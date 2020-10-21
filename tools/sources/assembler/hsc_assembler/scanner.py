from __future__ import annotations

import dataclasses
import shlex
import typing

from hsc_assembler.errors import ScanError, exception_chain
from hsc_assembler.instruction_info import Instruction
from hsc_assembler.sized_numbers import MAX_NUM
from hsc_assembler.token_enums import Register, Syntax, TokenType


# This is defined here, instead of in token_enums.py because of its scanner methods
# Maybe the visitor pattern would help here for code organization?
@dataclasses.dataclass
class Token:
    type: TokenType
    # These are the types Token.value would be depending on the Token.type
    # INSTRUCTION: Instruction (the specific instruction)
    # REGISTER: Register (the specific register)
    # SYNTAX: Syntax (the specific syntax)
    # LABEL: str (Name of the label)
    # STRING: int
    # INT: int
    value: typing.Union[str, bytes, int, Register, Instruction, Syntax]
    line: int
    text: str

    @classmethod
    def scan_instruction(cls, token_string: str, line: int) -> Token:
        try:
            instruction = Instruction[token_string.upper()]
        except KeyError:
            raise ScanError(f"Invalid instruction {token_string}", line) from None
        return Token(TokenType.INSTRUCTION, instruction, line, token_string)

    @classmethod
    def scan_register(cls, token_string: str, line: int) -> Token:
        try:
            register = Register[token_string.lower()]
        except KeyError:
            raise ScanError(f"Invalid register {token_string}", line) from None
        return cls(TokenType.REGISTER, register, line, token_string)

    @classmethod
    def scan_string(cls, token_string: str, line: int) -> Token:
        """
        Scans a string to a string (or character) token.
        If the token isn't valid, returns None.
        """
        if token_string[0] in {"'", '"'} and token_string[-1] == token_string[0]:
            value = int.from_bytes(
                token_string[1:-1].encode()
                + (b"\0" if token_string[0] == '"' else b""),
                "big",
            )
            return cls(TokenType.STRING, value, line, token_string)
        raise ScanError(f"Invalid string {token_string}", line)

    @classmethod
    def scan_syntax(cls, token_string: str, line: int) -> Token:
        """ Scans a string to a syntactical token. """
        try:
            syntax = Syntax[token_string]
        except KeyError:
            raise ScanError(f"Invalid syntax {token_string}", line)
        return cls(TokenType.SYNTAX, syntax, line, token_string)

    @classmethod
    def scan_integer(cls, token_string: str, line: int) -> Token:
        try:
            value = int(token_string, 0)
        except ValueError:
            raise ScanError(f"Invalid integer {token_string}", line) from None
        if value < 0:
            raise ScanError(f"Negative integer {value} is not supported", line)
        if value > MAX_NUM:
            message = (
                f"Integer {value} is too big, the largest supported number is {MAX_NUM}"
            )
            raise ScanError(message, line)
        return cls(TokenType.UINT, value, line, token_string)

    @classmethod
    def scan_label(cls, token_string: str, line: int) -> Token:
        """
        Scans a label.

        Any string is a valid label unless it has a character in the `Syntax` enum.
        """
        if any(syntax in token_string for syntax in Syntax.__members__):
            raise ScanError(
                f"Invalid label {token_string}. "
                "Does this have a syntax character in it? They're one of these:\n"
                f"{list(Syntax.__members__)}",
                line,
            )
        return cls(TokenType.LABEL, token_string, line, token_string)

    @classmethod
    def scan_token(cls, token_string: str, line: int) -> Token:
        scanners = (
            cls.scan_instruction,
            cls.scan_register,
            cls.scan_string,
            cls.scan_syntax,
            cls.scan_integer,
            cls.scan_label,
        )
        return exception_chain(
            scanners,
            ScanError(f'Invalid token "{token_string}"', line),
            token_string,
            line,
        )


def counted_lowered_no_comment_lines(
    text: str,
) -> typing.Iterator[typing.Tuple[int, str]]:
    """
    Yields the line number and the lower cased line without comments.

    If the line is empty, only has whitespace, or only has comments the line
    counts towards the line count but isn't yielded. The line count starts at 1.
    """
    for line_num, line in enumerate(text.lower().splitlines(), 1):
        line = line.split(";", 1)[0].strip()
        if not line.isspace() and line:
            yield line_num, line


def scan_label_def(str_token: str, line: int) -> typing.Tuple[Token, Token]:
    if str_token[-1] == ":":
        return (
            Token.scan_label(str_token[:-1], line),
            Token(TokenType.SYNTAX, Syntax[":"], line, str_token),
        )
    raise ScanError(f"Invalid label definition {str_token}", line)


def scan(text: str) -> typing.Iterator[typing.List[Token]]:
    # This keeps going after it errors to find all the errors in the program
    errors: typing.List[str] = []
    for line_num, line in counted_lowered_no_comment_lines(text):
        try:
            if line[-1] == ":":
                line_tokens = list(scan_label_def(line, line_num))
            else:
                # Using shlex seems to work, but there may be issues
                # TODO: Shlex doesn't fully support unicode characters.
                tokens = shlex.shlex(line, punctuation_chars="><", posix=False)
                try:
                    instruction = Token.scan_instruction(tokens.get_token(), line_num)
                except ScanError as exc:
                    errors.append(exc.args[0])
                    # This is to prevent a NameError.
                    # If instruction is None, errors isn't empty so it isn't yielded
                    # The "type: ignore" is to quiet the type checker
                    instruction = None  # type: ignore

                line_tokens = [
                    instruction,
                    *(Token.scan_token(token, line_num) for token in tokens),
                ]
            if not errors:
                yield line_tokens
        except ScanError as exc:
            errors.append(exc.args[0])

    if errors:
        raise ScanError.collect_errors(errors)
