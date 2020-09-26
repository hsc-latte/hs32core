from __future__ import annotations

import dataclasses
import enum
import shlex
import sys
import typing

from errors import error_print, format_error


# Move some of this to a seperate base class?
class ScanError(Exception):
    def __init__(self, message: str, line: typing.Optional[int], *args):
        super().__init__(format_error(message, line), *args)

    @classmethod
    def collect_errors(cls, errors: typing.Iterable[str]) -> ScanError:
        """ Collects multiple errors into a single error """
        message = "\n".join(errors)
        return cls(message, None)

    # Code is EX_DATAERR, taken from here https://man.openbsd.org/sysexits.3
    def error_exit(self, code=65):
        """ Prints the error then exits the program """
        error_print(self.args[0])
        sys.exit(code)


class TokenType(enum.Enum):
    INSTRUCTION = enum.auto()
    REGISTER = enum.auto()
    SYNTAX = enum.auto()
    LABEL = enum.auto()
    CONSTANT = enum.auto()


# This is defined like this because of the special characters as the enum names
Syntax = enum.Enum("Syntax", [",", "[", "]", "+", ":", "<<", ">>"])


class Register(enum.Enum):
    """
    Enum of the registers.
    If the value is positive, it is the value of the register in code.
    """

    r0 = 0
    r1 = 1
    r2 = 2
    r3 = 3
    r4 = 4
    r5 = 5
    r6 = 6
    r7 = 7
    r8 = 8
    r9 = 9
    r10 = 10
    r11 = 11
    r12 = 12
    r13 = 13
    r14 = 14
    r15 = 15
    lp = -1
    sr = -2


class Instruction(enum.Enum):
    # Should the values mean something?
    LDR = enum.auto()
    STR = enum.auto()
    MOV = enum.auto()
    MOVT = enum.auto()
    ADD = enum.auto()
    SUB = enum.auto()
    MUL = enum.auto()
    INC = enum.auto()
    DEC = enum.auto()
    AND = enum.auto()
    OR = enum.auto()
    XOR = enum.auto()
    NOT = enum.auto()
    CMP = enum.auto()
    TST = enum.auto()
    INT = enum.auto()
    ADDC = enum.auto()
    RSUB = enum.auto()
    SUBC = enum.auto()
    RSUBC = enum.auto()
    # TODO: Add branch, jump, and other missed instructions


@dataclasses.dataclass
class Token:
    type: TokenType
    # These are the types Token.value would be depending on the Token.type
    # INSTRUCTION: Instruction (the specific instruction)
    # REGISTER: Register (the specific register)
    # SYNTAX: Syntax (the specific syntax)
    # LABEL: str (Name of the label)
    # CONSTANT: bytes or int
    value: typing.Union[str, bytes, int, Register, Instruction, Syntax]
    line: int

    @classmethod
    def scan_instruction(cls, token_string: str, line: int) -> Token:
        try:
            instruction = Instruction[token_string.upper()]
        except KeyError:
            raise ScanError(f"Invalid instruction {token_string}", line) from None
        return Token(TokenType.INSTRUCTION, instruction, line)

    @classmethod
    def scan_register(cls, token_string: str, line: int) -> Token:
        try:
            register = Register[token_string.lower()]
        except KeyError:
            raise ScanError(f"Invalid register {token_string}", line) from None
        return cls(TokenType.REGISTER, register, line)

    @classmethod
    def scan_string(cls, token_string: str, line: int) -> Token:
        """
        Scans a string to a string (or character) token.
        If the token isn't valid, returns None.
        """
        if token_string[0] in {"'", '"'} and token_string[-1] == token_string[0]:
            return cls(
                TokenType.CONSTANT,
                token_string[1:-1].encode()
                + (b"\0" if token_string[0] == '"' else b""),
                line,
            )
        raise ScanError(f"Invalid string {token_string}", line)

    @classmethod
    def scan_syntax(cls, token_string: str, line: int) -> Token:
        """ Scans a string to a syntactical token. """
        try:
            syntax = Syntax[token_string]
        except KeyError:
            raise ScanError(f"Invalid syntax {token_string}", line)
        return cls(TokenType.SYNTAX, syntax, line)

    @classmethod
    def scan_integer(cls, token_string: str, line: int) -> Token:
        try:
            value = int(token_string, 0)
        except ValueError:
            raise ScanError(f"Invalid integer {token_string}", line) from None
        return cls(TokenType.CONSTANT, value, line)

    @classmethod
    def scan_label(cls, token_string: str, line: int) -> Token:
        """
        Scans a label.

        Any string is a valid label unless it has a character in the `Syntax` enum.
        """
        if any(syntax in token_string for syntax in Syntax.__members__):
            raise ScanError(
                f"Invalid label {token_string}."
                "Does this have a syntax character in it? They're one of these:\n"
                f"{list(Syntax.__members__)}",
                line,
            )
        return cls(TokenType.LABEL, token_string, line)

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
        for scan in scanners:
            try:
                return scan(token_string, line)
            except ScanError:
                pass
        raise ScanError(f'Invalid token "{token_string}"', line)


def counted_lowered_lines(text: str) -> typing.Iterator[typing.Tuple[int, str]]:
    """
    Yields the line number and the lower cased line.

    If the line is empty or only has whitespace, the line counts towards
    the line count but isn't yielded. The line count starts at 1
    """
    for line_num, line in enumerate(text.lower().splitlines(), 1):
        if not line.isspace() and line:
            yield line_num, line


def scan_label_def(str_token: str, line: int) -> typing.Tuple[Token, Token]:
    if str_token[-1] == ":":
        return (
            Token.scan_label(str_token[:-1], line),
            Token(TokenType.SYNTAX, Syntax[":"], line),
        )
    raise ScanError(f"Invalid label definition {str_token}", line)


def scan(text: str) -> typing.Iterator[typing.List[Token]]:
    # This keeps going after it errors to find all the errors in the program
    errors: typing.List[str] = []
    for line_num, line in counted_lowered_lines(text):
        line = line.split(";", 1)[0].strip()
        try:
            if line[-1] == ":":
                line_tokens = list(scan_label_def(line, line_num))
            else:
                # Using shlex seems to work, but there may be issues
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
