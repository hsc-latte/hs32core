# Processor
It's a processor

# CPU

- 32 bit
- flat address space, no MMU
- As simple as possible
- Should support running unmodified C programs.
- Required math ops: the usual AND OR NOT XOR shifts, rotates.
- Integer multiply and divide would be cool if we can fit it.
- Floating point math would be cool if we can fit it, including addition,mul,div operations

# Ports

- PS2 mouse, keyboard
- 4 Serial Ports (UART)
- Ethernet
- Display: Either VGA, NTSC, or DVI, or something like that.
- SD Card or Compactflash or something similar
- GPIOs, 8 would be nice.

# Memory

- use an external 16 or 32 bit ram Chip, likely SRAM for ease of use. Use several megabytes

# Target Silicon:

- 700nm process from ON Semi 
- 5 mm^2 of this tech: ON Semi 0.7µ C07M-D 2M/1P
- Silicon Fab price list: https://europractice-ic.com/wp-content/uploads/2020/07/General-MPW-EUROPRACTICE-200714-v11.pdf
- Packaging: https://europractice-ic.com/packaging-integration/standard-packaging/
- I would guess theres about 30000 to 8000 transistors per mm^2
- Therefor at 5mm^2, we have 150k to 40k transistors per chip. (it will be less due to the edge ring area being used for other stuff)
- It should be 4 transistors per gate
- so 37k to 10k gates per chip
- on-chip memory:
  - It looks like a CMOS SRAM cell has 6 transistors ... for 1 bit of storage.
  - If the entire die was made into SRAM we would therefore get 25kbit to 6.6kbit, or 3.2KB to .8KB
- The most basic ZPU (which is a tiny processor) calls for "about 1700 gates"
