# Instruction Set Architecture 

## Registers
(insert table here)

| Register | Designation | Size (Bits) | Alias |     Details    |
|:--------:|:-----------:|:-----------:|:-----:|:--------------:|
|    g0    |     0x00    |      32     |   NA  |       NA       |
|    g1    |     0x01    |      32     |   NA  |       NA       |
|    g2    |     0x02    |      32     |   NA  |       NA       |
|    g3    |     0x03    |      32     |   NA  |       NA       |
|    g4    |     0x04    |      32     |   NA  |       NA       |
|    g5    |     0x05    |      32     |   NA  |       NA       |
|    g6    |     0x06    |      32     |   NA  |       NA       |
|    g7    |     0x07    |      32     |   NA  |       NA       |
|    g8    |     0x08    |      32     |   NA  |       NA       |
|    g9    |     0x09    |      32     |   NA  |       NA       |
|    g10   |     0x0A    |      32     |   NA  |       NA       |
|    g11   |     0x0B    |      32     |   NA  |       NA       |
|    g12   |     0x0C    |      32     |   NA  |       NA       |
|    g13   |     0x0D    |      32     |   NA  |       NA       |
|    g14   |     0x0E    |      32     |   LR  | Return Address |
|    g15   |     0x0F    |      32     |   SP  |  Stack Pointer |

I think we need a dedicated register for Accumulator, Program Counter and Current Instruction Register?

## Instruction Listing
(insert table here)

|    Instructions   | OP Codes (HEX) |  OP Code Size (Bits) | Instruction Format | Instruction Example |   Assembly   |  Definition  |
|:-----------------:|:--------------:|:--------------------:|:------------------:|:-------------------:|:------------:|:------------:|
|    Read Memory    |      0x00      |          32          |    OP REG 0x0000   |   0x00 0x01 0x0000  |              |              |
|    Write Memory   |      0x10      |          32          |     OP REG DATA    |   0x10 0x01 0xDA7A  |              |              |
|     Read Flash    |      0x01      |          32          |    OP REG 0x0000   |   0x20 0x01 0x0000  |              |              |
|    Write Flash    |      0x11      |          32          |     OP REG DATA    |   0x30 0x01 0xDA7A  |              |              |
|    Read Serial    |      0x02      |          32          |    OP REG 0x0000   |   0x40 0x01 0x0000  |              |              |
|    Write Serial   |      0x12      |          32          |     OP REG DATA    |   0x50 0x01 0xDA7A  |              |              |
|   Call Function   |      0x60      |          32          |                    |                     |              |              |
| Conditional Jumps |      0x70      |          32          |                    |                     |              |              |
| Install Interrupt |      0x80      |          32          |                    |                     |              |              |
|  Handle Interrupt |      0x90      |          32          |                    |                     |              |              |
|        Loop       |      0xA0      |          32          |                    |                     |              |              |
|        Add        |      0xB0      |          32          |   OP REG REG REG   | 0xB0 0x01 0x02 0x03 | add g1 g2 g3 | g1 = g2 + g3 |
|     Substract     |      0xC0      |          32          |   OP REG REG REG   | 0xC0 0x01 0x02 0x03 | sub g1 g2 g3 | g1 = g2 - g3 |
|                   |      0xD0      |          32          |                    |                     |              |              |
|                   |      0xE0      |          32          |                    |                     |              |              |
|                   |      0xF0      |          32          |                    |                     |              |              |

## Instruction Encoding
Explain how instrucitions are encoded into "words".

I'm still thinking about it, these will have to be assembled into assembly before we can do anything...

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
