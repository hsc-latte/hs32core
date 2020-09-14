# Instruction Set Architecture 

## Register File

| Register | Bits        | Alias |           Details          |
|:--------:|:-----------:|:-----:|:--------------------------:|
|    0     |      32     |   R0  |      General purpose       |
|    1     |      32     |   R1  |      General purpose       |
|    2     |      32     |   R2  |      General purpose       |
|    3     |      32     |   R3  |      General purpose       |
|    4     |      32     |   R4  |      General purpose       |
|    5     |      32     |   R5  |      General purpose       |
|    6     |      32     |   R6  |      General purpose       |
|    7     |      32     |   R7  |      General purpose       |
|    8     |      32     |   R8  |      General purpose       |
|    9     |      32     |   R9  |      General purpose       |
|    10    |      32     |   R10 |      General purpose       |
|    11    |      32     |   R11 |      General purpose       |
|    12    |      32     |   R12 |      General purpose       |
|    13    |      32     |   R13 |      General purpose       |
|    14    |      32     |   LR  |        Link register        |
|    15    |      32     |   SP  |        Stack Pointer       |

Internal registers: PC and NZCV flags. These are inaccessible to the programmer.

### Encoding

All possible encodings (depends on OP I guess, someone has to work that out).

| 8 bits | 4 bits | 4 bits | 16 bits |  |  |  |
|---|--------|----|-|-|-|-|-|
| OP | SRC | DST | IMM16 | | | |
| OP | FLAG| REG | 16-bit MASK | | | |
| OP | SRC | REG | REG | IMM12 | | |
| OP | SRC | DST | SRC | DST | SHIFT1 | SHIFT2|
| OP | SRC | DST | SRC | DST | SRC | DST|

dw anth baby i got this no flags needed

## Instruction Listing

This table contains the instruction code and the assembly code. The assembly code is mostly following INTEL SYNTAX with slight modifications for our purposes.

The low nibble is by row, the high nibble is by column. Together, the lo and hi nibbles form the opcode.

Legend:
- imm12/16/24 = 12/16/24-bit immediate valute
- list = any combination/list of registers
- Rs = source register, Rd = destination register, Ra, Rb... = Operand registers
- [xxx] = dereference pointer, address is stored in xxx

**I will specify flags that STM uses soon**

| Bank | Hi \| Lo -> | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | A | B | C | D | E | F |
|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|
| LOAD | 0 |  | list = [Rs]<br>`LDM list, Rs` | LDR Rd, [Rs + imm16] | Should we allowpost increment? |  |  |  |  |  |  |  |  |  |  |  |  |
| STORE | 1 |  | [Rd] = list<br>based on flags<br>`STM [flags] [Rd], list` | STR [Rd + imm16], Rs | Should we allowpost increment? |  |  |  |  |  |  |  |  |  |  |  |  |
| MOV | 2 | Move to lower word<br>MOV Rd, imm16 | Rd = Rs << s<br>MOV Rd, Rs << s | Vector move<br>(2 pairs with shift)<br>MOV Rd..., Rs... << s | Vector move<br>(3 pairs, no shift)<br>MOV Rd..., Rs... |  |  |  |  | Move to upper word<br>MOVT Rd, imm16 | etc… |  |  |  |  |  |  |
| BANK 3 | 3 |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| IO | 4 | IN | OUT |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| BRANCH | 5 | Branch and Link<br>B<cond>L (PC+imm24) | etc… |  |  |  |  |  |  | Branch<br>B<cond> (PC+imm24) | etc… |  |  |  |  |  |  |
| BANK 6 | 6 |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| ARITH | 7 | Rd = Ra + Rb + imm12<br>ADD Rd, Ra, Rb, imm12 | SUB Rd, Ra, Rb, imm12 | MUL Rd, Ra, Rb |  |  |  |  |  | ADDC Rd, Ra, Rb | etc… |  |  |  |  |  |  |
| LOGIC | 8 | AND (i got tired) | OR | NOT | XOR | SHL | SHR |  |  |  |  |  |  |  |  |  |  |
| BANK9 | 9 |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| BANK 10 | A | hehe vector arith and<br>logic would be so cool! |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| BANK 11 | B |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| BANK 12 | C |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| BANK 13 | D |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| BANK 14 | E |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| INT | 6 | INT (vector) |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |

Yes anth the kung I yeeted CPY.

### Memory

- 32 bits addresses
- no segment 
- big endian
- byte addressable + 32 bits == inc/dec by 4

load/store require splitting into two 16-bits and combined in a register to get full 32 bit address similar to LUI and ORI in MIPS

yes good boy someone understands

ignore everything below I haven't gotten to fixing below.

Example: Loading from address 0x6D5E4F3C

Assembly

```assembly
LMF g0 0x6D5E lmf = load muthaf*
LMS g0 0x4F3C
```

Machine Code
```
0x01006D5E
0x02004F3C
```

## Instruction Encoding


### Addressing Mode



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


