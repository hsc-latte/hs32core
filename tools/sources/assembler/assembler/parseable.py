from __future__ import annotations

import typing

if typing.TYPE_CHECKING:
    PT = typing.TypeVar("PT", bound="Parseable")
    from token_enums import Token


class Parseable:
    """ Implementation of the visitor GoF design pattern for the parse method """

    @classmethod
    def parse(
        cls: typing.Type[PT],
        tokens: typing.Union[typing.Sequence[Token], Token],
        line: int,
    ) -> PT:
        import parser

        if not isinstance(tokens, typing.Sequence):
            tokens = [tokens]
        func_name = f"parse_{cls.__name__}"
        return getattr(parser, func_name)(cls, tokens, line)
