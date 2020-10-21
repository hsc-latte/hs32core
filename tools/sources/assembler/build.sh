#!/bin/sh

set -eu

poetry build

# arg wheel should only be one file. This may be bad practice
docker build -t hsc_assembler . --build-arg wheel=$(find ./dist -type f -name hsc_assembler-*.whl)

