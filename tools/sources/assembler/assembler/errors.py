import sys
import typing


def format_error(error_message: str, line: typing.Optional[int]) -> str:
    line_msg = f"[line: {line}] " if line is not None else ""
    return f"{line_msg}{error_message}"


def error_print(*args, **kwargs) -> None:
    print(*args, file=sys.stderr, **kwargs)
