#!/bin/sh

# TODO: Add a windows version of this script (powershell or cmd.exe).
# TODO: Add install prompt
set -eu

docker run -v "$PWD":/assembler/assembler_context -w /assembler/assembler_context hsc_assembler -- "$@"
