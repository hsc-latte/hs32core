#!/bin/sh

set -eu

docker run -v "$PWD":/assembler/assembler_context -w /assembler/assembler_context bolunthompson/hsc_assembler "$@"
