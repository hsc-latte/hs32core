# TODO: Finish encoding the ISA encoding in code
"""Enums for Tokens."""
from __future__ import annotations

import dataclasses
import enum
import typing

from instruction import BinaryInstruction, DecodeEnumFromValueMixin, EncodingType
from parseable import Parseable
from sized_numbers import Uint8, Uint16, Uint24

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


TI = typing.TypeVar("TI", Uint16, Shift)


@dataclasses.dataclass
class PointerDeref(Parseable, typing.Generic[TI]):
    register: Register
    increment: TI
    inc_parse_function: typing.ClassVar[
        typing.Callable[[typing.Sequence[Token], int], TI]
    ]


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


@dataclasses.dataclass(init=False)
class EncodingSlot:
    arg_index: int
    # Allows multiple field accesses
    field: typing.Sequence[str]

    def __init__(self, arg_index: int, *fields: str) -> None:
        self.arg_index = arg_index
        self.field = fields


class InstructionInfo(typing.NamedTuple):
    """
    Information about the instruction

    types: The corrosponding types of the instruction arguments
    encoding_slots: Dict of the slot on the encoding name and where to get its
    value in the instruction's args
    value: The argument's value in the encoding
    encoding: The instruction's encoding
    """

    types: typing.Sequence[typing.Type[InstructionArgTypes]]
    encoding_slots: typing.Dict[str, EncodingSlot]
    value: Uint8
    encoding_class: BinaryInstruction

    @classmethod
    def register_and_register_or_uint16(
        cls, instruction_value_shift: int, instruction_value_imm: int
    ) -> MultInstructionInfo:
        pass
        # return MultInstructionInfo(
        #     (
        #         cls(
        #             [Register, Shift],
        #             {
        #                 "rd": EncodingSlot(0),
        #                 "rm": EncodingSlot(1),
        #                 "rn": EncodingSlot(2, "register"),
        #                 "shift_type": EncodingSlot(2, "type"),
        #                 "shift": EncodingSlot(2, "amount"),
        #             },
        #             instruction_value_shift,
        #             EncodingType.SHIFT,
        #         ),
        #         cls(
        #             [Register, Uint16],
        #             {
        #                 "rd": EncodingSlot(0),
        #                 "rm": EncodingSlot(1),
        #                 "imm16": EncodingSlot(2),
        #             },
        #             instruction_value_imm,
        #             EncodingType.RRI,
        #         ),
        #     )
        # )

    @classmethod
    def two_register_and_shift_or_uint16(
        cls, instruction_value_shift: int, instruction_value_imm: int
    ) -> MultInstructionInfo:
        return MultInstructionInfo(
            (
                cls(
                    [Register, Register, Shift],
                    {
                        "rd": EncodingSlot(0),
                        "rm": EncodingSlot(1),
                        "rn": EncodingSlot(2, "register"),
                        "shift_type": EncodingSlot(2, "type"),
                        "shift": EncodingSlot(2, "amount"),
                    },
                    instruction_value_shift,
                    EncodingType.SHIFT,
                ),
                cls(
                    [Register, Register, Uint16],
                    {
                        "rd": EncodingSlot(0),
                        "rm": EncodingSlot(1),
                        "imm16": EncodingSlot(2),
                    },
                    instruction_value_imm,
                    EncodingType.RRI,
                ),
            )
        )

    @classmethod
    def register_and_pointer_deref_with_imm_or_shift(
        cls, instruction_value_imm: int, instruction_value_shift: int
    ) -> MultInstructionInfo:
        return MultInstructionInfo(
            (
                InstructionInfo(
                    # PointerDeref isn't generic because that makes different
                    # generic classes not equal each other, which messes things up.
                    (Register, Uint16PointerDeref),
                    {
                        "rd": EncodingSlot(0),
                        "rm": EncodingSlot(1, "register"),
                        "imm16": EncodingSlot(1, "increment"),
                    },
                    instruction_value_imm,
                    EncodingType.RRI,
                ),
                InstructionInfo(
                    (Register, ShiftPointerDeref),
                    {
                        "rd": EncodingSlot(0),
                        "rm": EncodingSlot(1, "register"),
                        "rn": EncodingSlot(1, "increment", "register"),
                        "shift_type": EncodingSlot(1, "increment", "type"),
                        "shift": EncodingSlot(1, "increment", "amount"),
                    },
                    instruction_value_shift,
                    EncodingType.SHIFT,
                ),
            )
        )


class NoEncodingError(Exception):
    pass


class MultInstructionInfo(typing.Tuple[InstructionInfo]):
    types: typing.List[typing.Set[typing.Type[InstructionArgTypes]]]

    def __init__(self, args) -> None:
        self.types = [
            set(instruction_type)
            for instruction_type in zip(*(instruction.types for instruction in self))
        ]

    def get_encoding(
        self, args: typing.Sequence[InstructionArgTypes]
    ) -> InstructionInfo:
        for instruction in self:
            if len(instruction.types) == len(args) and all(
                isinstance(arg, tuple(arg_type))  # type: ignore
                for arg, arg_type in zip(args, instruction.types)
            ):
                return instruction

        raise NoEncodingError("No valid encoding with those args")

    def reverse(self) -> MultInstructionInfo:
        return MultInstructionInfo(reversed(self))


class Instruction(enum.Enum):
    # The value arg in InstructionInfo is arbritrary right now; The actual value is TBD.
    LDR = InstructionInfo.register_and_pointer_deref_with_imm_or_shift(0, 1)
    STR = InstructionInfo.register_and_pointer_deref_with_imm_or_shift(2, 3).reverse()
    MOV = (Register, (Uint16, Shift))
    MOVT = (Register, Uint16)
    ADD = InstructionInfo.two_register_and_shift_or_uint16(7, 8)
    ADDC = InstructionInfo.two_register_and_shift_or_uint16(9, 10)
    SUB = InstructionInfo.two_register_and_shift_or_uint16(11, 12)
    RSUB = InstructionInfo.two_register_and_shift_or_uint16(13, 14)
    SUBC = InstructionInfo.two_register_and_shift_or_uint16(15, 16)
    RSUBC = InstructionInfo.two_register_and_shift_or_uint16(17, 18)
    MUL = (Register, Register, Shift)
    # INC = enum.auto()
    # DEC = enum.auto()
    AND = InstructionInfo.two_register_and_shift_or_uint16(20, 21)
    OR = InstructionInfo.two_register_and_shift_or_uint16(22, 23)
    XOR = InstructionInfo.two_register_and_shift_or_uint16(24, 25)
    NOT = (Register, Register)
    CMP = (Register, (Register, Uint16))
    TST = (Register, (Register, Uint16))
    INT = (Uint24,)
    # TODO: Add branch, jump, and other missed instructions

    @classmethod
    def from_byte(cls, byte: bytes) -> Instruction:
        if len(byte) != 1:
            raise ValueError("More than one byte passed")

        op = int.from_bytes(byte, "big")
        try:
            return next(
                mem for mem in cls if mem.value.value == op  # type: ignore
            )
        except StopIteration:
            message = (
                "There is no instruction with the value of byte "
                f"{byte!r} (int value {op})"
            )
            raise ValueError(message) from None


instruction_arg_types = (
    Register,
    ShiftPointerDeref,
    Uint16PointerDeref,
    Uint16,
    Uint24,
    Shift,
    str,
)

InstructionArgTypes = typing.Union[
    ShiftPointerDeref, Uint16PointerDeref, Uint16, Uint24, Shift, str
]
