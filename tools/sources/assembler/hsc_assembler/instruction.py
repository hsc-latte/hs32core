from __future__ import annotations

import dataclasses
import enum
import itertools
import typing

from hsc_assembler.errors import DecodingError
from hsc_assembler.instruction_info import Instruction as InstructionEnum
from hsc_assembler.token_enums import Label
from hsc_assembler.utilities import chunk, getattributes

if typing.TYPE_CHECKING:
    from instruction_info import InstructionArgTypes, InstructionInfo
    from sized_numbers import Uint16


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
            for arg, arg_type in zip(args, instruction_type.value.types):
                assert isinstance(arg, tuple(arg_type))
        self.type = instruction_type
        self.args = args

    def __str__(self) -> str:
        arg_list = ", ".join(arg.asm_code() for arg in self.args)
        return f"{self.type.name} {arg_list}"

    def to_bytes(self, symbol_table: typing.Dict[Label, Uint16]) -> bytes:
        encoding: InstructionInfo = self.type.value.get_encoding(self.args)
        encoding_values = {}
        for encoding_slot, field_name in encoding.encoding_slots.items():
            value = getattributes(self.args[field_name.arg_index], *field_name.field)
            if isinstance(value, enum.Enum):
                value = value.value
            elif isinstance(value, Label):
                value = symbol_table[value]
            encoding_values[encoding_slot] = value
        temp = encoding.encoding_type.encoding_class(encoding.value, **encoding_values)
        if getattr(temp, "shift_type", 0) not in {0, 1}:
            breakpoint()
        return temp.to_bytes()

    @classmethod
    def from_bytes(cls, byte_op: bytes) -> Instruction:
        if len(byte_op) != 4:
            raise DecodingError(
                f"Instructions are of length 4, this is of length {len(byte_op)}", None
            )
        op_code = byte_op[0]
        instruction: InstructionInfo = InstructionEnum.from_int(op_code)
        instruction_info = instruction.value.get_encoding(op_code)
        encoding_class = instruction_info.encoding_type.encoding_class
        byte_instruction = encoding_class.from_buffer_copy(byte_op)
        fields_to_values = (
            {
                tuple(decoded_rep.field): getattr(byte_instruction, encoded_field)
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
            decoded_instruction = Instruction.from_bytes(bytes(instruction))
        except DecodingError as exc:
            errors.append(f"[instruction {i}] {exc.args[0]})")
        else:
            if not errors:
                yield decoded_instruction
    if errors:
        raise DecodingError.collect_errors(errors)
