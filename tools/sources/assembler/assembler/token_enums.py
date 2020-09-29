"""Enums for Tokens."""
from __future__ import annotations

import dataclasses
import enum
import typing

import aenum
from parseable import Parseable
from sized_numbers import Uint16, Uint24

__all__ = [  # noqa
    "Token",
    "TokenType",
    "Syntax",
    "Register",
    "Instruction",
    "Shift",
    "PointerDeref",
    "instruction_arg_types",
]

InstructionArgTypes = typing.Union["Register", "PointerDeref", Uint16, Uint24, "Shift"]

if typing.TYPE_CHECKING:
    from scanner import Token
    from sized_numbers import Uint5


def __getattr__(name: str) -> typing.Any:
    # To prevent a circular import error
    if name == "Token":
        from .scanner import Token

        return Token
    raise AttributeError(f"module {__name__!r} has no attribute {name!r}")


class TokenType(enum.Enum):
    INSTRUCTION = enum.auto()
    REGISTER = enum.auto()
    SYNTAX = enum.auto()
    LABEL = enum.auto()
    STRING = enum.auto()
    UINT = enum.auto()


# This is defined like this because of the special characters as the enum names
Syntax = enum.Enum("Syntax", [",", "[", "]", "+", ":", "<<", ">>"])


class Register(Parseable, enum.Enum):
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
    lr = -1
    sp = -2


ShiftType = enum.Enum("ShiftType", ["<<", ">>"])


@dataclasses.dataclass
class Shift(Parseable):
    type: ShiftType
    register: Register
    amount: Uint5


@dataclasses.dataclass
class PointerDeref(Parseable):
    register: Register
    increment: typing.Union[Uint16, Shift]


class Instruction(aenum.Enum):
    _settings_ = aenum.NoAlias

    # The values are the constraints the instruction operands have to be under
    LDR = (Register, PointerDeref)
    STR = (PointerDeref, Register)
    MOV = (Register, (Uint16, Shift))
    MOVT = (Register, Uint16)
    ADD = (Register, Register, (Shift, Uint16))
    ADDC = (Register, Register, (Shift, Uint16))
    SUB = (Register, Register, (Shift, Uint16))
    RSUB = (Register, Register, (Shift, Uint16))
    SUBC = (Register, Register, (Shift, Uint16))
    RSUBC = (Register, Register, (Shift, Uint16))
    MUL = (Register, Register, Shift)
    # INC = enum.auto()
    # DEC = enum.auto()
    AND = (Register, Register, (Shift, Uint16))
    OR = (Register, Register, (Shift, Uint16))
    XOR = (Register, Register, (Shift, Uint16))
    NOT = (Register, Register)
    CMP = (Register, (Shift, Uint16))
    TST = (Register, (Shift, Uint16))
    INT = (Uint24,)
    # TODO: Add branch, jump, and other missed instructions


instruction_arg_types = (Register, PointerDeref, Uint16, Uint24, Shift)
