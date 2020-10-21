# TODO: Finish encoding the ISA encoding in code
"""Enums for Tokens."""
from __future__ import annotations

import dataclasses
import enum
import typing

from hsc_assembler.errors import DecodingError, merge_exceptions
from hsc_assembler.parseable import Parseable
from hsc_assembler.sized_numbers import Uint5, Uint16

__all__ = [  # noqa
    "Token",
    "TokenType",
    "Syntax",
    "Register",
    "Shift",
    "ShiftType",
    "PointerDeref",
    "Label",
    "DecodeEnumFromValueMixin",
    "ShiftPointerDeref",
    "Uint16PointerDeref",
]

if typing.TYPE_CHECKING:
    from scanner import Token


def __getattr__(name: str) -> typing.Any:
    # To prevent a circular import error
    if name == "Token":
        from .scanner import Token

        return Token
    raise AttributeError(f"module {__name__!r} has no attribute {name!r}")


TC = typing.TypeVar("TC", bound="DecodeEnumFromValueMixin")


class DecodeEnumFromValueMixin:
    @classmethod
    def from_int(cls: typing.Type[TC], value: int) -> TC:
        try:
            return next(
                enum_mem for enum_mem in cls if enum_mem.value == value  # type: ignore
            )
        except StopIteration:
            raise merge_exceptions("DecodeKeyError", KeyError, DecodingError)(
                f"No {cls.__name__} with encoding {value}"
            ) from None


class TokenType(enum.Enum):
    INSTRUCTION = enum.auto()
    REGISTER = enum.auto()
    SYNTAX = enum.auto()
    LABEL = enum.auto()
    STRING = enum.auto()
    UINT = enum.auto()


# This is defined like this because of the special characters as the enum names
Syntax = enum.Enum("Syntax", [",", "[", "]", "+", ":", "<<", ">>"])


class Register(DecodeEnumFromValueMixin, Parseable, enum.Enum):
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
    lr = 14
    sp = 15

    @classmethod
    def from_fields(cls, fields: typing.Dict[typing.Tuple[str, ...], int]) -> Register:
        return cls.from_int(fields[()])

    def asm_code(self) -> str:
        return self.name


# The values are the values left and right shifts are represented with
# in the encoding, which I do not know.
ShiftType = enum.Enum(  # type: ignore
    "ShiftType", {"<<": 0, ">>": 1}, type=DecodeEnumFromValueMixin
)


class Label(Parseable, str):
    @classmethod
    def from_fields(cls, fields: typing.Dict[typing.Tuple[str, ...], int]) -> Label:
        # Should the label's string representation be in hex?
        return cls(hex(fields[()]))

    def __repr__(self) -> str:
        return f"{type(self).__name__}({super().__repr__()})"

    def __str__(self) -> str:
        return super().__repr__()

    asm_code = __str__


@dataclasses.dataclass
class Shift(Parseable):
    type: ShiftType
    register: Register
    amount: Uint5

    @classmethod
    def from_fields(cls, fields: typing.Dict[typing.Tuple[str, ...], int]) -> Shift:
        shift_type = ShiftType.from_int(fields[("type",)])  # type: ignore
        shift_register = Register.from_int(fields[("register",)])
        shift_amount = Uint5(fields[("amount",)])
        return cls(shift_type, shift_register, shift_amount)

    def asm_code(self) -> str:
        return f"{self.register.asm_code()} {self.type.name} {self.amount.asm_code()}"


TI = typing.TypeVar("TI", Uint16, Shift)


@dataclasses.dataclass
class PointerDeref(Parseable, typing.Generic[TI]):
    register: Register
    increment: TI
    inc_parse_function: typing.ClassVar[
        typing.Callable[[typing.Sequence[Token], int], TI]
    ]

    def asm_code(self) -> str:
        return f"[{self.register.asm_code()} + {self.increment.asm_code()}]"


# These are seperate because they have different binary encodings
class Uint16PointerDeref(PointerDeref[Uint16]):
    inc_parse_function = Uint16.parse

    @classmethod
    def from_fields(
        cls, fields: typing.Dict[typing.Tuple[str, ...], int]
    ) -> Uint16PointerDeref:
        dest_register = Register.from_int(fields[("register",)])
        increment = Uint16(fields[("increment",)])
        return cls(dest_register, increment)


class ShiftPointerDeref(PointerDeref[Shift]):
    inc_parse_function = Shift.parse

    @classmethod
    def from_fields(
        cls, fields: typing.Dict[typing.Tuple[str, ...], int]
    ) -> ShiftPointerDeref:
        dest_register = Register.from_int(fields[("register",)])
        shift = Shift.from_fields(
            {
                name[1:]: value
                for name, value in fields.items()
                if name[0] == "increment"
            }
        )
        return cls(dest_register, shift)
