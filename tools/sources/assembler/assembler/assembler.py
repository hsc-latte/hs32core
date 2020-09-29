#!/usr/bin/env python3
import argparse
import os
import typing as tp
from parser import parse

from errors import ParseError, ScanError
from scanner import scan

Path = tp.Union[str, bytes, os.PathLike]
__all__ = ["assemble", "assemble_file", "cli"]


def assemble(assembly_code: str) -> bytes:
    tokens = scan(assembly_code)
    try:
        instructions = parse(tokens)
    # Error checking for the scanner is pushed here due to scan() being
    # a lazy generator
    except (ScanError, ParseError) as exc:
        exc.error_exit()
    import pprint

    pprint.pprint(instructions.instructions)
    pprint.pprint(instructions.symbol_table)
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
