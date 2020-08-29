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
