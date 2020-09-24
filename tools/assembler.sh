#!/bin/sh

set -eu

docker run -v "$PWD":/assembler_context -w /assembler_context hsc_assembler "$@"
