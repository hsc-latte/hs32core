from __future__ import annotations

import ctypes
import dataclasses
import enum
import itertools
import typing

from errors import DecodingError, merge_exceptions
from utilities import chunk, getattributes

if typing.TYPE_CHECKING:
    from sized_numbers import Uint16
    from token_enums import Instruction as InstructionEnum
    from token_enums import InstructionArgTypes, InstructionInfo, Label


def format_fields(
    **kwargs: int,
) -> typing.List[typing.Tuple[str, typing.Type[ctypes.c_int], int]]:
    assert sum(kwargs.values()) == 24
    return [
        ("opcode", ctypes.c_int, 8),
        *((name, ctypes.c_int, value) for name, value in kwargs.items()),
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


class BinaryInstruction(ctypes.BigEndianStructure):
    opcode: int

    def to_bytes(self) -> bytes:
        return bytes(self)


class InstructionRRI(BinaryInstruction):
    _fields_ = EncodingType.RRI.value


class InstructionShift(BinaryInstruction):
    _fields_ = EncodingType.SHIFT.value


class InstructionIMM24(BinaryInstruction):
    _fields_ = EncodingType.IMM24.value


class InstrructionRegister(BinaryInstruction):
    _fields_ = EncodingType.REGISTER.value


class InstructionJump(BinaryInstruction):
    _fields_ = EncodingType.JUMP.value


@dataclasses.dataclass(init=False)
class Instruction:
    type: InstructionEnum
    # The exact types are based on the value of the InstructionEnum
    args: typing.Sequence[InstructionArgTypes]

    def __init__(
        self,
        instruction_type: InstructionEnum,
        args: typing.Sequence[InstructionArgTypes],
    ) -> None:
        # TODO: Have this raise an actual error, not just an assertion
        if __debug__:
            for arg, arg_type in zip(args, instruction_type.value):
                assert isinstance(arg, arg_type)
        self.type = instruction_type
        self.args = args

    def to_bytes(self, symbol_table: typing.Dict[Label, Uint16]) -> bytes:
        encoding: InstructionInfo = self.type.value.get_encoding()
        encoding_values = {}
        for encoding_slot, field_name in encoding.encoding_slots.items():
            value = getattributes(self.args[field_name.arg_index], *field_name.field)
            if isinstance(value, enum.Enum):
                value = value.value
            elif isinstance(value, Label):
                value = symbol_table[value]
            encoding_values[encoding_slot] = value
        return self.type.value.encoding_class(
            self.type.value.value, **encoding_values
        ).to_bytes()

    @classmethod
    def from_bytes(cls, byte_op: bytes) -> Instruction:
        if len(byte_op) != 4:
            raise DecodingError(
                f"Instructions are of length 4, this is of length {len(byte_op)}"
            )
        instruction = InstructionEnum.from_byte(byte_op[0])
        instruction_info: InstructionInfo = instruction.value
        byte_instruction = instruction_info.encoding_class.from_buffer(byte_op)
        fields_to_values = (
            {
                tuple(decoded_rep.fields): getattr(byte_instruction, encoded_field)
                for encoded_field, decoded_rep in encoding_slots
            }
            for _, encoding_slots in itertools.groupby(
                sorted(
                    instruction_info.encoding_slots.items(),
                    key=lambda x: x[1].arg_index,
                ),
                lambda x: x[1].arg_index,
            )
        )
        decoded_values = [
            arg_type.from_fields(fields)
            for arg_type, fields in zip(instruction_info.types, fields_to_values)
        ]
        return cls(instruction, decoded_values)


def encode_instructions(
    instructions: typing.Iterable[Instruction], symbol_table: typing.Dict[Label, Uint16]
) -> bytes:
    return b"".join(instruction.to_bytes(symbol_table) for instruction in instructions)


def decode_instructions(instructions: bytes) -> typing.Iterator[Instruction]:
    errors = []
    for i, instruction in enumerate(chunk(instructions, 4)):
        try:
            decoded_instruction = Instruction.from_bytes(instruction)
        except DecodingError as exc:
            errors.append(f"[instruction {i}] {exc.args[0]})")
        else:
            if not errors:
                yield decoded_instruction
    if errors:
        raise DecodingError.collect_errors(errors)


# Which of the encoding types are valid for which instruction?

# Not the best place to put this, but it is only used in this module and
# methods that are called by this module

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
                f"No {cls.__name__.lower()} with encoding {value}"
            ) from None
