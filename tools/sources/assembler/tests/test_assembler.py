# TODO: Add tests

# TODO: Fix import issues. This doesn't run right now
import hsc_assembler


def test_assembler():
    with open("tests/test.asm") as f:
        code = f.read()
    hsc_assembler.assemble(code)
