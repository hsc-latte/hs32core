import argparse
import os
import typing as tp

import scanner

Path = tp.Union[str, bytes, os.PathLike]


def assemble(assembly_code: str) -> bytes:
    try:
        scanner.scan(assembly_code)
    except scanner.ScanError as exc:
        exc.error_exit()
    return b""


def assemble_file(source: Path, destination: Path):
    with open(source) as source_file:
        machine_code = assemble(source_file.read())
    with open(destination, "wb") as destination_file:
        destination_file.write(machine_code)


def cli():
    parser = argparse.ArgumentParser(description="Assembler for the risc666 ISA")
    parser.add_argument(
        "source", metavar="source", type=str, help="The path of the source file"
    )
    parser.add_argument(
        "destination",
        metavar="destination",
        type=str,
        help="The path of the destination file",
    )
    args = parser.parse_args()
    assemble_file(args.source, args.destination)


if __name__ == "__main__":
    cli()
