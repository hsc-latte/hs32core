#!/usr/bin/env python3

from enum import Enum


class Memory(object):
    def __init__(self):
        self.storage = {}

    def __setitem__(self, addr, value):
        self.storage[addr] = value

    def __getitem__(self, addr):
        return self.storage.get(addr, 0)


class Opcode(Enum):
    LDR_IMM = 1  # Load from memory immed
    LDR = 2  # Load from memory
    STR_IMM = 3  # Store to memory immed
    STR = 4  # Store to memory
    MOV_IMM = 5 # Move immed
    MOV = 6 # Move reg-reg
    MOVT = 7 # Move to top word immed
    ADD = 8 # Add
    ADDC = 9 # Add with carry
    ADD_IMM = 10 # Add immed
    ADDC_IMM = 11 # Add with carry immed
    SUB = 12  # Sub
    SUBC = 13  # Sub with carry
    SUB_IMM = 14  # Sub immed
    SUBC_IMM = 15  # Sub with carry immed
    MUL = 16 # signed multiply
    AND = 17 # and
    AND_IMM = 18 # and immed
    OR = 19  # or
    OR_IMM = 20  # or immed
    XOR = 21  # xor
    XOR_IMM = 22  # xor immed
    NOT = 23 # not
    CMP = 24 # cmp
    CMP_IMM = 25 # cmp immed
    TST = 26 # test
    TST = 27 # test immed
    BRANCHL = 28 # Branch and link to PC+imm (TODO naming)
    BRANCH = 29 # Branch to PC+imm (TODO naming)
    INT = 30 # Invoke software interrupt


# Opcode = Enum('Opcode', 'mov literal add sub mul div mod inc dec jmp je jne jg jge print')

# argument size in words: what the op does
# 2: mov A -> B
# 2: literal VAL -> A
# 3: add A + B -> C
# 3: sub A - B -> C
# 3: mul A * B -> C
# 3: div A / B -> C
# 3: mod A % B -> C
# 1: inc A + 1 -> A
# 1: dec A - 1 -> A
# 1: jmp POSITION
# 3: je if A == B goto POSITION
# 3: jne if A != B goto POSITION
# 3: jg if A > B goto POSITION
# 3: jge if A >= B goto POSITION
# 1: print A

# writepointer mov A -> memory[B]
# readpointer memory[A] --> B

# Need to ensure you dont overwrite the code memory with variables!
# This is the task that assemblers do for you by createing code and data sections.
VAR_COUNTER = 100
VAR_COUNTER_INNER = 101
VAR_MODULO_RESULT = 102
VAR_ZERO = 103

PROGRAM_COUNT_UPWARDS = [
    Opcode.literal, 1, VAR_COUNTER,  # 0
    Opcode.inc, VAR_COUNTER,  # 3
    Opcode.print, VAR_COUNTER,  # 5
    Opcode.jmp, 3  # 7
]

PROGRAM_LIST_PRIME_NUMBERS = [
    Opcode.literal, 1, VAR_COUNTER,  # 0
    Opcode.literal, 0, VAR_ZERO,  # 3
    Opcode.inc, VAR_COUNTER,  # 6
    Opcode.literal, 2, VAR_COUNTER_INNER,  # 8
    Opcode.mod, VAR_COUNTER, VAR_COUNTER_INNER, VAR_MODULO_RESULT,  # 11
    Opcode.je, VAR_MODULO_RESULT, VAR_ZERO, 6,  # 15, jump to next candidate prime
    Opcode.inc, VAR_COUNTER_INNER,  # 19, increment factor
    Opcode.jge, VAR_COUNTER_INNER, VAR_COUNTER, 27,  # 21, This number is prime, go to print it
    Opcode.jmp, 11,  # 25, jump to next modulo test.
    Opcode.print, VAR_COUNTER,  # 27
    Opcode.jmp, 3  # 29, jump to next candidate prime
]

program = PROGRAM_LIST_PRIME_NUMBERS

memory = Memory()
# load the program into memory
for i in range(len(program)):
    memory[i] = program[i]

program_counter = 0


def readword():
    global program_counter
    val = memory[program_counter]
    program_counter += 1
    return val


while True:
    Opcode_code = readword()
    Opcode = Opcode(Opcode_code)
    # print('PC = {}, Got Opcode {}'.format(program_counter-1, Opcode))
    if Opcode == Opcode.mov:
        A = readword()
        B = readword()
        memory[B] = memory[A]
    elif Opcode == Opcode.literal:
        VAL = readword()
        A = readword()
        memory[A] = VAL
    elif Opcode == Opcode.add:
        A = readword()
        B = readword()
        C = readword()
        memory[C] = memory[A] + memory[B]  # TODO modulo
    elif Opcode == Opcode.sub:
        A = readword()
        B = readword()
        C = readword()
        memory[C] = memory[A] - memory[B]  # TODO modulo
    elif Opcode == Opcode.mul:
        A = readword()
        B = readword()
        C = readword()
        memory[C] = memory[A] * memory[B]  # TODO modulo
    elif Opcode == Opcode.div:
        A = readword()
        B = readword()
        C = readword()
        memory[C] = int(memory[A] / memory[B])
    elif Opcode == Opcode.mod:
        A = readword()
        B = readword()
        C = readword()
        memory[C] = int(memory[A] % memory[B])
    elif Opcode == Opcode.inc:
        A = readword()
        memory[A] = memory[A] + 1  # TODO modulo
    elif Opcode == Opcode.dec:
        A = readword()
        memory[A] = memory[A] - 1  # TODO modulo
    elif Opcode == Opcode.jmp:
        POSITION = readword()
        program_counter = POSITION
    elif Opcode == Opcode.je:
        A = readword()
        B = readword()
        POSITION = readword()
        A_val = memory[A]
        B_val = memory[B]
        if A_val == B_val:
            program_counter = POSITION
    elif Opcode == Opcode.jne:
        A = readword()
        B = readword()
        POSITION = readword()
        A_val = memory[A]
        B_val = memory[B]
        if A_val != B_val:
            program_counter = POSITION
    elif Opcode == Opcode.jg:
        A = readword()
        B = readword()
        POSITION = readword()
        A_val = memory[A]
        B_val = memory[B]
        if A_val > B_val:
            program_counter = POSITION
    elif Opcode == Opcode.jge:
        A = readword()
        B = readword()
        POSITION = readword()
        A_val = memory[A]
        B_val = memory[B]
        if A_val >= B_val:
            program_counter = POSITION
    elif Opcode == Opcode.print:
        A = readword()
        value = memory[A]
        print(value)
