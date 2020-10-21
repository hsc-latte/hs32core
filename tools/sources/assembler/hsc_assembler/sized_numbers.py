from __future__ import annotations

import typing

from hsc_assembler.parseable import Parseable

MAX_NUM = 0b111111111111111111111111


class OverflowError_(Exception):
    def __init__(self, number: int, max_size: int, type_name: str) -> None:
        message = (
            f"Number {number} is too large for type {type_name}. "
            f"Its max size is {max_size}."
        )
        super().__init__(message)


class UnderflowError(Exception):
    def __init__(self, number: int, type_name: str) -> None:
        super().__init__(
            f"Number {number} is too small (below zero) for type {type_name}."
        )


class PositiveSizedNumber(int):
    MAX: typing.ClassVar[int]

    def __new__(cls, *args, **kwargs):
        self = super().__new__(cls, *args, **kwargs)
        if self > self.MAX:
            raise OverflowError_(self, self.MAX, cls.__name__)
        if self < 0:
            raise UnderflowError(self, cls.__name__)
        return self

    def __repr__(self) -> str:
        return f"{type(self).__name__}({super().__repr__()})"

    def __str__(self) -> str:
        return super().__repr__()

    @classmethod
    def from_int(cls, value: int) -> PositiveSizedNumber:
        return cls(value)

    @classmethod
    def from_fields(
        cls, fields: typing.Dict[typing.Tuple[str, ...], int]
    ) -> PositiveSizedNumber:
        return cls(fields[()])

    asm_code = __str__


class Uint5(PositiveSizedNumber):
    MAX = 0b11111


class Uint8(PositiveSizedNumber):
    MAX = 0b11111111


class Uint16(PositiveSizedNumber, Parseable):
    MAX = 0b1111111111111111


class Uint24(PositiveSizedNumber, Parseable):
    MAX = 0b111111111111111111111111
