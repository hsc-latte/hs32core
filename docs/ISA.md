# Instruction Set Architecture 

## Registers
(insert table here)

| Register | Designation | Size (Bits) | Alias |     Details    |
|:--------:|:-----------:|:-----------:|:-----:|:--------------:|
|    g0    |     0x00    |      32     |   NA  |       NA       |
|    g1    |     0x10    |      32     |   NA  |       NA       |
|    g2    |     0x20    |      32     |   NA  |       NA       |
|    g3    |     0x30    |      32     |   NA  |       NA       |
|    g4    |     0x40    |      32     |   NA  |       NA       |
|    g5    |     0x50    |      32     |   NA  |       NA       |
|    g6    |     0x60    |      32     |   NA  |       NA       |
|    g7    |     0x70    |      32     |   NA  |       NA       |
|    g8    |     0x80    |      32     |   NA  |       NA       |
|    g9    |     0x90    |      32     |   NA  |       NA       |
|    g10   |     0xA0    |      32     |   NA  |       NA       |
|    g11   |     0xB0    |      32     |   NA  |       NA       |
|    g12   |     0xC0    |      32     |   NA  |       NA       |
|    g13   |     0xD0    |      32     |   NA  |       NA       |
|    g14   |     0xE0    |      32     |   LR  | Return Address |
|    g15   |     0xF0    |      32     |   SP  |  Stack Pointer |

### Structure

|  0x |     A    |   B  |
|:---:|:--------:|:----:|
| HEX | Register | Flag |

### Flags

I'm having second thoughts about the flags... It's kinda on the edge of CISC... I'm planning on making everything 1 byte so that its easier to work with but if we're not using the flags maybe we'll just give the extra 4 bits to op code or something.

## Instruction Listing
(insert table here)

My professor is a RISC guy so I'm a very RISC dude as well. I'm only taking ISA class next year so this is has been fun, I do appologise if this looks nothing like an ISA.

This table contains the instruction code and the assembly code. The assembly code is mostly following standard convention (or at least MIPS convention) with a slight mordification for our purposes. Empty cell represent unassigned instruction that we can add things to if needed.

| Description | LSB |                       |                             |                             |                 |                  |                   |                   |                    |                      |   |   |   |   |   |   |   |
|:-----------:|:---:|:---------------------:|:---------------------------:|:---------------------------:|:---------------:|:----------------:|:-----------------:|:-----------------:|:------------------:|:--------------------:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|
|  MSB/Prefix |  0  |           0           |              1              |              2              |        3        |         4        |         5         |         6         |          7         |           8          | 9 | A | B | C | D | E | F |
|     LOAD    |  0  |  LDR (Load Register)  |  LDM (Load memory 1st half) |  LDM (Load memory 2nd half) |                 |                  |                   |                   |                    |                      |   |   |   |   |   |   |   |
|    STORE    |  1  |  STR (store register) | STM (Store memory 1st half) | STM (Store memory 2nd half) |                 |                  |                   |                   |                    |                      |   |   |   |   |   |   |   |
|    INPUT    |  2  |          INB          |                             |                             |                 |                  |                   |                   |                    |                      |   |   |   |   |   |   |   |
|    OUTPUT   |  3  |          OUTB         |                             |                             |                 |                  |                   |                   |                    |                      |   |   |   |   |   |   |   |
|   FUNCTION  |  4  |          CPY          |             MOV             |                             |                 |                  |                   |                   |                    |                      |   |   |   |   |   |   |   |
|     JUMP    |  5  | BEQ (Branch if equal) |           J (Jump)          |                             |                 |                  |                   |                   |                    |                      |   |   |   |   |   |   |   |
|  INTERRUPT  |  6  |                       |                             |                             |                 |                  |                   |                   |                    |                      |   |   |   |   |   |   |   |
|     MATH    |  7  |          ADD          |             SUB             |       INC (Increment)       | DEC (Decrement) |                  |                   |                   |                    |                      |   |   |   |   |   |   |   |
|    LOGIC    |  8  |          AND          |              OR             |             NOT             |       XOR       | SHL (Shift left) | SHR (Shift right) | ROL (Rotate left) | ROR (Rotate right) | SLT (Set less than)  |   |   |   |   |   |   |   |
|             |  9  |                       |                             |                             |                 |                  |                   |                   |                    |                      |   |   |   |   |   |   |   |
|             |  A  |                       |                             |                             |                 |                  |                   |                   |                    |                      |   |   |   |   |   |   |   |
|             |  B  |                       |                             |                             |                 |                  |                   |                   |                    |                      |   |   |   |   |   |   |   |
|             |  C  |                       |                             |                             |                 |                  |                   |                   |                    |                      |   |   |   |   |   |   |   |
|             |  D  |                       |                             |                             |                 |                  |                   |                   |                    |                      |   |   |   |   |   |   |   |
|             |  E  |                       |                             |                             |                 |                  |                   |                   |                    |                      |   |   |   |   |   |   |   |
|             |  F  |                       |                             |                             |                 |                  |                   |                   |                    |                      |   |   |   |   |   |   |   |

For math and logic I'm not sure if we want unsigned as well, right now they are signed

### Addressing Mode

|  Type  |        Description       |
|:------:|:------------------------:|
| R-Type | Register Only Addressing |
| I-Type |   Immidiate Addressing   |
| J-Type |      Jump Addressing     |
|  Base  |      Base Addressing     |
| Pseudo |    Pseudo Instructions   |

|  Type  |     Prefix     | 1st Byte | 2nd Byte | 3rd Byte | 4th Byte |
|:------:|:--------------:|:--------:|:--------:|:--------:|:--------:|
| I-Type |  LOAD REGISTER |    OP    |    REG   |   0x00   |   0x00   |
| I-Type | WRITE REGISTER |    OP    |    REG   |   0xDA   |   0x7A   |
| I-Type |   LOAD MEMORY  |    OP    |    REG   |   0xAD   |   0xD0   |
| I-Type |  WRITE MEMORY  |    OP    |    REG   |   0xAD   |   0xD0   |
| R-Type |       CPY      |    OP    |    REG   |    REG   |   0x00   |
| R-Type |       MATH     |    OP    |    REG   |    REG   |    REG   |

### Memory

32 bits addresses no segments big endian byte addressable

## Instruction Encoding
Explain how instrucitions are encoded into "words".

4 bytes 32-bits fixed, see addressing mode

## Timing

Execution Time = (# of instructions)(cycles/instruction)(second/cycle)

By going with RISC we have a smaller number of instructions but complex operation will use more instructions

> The number of instructions also depends enormously on the cleverness of the programmer

Now we only need a few essential instructions, but we also include some special instructions that are useful in our case

## Examples of instrucion set usage
These are things we'll need to do

### Read from memory

### Write to memory

### Read from flash

### Write to flash

### Read and write to serial

### Call a function

### Conditional jumps

### Install an interrupt handler

### Handle an interrupt - such as: new serial byte available

### Basic loop - print numbers 1 to 10


# Notes and changes to make to the ISA
One general comment is that making most special features accessible as if they were memory - called memory mapping - tends to make the architecture clearer. 

One big thing missing seems to be “register-indirect” addressing. This is how pointers are implemented.
We need to read and write a memory location pointed to by a register

Here’s how I would like register indirect to be ideally:
- memory[base+index*size] = register (Writes to a memory location where base and index are registers. Size is part of the opcode, and it is one of: 1,2,4,8,16,32,64,128)

- register  = memory[base+index*size] (Writes to a memory location where base and index are registers. Size is part of the opcode, and it is one of: 1,2,4,8,16,32,64,128)

This allows efficient operations on arrays of items of varying sizes. 

We don’t need an accumulator register since we have all the general purpose registers

We should have an accessible program counter register that can be read/written by code.

Don’t need a current instruction register - that is internal to the CPU and can be hidden

Don’t need “”return address register” - this will get saved on the stack

“Read memory” should be called Load
“Write memory“ should be called Store

We don’t need separate instructions to read and write flash, They will be memory-mapped and look like regular RAM. The CPU will do this automatically

Read and write Serial should be made more generic - work with any IO port. We have SPI i2c and GPIO.

I don’t think we really necessarily need IO input output instructions — they can be memory mapped as well

Installing an interrupt handler should probably be memory mapped as well?

“Loop” is not really needed if you have conditional jumps

Most math operators are missing, although I think the structure looks good. We should also have AND OR NOT XOR shift-right shift-left rotate-left rotate-right. MUL and DIV can probably be skipped in V1

Increment and decrement instructions would be nice

Should we also have math instructions that can take 1 literal value in place of one of the register inputs?
Should we also have math instructions that overwrite the first register?

Should we have push and pop instructions for stack usage?
Should we have a PUSHALL instruction that pushes a bunch of registers to save the stack
