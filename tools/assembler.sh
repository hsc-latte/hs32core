#!/bin/sh

set -eu

echo "The docker image (which this uses) doesn't work right now. Once the assembler is in a working state, that will be fixed."
exit 0

docker run -v "$PWD":/assembler_context -w /assembler_context hsc_assembler "$@"
