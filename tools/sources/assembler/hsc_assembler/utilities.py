import typing

T = typing.TypeVar("T")


def chunk(iterable: typing.Iterable[T], size: int) -> typing.Iterator[typing.List[T]]:
    group = []
    for item in iterable:
        group.append(item)
        if len(group) == size:
            yield group
            group = []
    if group:
        message = (
            "Extra data in iterable; Iterable cannot split into "
            f"chunks of size {size} without extra data."
        )
        raise ValueError(message)


def getattributes(obj: object, *fields: str) -> object:
    for field in fields:
        obj = getattr(obj, field)
    return obj
