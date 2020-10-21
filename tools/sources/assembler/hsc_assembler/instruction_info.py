from __future__ import annotations

import ctypes
import dataclasses
import enum
import functools
import typing

from hsc_assembler.sized_numbers import Uint8, Uint16, Uint24
from hsc_assembler.token_enums import (
    Label,
    Register,
    Shift,
    ShiftPointerDeref,
    Uint16PointerDeref,
)


def format_fields(
    **kwargs: int,
) -> typing.List[typing.Tuple[str, typing.Type[ctypes.c_uint], int]]:
    assert sum(kwargs.values()) == 24
    return [
        ("opcode", ctypes.c_uint, 8),
        *((name, ctypes.c_uint, value) for name, value in kwargs.items()),
    ]


class EncodingType(enum.Enum):
    # Don't have a good name for this encoding
    RRI = format_fields(rd=4, rm=4, imm16=16)

    # TODO: For shift, I am assming that the most significant bit determines
    # if it is a left shift (bit would be 0) or right shift (bit would be 1).
    # I don't know if that is actually true. That needs to be figured out.
    SHIFT = format_fields(rd=4, rm=4, rn=4, shift_type=1, shift=5, _padding=6)
    IMM24 = format_fields(imm24=24)
    REGISTER = format_fields(rd=4, rm=4, rn=4, _padding=12)
    JUMP = format_fields(rd=4, _padding=4, address=16)

    # Hacky solution, but it should work
    @functools.cached_property
    def encoding_class(self) -> typing.Type[BinaryInstruction]:
        class GenBinaryInstruction(BinaryInstruction):
            _fields_ = self.value

        return GenBinaryInstruction


class BinaryInstruction(ctypes.BigEndianStructure):
    opcode: int

    def to_bytes(self) -> bytes:
        return bytes(self)


@dataclasses.dataclass(init=False)
class EncodingSlot:
    arg_index: int
    # Allows multiple field accesses
    field: typing.Sequence[str]

    def __init__(self, arg_index: int, *fields: str) -> None:
        self.arg_index = arg_index
        self.field = fields

    def reversed_index(self) -> EncodingSlot:
        return type(self)(-self.arg_index - 1, *self.field)


@dataclasses.dataclass
class InstructionInfo:
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
    value: int
    encoding_type: EncodingType

    def __init__(
        self,
        types: typing.Sequence[typing.Type[InstructionArgTypes]],
        encoding_slots: typing.Dict[str, EncodingSlot],
        value: int,
        encoding_type: EncodingType,
    ) -> None:
        self.types = types
        self.encoding_slots = encoding_slots
        self.encoding_type = encoding_type
        self.value = Uint8(value)

    @classmethod
    def register_and_register_or_uint16(
        cls, instruction_value_register: int, instruction_value_imm: int
    ) -> MultInstructionInfo:
        return MultInstructionInfo(
            (
                cls.register_and_uint16(instruction_value_imm)[0],
                cls.two_register(instruction_value_register)[0],
            )
        )

    @classmethod
    def two_register_and_shift_or_uint16(
        cls, instruction_value_shift: int, instruction_value_imm: int
    ) -> MultInstructionInfo:
        return MultInstructionInfo(
            (
                cls.two_register_and_shift(instruction_value_shift)[0],
                cls(
                    (Register, Register, Uint16),
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
                cls(
                    (Register, Uint16PointerDeref),
                    {
                        "rd": EncodingSlot(0),
                        "rm": EncodingSlot(1, "register"),
                        "imm16": EncodingSlot(1, "increment"),
                    },
                    instruction_value_imm,
                    EncodingType.RRI,
                ),
                cls(
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

    @classmethod
    def uint24(cls, instruction_value: int) -> MultInstructionInfo:
        return MultInstructionInfo(
            (
                cls(
                    (Uint24,),
                    {"imm24": EncodingSlot(0)},
                    instruction_value,
                    EncodingType.IMM24,
                ),
            )
        )

    @classmethod
    def two_register(cls, instruction_value: int) -> MultInstructionInfo:
        # TODO: I don't know the encoding for this, so I'm just
        # going to do REGISTER encoding
        return MultInstructionInfo(
            (
                cls(
                    (Register, Register),
                    {"rd": EncodingSlot(0), "rm": EncodingSlot(1)},
                    instruction_value,
                    EncodingType.REGISTER,
                ),
            )
        )

    @classmethod
    def two_register_and_shift(cls, instruction_value: int) -> MultInstructionInfo:
        return MultInstructionInfo(
            (
                cls(
                    (Register, Register, Shift),
                    {
                        "rd": EncodingSlot(0),
                        "rm": EncodingSlot(1),
                        "rn": EncodingSlot(2, "register"),
                        "shift_type": EncodingSlot(2, "type"),
                        "shift": EncodingSlot(2, "amount"),
                    },
                    instruction_value,
                    EncodingType.SHIFT,
                ),
            )
        )

    @classmethod
    def register_and_uint16(cls, instruction_value: int) -> MultInstructionInfo:
        return MultInstructionInfo(
            (
                cls(
                    (Register, Uint16),
                    {"rd": EncodingSlot(0), "imm16": EncodingSlot(1)},
                    instruction_value,
                    EncodingType.RRI,
                ),
            )
        )

    @classmethod
    def register_and_uint16_or_shift(
        cls, instruction_value_uint16: int, instrction_value_shift: int
    ) -> MultInstructionInfo:
        return MultInstructionInfo(
            (
                cls.register_and_uint16(instruction_value_uint16)[0],
                cls(
                    (Register, Shift),
                    {
                        "rd": EncodingSlot(0),
                        "shift_type": EncodingSlot(1, "type"),
                        "shift": EncodingSlot(1, "amount"),
                        "rn": EncodingSlot(1, "register"),
                    },
                    instrction_value_shift,
                    EncodingType.SHIFT,
                ),
            )
        )

    @classmethod
    def register_and_label(cls, instruction_value: int) -> MultInstructionInfo:
        return MultInstructionInfo(
            (
                cls(
                    (Register, Label),
                    {"rd": EncodingSlot(0), "address": EncodingSlot(1)},
                    instruction_value,
                    EncodingType.JUMP,
                ),
            )
        )

    @classmethod
    def label(cls, instruction_value: int) -> MultInstructionInfo:
        return MultInstructionInfo(
            (
                cls(
                    (Label,),
                    {"address": EncodingSlot(0)},
                    instruction_value,
                    EncodingType.JUMP,
                ),
            )
        )


class NoEncodingError(Exception):
    pass


class MultInstructionInfo(typing.Tuple[InstructionInfo]):
    types: typing.List[typing.FrozenSet[typing.Type[InstructionArgTypes]]]

    def __init__(self, args) -> None:
        # This will be an issue if different versions of the same
        # instruction have a different argument count
        self.types = [
            frozenset(instruction_type)
            for instruction_type in zip(*(instruction.types for instruction in self))
        ]

    def get_encoding(
        self, args: typing.Union[typing.Sequence[InstructionArgTypes], int]
    ) -> InstructionInfo:
        if isinstance(args, int):
            try:
                return next(op for op in self if op.value == args)
            except StopIteration:
                raise NoEncodingError(
                    f"No valid encoding for this instruction with op code {args}"
                ) from None
        for instruction in self:
            if len(instruction.types) == len(args) and all(
                isinstance(arg, arg_type)
                for arg, arg_type in zip(args, instruction.types)
            ):
                return instruction

        raise NoEncodingError("No valid encoding with those args with this instruction")

    def reverse(self) -> MultInstructionInfo:
        return MultInstructionInfo(
            dataclasses.replace(
                instruction,
                types=tuple(reversed(instruction.types)),
                encoding_slots={
                    key: value.reversed_index()
                    for key, value in instruction.encoding_slots.items()
                },
            )
            for instruction in self
        )

    def __repr__(self) -> str:
        return f"{type(self).__name__}({super().__repr__()})"


class Instruction(enum.Enum):
    # The value arg in InstructionInfo is arbritrary right now; The actual value is TBD.
    LDR = InstructionInfo.register_and_pointer_deref_with_imm_or_shift(0, 1)
    STR = InstructionInfo.register_and_pointer_deref_with_imm_or_shift(2, 3).reverse()
    MOV = InstructionInfo.register_and_uint16_or_shift(4, 5)
    MOVT = InstructionInfo.register_and_uint16(6)
    ADD = InstructionInfo.two_register_and_shift_or_uint16(7, 8)
    ADDC = InstructionInfo.two_register_and_shift_or_uint16(9, 10)
    SUB = InstructionInfo.two_register_and_shift_or_uint16(11, 12)
    RSUB = InstructionInfo.two_register_and_shift_or_uint16(13, 14)
    SUBC = InstructionInfo.two_register_and_shift_or_uint16(15, 16)
    RSUBC = InstructionInfo.two_register_and_shift_or_uint16(17, 18)
    MUL = InstructionInfo.two_register_and_shift(19)
    AND = InstructionInfo.two_register_and_shift_or_uint16(20, 21)
    OR = InstructionInfo.two_register_and_shift_or_uint16(22, 23)
    XOR = InstructionInfo.two_register_and_shift_or_uint16(24, 25)
    NOT = InstructionInfo.two_register(26)  # Is this supposed to take two registers?
    CMP = InstructionInfo.register_and_register_or_uint16(27, 28)
    TST = InstructionInfo.register_and_register_or_uint16(29, 30)
    INT = InstructionInfo.uint24(31)
    JMP = InstructionInfo.label(32)
    # TODO: Add branch, jump, and other missed instructions

    @classmethod
    def from_int(cls, op: int) -> Instruction:
        try:
            return next(
                mem
                for mem in cls
                if op in {instruction.value for instruction in mem.value}
            )
        except StopIteration:
            raise ValueError(f"There is no instruction with the value {op}") from None


InstructionArgTypes = typing.Union[
    ShiftPointerDeref, Uint16PointerDeref, Uint16, Uint24, Shift, Label, Register
]
