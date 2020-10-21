from __future__ import annotations

import sys
import typing

T = typing.TypeVar("T")


def format_error(error_message: str, line: typing.Optional[int]) -> str:
    line_msg = f"[line: {line}] " if line is not None else ""
    return f"{line_msg}{error_message}"


def error_print(*args, **kwargs) -> None:
    print(*args, file=sys.stderr, **kwargs)


class AsmException(Exception):
    """ Base class for exceptions in this module """

    def __init__(self, message: str, line: typing.Optional[int], *args):
        super().__init__(format_error(message, line), *args)

    @classmethod
    def collect_errors(cls, errors: typing.Iterable[str]) -> AsmException:
        """ Collects multiple error messages into a single error """
        message = "\n".join(errors)
        return cls(message, None)

    # Code is EX_DATAERR, taken from here https://man.openbsd.org/sysexits.3
    def error_exit(self, code=65) -> typing.NoReturn:
        """ Prints the error then exits the program """
        error_print(self.args[0])
        sys.exit(code)


class ScanError(AsmException):
    pass


class ParseError(AsmException):
    pass


class DecodingError(AsmException):
    pass


def exception_chain(
    functions: typing.Iterable[typing.Callable[..., T]],
    exception: BaseException,
    *args: object,
    **kwargs: object,
) -> T:
    for function in functions:
        try:
            return function(*args, **kwargs)
        except type(exception):
            pass
    raise exception


def merge_exceptions(
    name, *bases: typing.Type[BaseException]
) -> typing.Type[BaseException]:
    return type(name, bases, {})
