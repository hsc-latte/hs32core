#!/usr/bin/env python3

from enum import Enum


# This computer will have these memory mapped registers:
# 0 = PC
# 1 = SP

# but I didn't implement them. Only the program counter exists and its not memory mapped

class Memory(object):
    def __init__(self):
        self.storage = {}

    def __setitem__(self, addr, value):
        self.storage[addr] = value

    def __getitem__(self, addr):
        return self.storage.get(addr, 0)


Instruction = Enum('Instruction', 'mov literal add sub mul div mod inc dec jmp je jne jg jge print')

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
    Instruction.literal, 1, VAR_COUNTER,  # 0
    Instruction.inc, VAR_COUNTER,  # 3
    Instruction.print, VAR_COUNTER,  # 5
    Instruction.jmp, 3  # 7
]

PROGRAM_LIST_PRIME_NUMBERS = [
    Instruction.literal, 1, VAR_COUNTER,  # 0
    Instruction.literal, 0, VAR_ZERO,  # 3
    Instruction.inc, VAR_COUNTER,  # 6
    Instruction.literal, 2, VAR_COUNTER_INNER,  # 8
    Instruction.mod, VAR_COUNTER, VAR_COUNTER_INNER, VAR_MODULO_RESULT,  # 11
    Instruction.je, VAR_MODULO_RESULT, VAR_ZERO, 6,  # 15, jump to next candidate prime
    Instruction.inc, VAR_COUNTER_INNER,  # 19, increment factor
    Instruction.jge, VAR_COUNTER_INNER, VAR_COUNTER, 27,  # 21, This number is prime, go to print it
    Instruction.jmp, 11,  # 25, jump to next modulo test.
    Instruction.print, VAR_COUNTER,  # 27
    Instruction.jmp, 3  # 29, jump to next candidate prime
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
    instruction_code = readword()
    instruction = Instruction(instruction_code)
    # print('PC = {}, Got Instruction {}'.format(program_counter-1, instruction))
    if instruction == Instruction.mov:
        A = readword()
        B = readword()
        memory[B] = memory[A]
    elif instruction == Instruction.literal:
        VAL = readword()
        A = readword()
        memory[A] = VAL
    elif instruction == Instruction.add:
        A = readword()
        B = readword()
        C = readword()
        memory[C] = memory[A] + memory[B]  # TODO modulo
    elif instruction == Instruction.sub:
        A = readword()
        B = readword()
        C = readword()
        memory[C] = memory[A] - memory[B]  # TODO modulo
    elif instruction == Instruction.mul:
        A = readword()
        B = readword()
        C = readword()
        memory[C] = memory[A] * memory[B]  # TODO modulo
    elif instruction == Instruction.div:
        A = readword()
        B = readword()
        C = readword()
        memory[C] = int(memory[A] / memory[B])
    elif instruction == Instruction.mod:
        A = readword()
        B = readword()
        C = readword()
        memory[C] = int(memory[A] % memory[B])
    elif instruction == Instruction.inc:
        A = readword()
        memory[A] = memory[A] + 1  # TODO modulo
    elif instruction == Instruction.dec:
        A = readword()
        memory[A] = memory[A] - 1  # TODO modulo
    elif instruction == Instruction.jmp:
        POSITION = readword()
        program_counter = POSITION
    elif instruction == Instruction.je:
        A = readword()
        B = readword()
        POSITION = readword()
        A_val = memory[A]
        B_val = memory[B]
        if A_val == B_val:
            program_counter = POSITION
    elif instruction == Instruction.jne:
        A = readword()
        B = readword()
        POSITION = readword()
        A_val = memory[A]
        B_val = memory[B]
        if A_val != B_val:
            program_counter = POSITION
    elif instruction == Instruction.jg:
        A = readword()
        B = readword()
        POSITION = readword()
        A_val = memory[A]
        B_val = memory[B]
        if A_val > B_val:
            program_counter = POSITION
    elif instruction == Instruction.jge:
        A = readword()
        B = readword()
        POSITION = readword()
        A_val = memory[A]
        B_val = memory[B]
        if A_val >= B_val:
            program_counter = POSITION
    elif instruction == Instruction.print:
        A = readword()
        value = memory[A]
        print(value)
