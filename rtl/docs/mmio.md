# Memory Mapped I/O

The MMIO is a 32 bit address memory space

## Types

The MMIO consists of the follow types:

1. Base
2. Interrupts
3. Wishbone
4. GPIO
5. Timer

## Base

| Where          | What          |
| -------------- | ------------- |
| Base + 0x 0000 | Base Location |

## Interrupts

| Where          | What           |
| -------------- | -------------- |
| Base + 0x 0004 | Interrupt 0x00 |
| Base + 0x 0008 | Interrupt 0x01 |
| Base + 0x 000C | Interrupt 0x02 |
| Base + 0x 0010 | Interrupt 0x03 |
| Base + 0x 0014 | Interrupt 0x04 |
| Base + 0x 0018 | Interrupt 0x05 |
| Base + 0x 001C | Interrupt 0x06 |
| Base + 0x 0020 | Interrupt 0x07 |
| Base + 0x 0024 | Interrupt 0x08 |
| Base + 0x 0028 | Interrupt 0x09 |
| Base + 0x 002C | Interrupt 0x0A |
| Base + 0x 0030 | Interrupt 0x0B |
| Base + 0x 0034 | Interrupt 0x0C |
| Base + 0x 0038 | Interrupt 0x0D |
| Base + 0x 003C | Interrupt 0x0E |
| Base + 0x 0040 | Interrupt 0x0F |
| Base + 0x 0044 | Interrupt 0x10 |
| Base + 0x 0048 | Interrupt 0x11 |
| Base + 0x 004C | Interrupt 0x12 |
| Base + 0x 0050 | Interrupt 0x13 |
| Base + 0x 0054 | Interrupt 0x14 |
| Base + 0x 0058 | Interrupt 0x15 |
| Base + 0x 005C | Interrupt 0x16 |
| Base + 0x 0060 | Interrupt 0x17 |