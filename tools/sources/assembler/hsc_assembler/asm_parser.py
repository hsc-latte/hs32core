# TODO: Improve error messages
# Replace this with a parsing library (e.g pyparsing)?
from __future__ import annotations

import typing

from hsc_assembler.errors import ParseError, format_error
from hsc_assembler.instruction import Instruction
from hsc_assembler.instruction_info import Instruction as InstructionEnum
from hsc_assembler.sized_numbers import (
    OverflowError_,
    PositiveSizedNumber,
    Uint5,
    Uint16,
)
from hsc_assembler.token_enums import (
    Label,
    Register,
    Shift,
    ShiftType,
    Syntax,
    TokenType,
)

if typing.TYPE_CHECKING:
    from .parseable import Parseable  # noqa
    from .token_enums import PointerDeref, Token

    TPA = typing.TypeVar("TPA", bound=Parseable)


__all__ = ["InstructionsNT", "parse"]


class InstructionsNT(typing.NamedTuple):
    instructions: typing.Sequence[Instruction]
    symbol_table: typing.Dict[str, int]


def comma_split(tokens: typing.Iterable[Token]) -> typing.Iterator[typing.List[Token]]:
    current_tokens: typing.List[Token] = []
    for token in tokens:
        if token.type is TokenType.SYNTAX and token.value is Syntax[","]:
            yield current_tokens
            current_tokens = []
        else:
            current_tokens.append(token)
    if current_tokens:
        yield current_tokens


def empty_token_check(
    tokens: typing.Sequence[Token], line: int
) -> typing.Sequence[Token]:
    if not tokens:
        raise ParseError("Empty operand", line)
    return tokens


def extact_token(one_token: typing.Sequence[Token], line: int) -> Token:
    empty_token_check(one_token, line)
    if len(one_token) > 1:
        raise ParseError(
            f'Extra text "{"".join(token.text for token in one_token[1:])}"', line,
        )
    return one_token[0]


def token_type_check(
    token: Token,
    token_types: typing.Union[TokenType, typing.Iterable[TokenType]],
    line: int,
) -> Token:
    if isinstance(token_types, TokenType):
        token_types = (token_types,)
    if token.type not in token_types:
        type_names = " or ".join(token_type.name.lower() for token_type in token_types)
        message = f'Token "{token.text}" instead of {type_names}'
        raise ParseError(message, line)
    return token


TN = typing.TypeVar("TN", bound=PositiveSizedNumber)


def extract_token_num(token: Token, num_type: typing.Type[TN], line: int) -> TN:
    token_type_check(token, (TokenType.UINT, TokenType.STRING), line)
    try:
        return num_type(token.value)
    except OverflowError_:
        assert isinstance(token.value, int)
        message = (
            f"Number or string {token.value} is too large. "  # type: ignore
            f"The max size for this operand is {num_type.MAX}. "
            f"The orignal text was {token.text}."
        )
        raise ParseError(message, line) from None


# These are for the Parseable visitors


def parse_Register(
    cls: typing.Type[Register], tokens: typing.Sequence[Token], line: int
) -> Register:
    token = token_type_check(extact_token(tokens, line), TokenType.REGISTER, line)
    assert isinstance(token.value, cls)
    return token.value


def parse_PointerDeref(
    cls: typing.Type[PointerDeref], tokens: typing.Sequence[Token], line: int,
) -> PointerDeref:
    empty_token_check(tokens, line)
    if tokens[0].value != Syntax["["] or tokens[-1].value != Syntax["]"]:
        str_tokens = "".join(token.text for token in tokens)
        raise ParseError(f"Invalid pointer dereference {str_tokens}", line)
    register = Register.parse(tokens[1], line)
    if len(tokens) > 3:
        if tokens[2].value != Syntax["+"]:
            raise ParseError(f'Expected "+" sign, instead got {tokens[2].text}', line)
        increment = cls.inc_parse_function(tokens[3:-1], line)
    else:
        increment = Uint16(0)
    return cls(register, increment)


parse_Uint16PointerDeref = parse_ShiftPointerDeref = parse_PointerDeref


def parse_number(
    cls: typing.Type[PositiveSizedNumber], tokens: typing.Sequence[Token], line: int
) -> PositiveSizedNumber:
    return extract_token_num(extact_token(tokens, line), cls, line)


parse_Uint24 = parse_Uint16 = parse_number


def parse_Shift(
    cls: typing.Type[Shift], tokens: typing.Sequence[Token], line: int
) -> Shift:
    empty_token_check(tokens, line)
    register = Register.parse(tokens[0], line)
    if len(tokens) == 1:
        shift_type = ShiftType["<<"]
        amount = Uint5(0)
    elif tokens[1].value not in {Syntax[">>"], Syntax["<<"]}:
        raise ParseError(f"Invalid operator {tokens[1].text}", line)
    else:
        assert isinstance(tokens[1].value, Syntax)
        shift_type = ShiftType[tokens[1].value.name]
        amount = extract_token_num(extact_token(tokens[2:], line), Uint5, line)
    return cls(shift_type, register, amount)


def parse_args(
    parser_types: typing.Iterable[typing.Iterable[typing.Type[TPA]]],
    args: typing.Iterable[typing.Sequence[Token]],
) -> typing.Iterator[TPA]:
    errors = []
    for arg_types, arg in zip(parser_types, args):
        for arg_type in arg_types:
            try:
                parsed_arg = arg_type.parse(arg, arg[0].line)  # type: ignore
                break
            except ParseError as exc:
                error = exc.args[0]
        else:
            errors.append(error)
        if not errors:
            yield parsed_arg
    if errors:
        raise ParseError.collect_errors(errors)


def parse_Label(
    cls: typing.Type[Label], tokens: typing.Sequence[Token], line: int
) -> Label:
    return Label(
        token_type_check(extact_token(tokens, line), TokenType.LABEL, line).value
    )


def parse(tokens: typing.Iterator[typing.Sequence[Token]]) -> InstructionsNT:
    instructions = []
    symbol_table = {}
    ip = 0
    errors = []
    for line in tokens:
        line_num = line[0].line
        if line[-1].value is Syntax[":"]:
            assert line[-1].type is TokenType.SYNTAX
            assert len(line) == 2
            assert line[0].type is TokenType.LABEL
            assert isinstance(line[0].value, str)
            # is ip the correct value for this?
            symbol_table[line[0].value] = ip
        else:
            ip += 32
            assert line[0].type is TokenType.INSTRUCTION
            instruction = line[0].value
            assert isinstance(instruction, InstructionEnum)
            raw_args = list(comma_split(line[1:]))
            if len(raw_args) != len(instruction.value.types):
                message = (
                    f"Opcode {instruction.name} takes {len(instruction.value)} "
                    f"arguments, but was given {len(raw_args)} arguments."
                )
                errors.append(format_error(message, line_num))

            args = parse_args(instruction.value.types, raw_args)

            instructions.append(Instruction(instruction, list(args)))
    if errors:
        raise ParseError.collect_errors(errors)
    return InstructionsNT(instructions, symbol_table)
