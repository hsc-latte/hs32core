# Processor

Open Source Hardware Processor
![silicon die photo](/images/silicon.jpg)

# Project Goals

## Processor V1 (November 2020)
1. Create a new CPU instruction set and design.
    - it should be a sort of minimum viable 32 bit CPU. Something similar in capability to an Arduino, and with similar ports.
2. Test the CPU design in simulators and on FPGA
3. Fabricate the processor using Google and efabless free shuttle service for open source using 130nm process, and open source PDK
    - Submit a design for the November free shuttle run.
    - Try not to go too crazy with transistor count. We want to not be dependent on free fabrication in the future.
4. Make an Arduino-like board for the processor, with similar capabilities and supporting software

**Fun Side Project for V1** : Make an Apple II or commodore style standalone PC using the processsor.

## Processor V2 (Early 2021)
1. Replicate V1 using non-donated fabrication and make the process economically sustainable.
    - This means making chips and boards than people can actually buy.
    - See Target Silicon section below.
    - In theory, multi project wafer runs on very old tech could be < $100 per chip. Costs will go down as volume increases.
    - we could do a Kickstarter or similar to fund a larger fabrication run for V2.
2. Expand capabilities
    - more RAM, faster RAM
    - graphics framebuffer
    - more ports in general.

## Processor V3 (Late 2021)
While maintaining economic sustainability:
1. Expand capabilities
    - add MMU (ucLinux will run without an MMU, but typical programs will not run. They require fork() and mmap() among other MMU features.)
    - hardware floating point
    - more RAM, faster RAM
    - more ports in general. HDMI, ethernet, possibly USB and WiFi to some degree, with external chips
3. Make a raspberry-Pi style board. It would be much much slower than a Pi, but should have a similar style of capabilities and functions.
3. Explore Linux support

## Processor V4 (2022)
Generally more powerful and unique. Try to achieve some interoperability with modern hardware, yet remain fully open source.
Just some ideas:
- On-chip Software Defined Radio (SDR) so that it can be a flexible radio device (WiFi, LTE, Bluetooth, GPS)
- GPU
- Multi core
- PCIE Root Controller
- DDR4 Controller
- USB3 Controller

# Task List
- Get VLSI design tools running in Docker and document usage on various operating systems.
- Replicate this using their design and same tooling: https://content.riscv.org/wp-content/uploads/2017/12/Wed-1142-RISCV-Tim-Edwards.pdf
- Get prototyping FPGA hardware and needed tools into people's hands
  - this board looks like the most promising one https://www.olimex.com/Products/FPGA/iCE40/iCE40HX8K-EVB/open-source-hardware
- Prepare reading list for newcomers to computer engineering
  - started here: [link](Resources.md)
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
  - https://opencores.org/projects/ps2
- 4 Serial Ports (UART)
  - https://opencores.org/projects/uart16550
  - https://opencores.org/projects/uart
- Ethernet
  - https://webcache.googleusercontent.com/search?q=cache:brylkvkD1N4J:https://opencores.org/projects/ethmac+&cd=1&hl=en&ct=clnk&gl=us
  - oops! ethernet may require too many gates.
  - We can cheat a little by using this chip which offloads most of the harder networking work and you just need to talk to it over SPI.
   - https://wizwiki.net/wiki/lib/exe/fetch.php?media=products:w5100s:w5100s_ds_v100e.pdf
   - in fact it does TCP and UDP for you!
- Display: Either VGA, NTSC, or DVI, or something like that.
  - ntsc https://webcache.googleusercontent.com/search?q=cache:4BF235L2FPcJ:https://opencores.org/projects/fbas_encoder+&cd=1&hl=en&ct=clnk&gl=us
  - https://webcache.googleusercontent.com/search?q=cache:uBfl2FENLigJ:https://opencores.org/projects/yavga+&cd=2&hl=en&ct=clnk&gl=us
  - really not sure if we can do video out without a framebuffer, and then if we can get fast enough external RAM to use as a framebuffer.
  - possible expensive memory chip: https://www.digikey.com/product-detail/en/renesas-electronics-america-inc/70V28L20PFGI/800-2108-ND/2010195
   - it is dual port so it can simultaneous read and write (great for framebuffers)
   - asynchronous SRAM
   - parallel addr/data bus, 16 bit
   - full speed should be 50Mhz @ 16 bit accesses
   - The VGA core has a 50Mhz pixel clock so it should be possible to do color at 800x600!
- SD Card or Compactflash or something similar
- GPIOs, 8 would be nice.
- If we want we can add a USB host using an external chip https://www.hobbytronics.co.uk/usb-host-dip

# Memory

- use an external 16 or 32 bit ram Chip, likely SRAM for ease of use. Use several megabytes

# Target Silicon:
- Silicon price list exploration: https://docs.google.com/spreadsheets/d/1oqIo1lJNRx8SugjHd8WOBk07iPeCCzOLdnaOR9BBdXU/edit#gid=0
- 700nm process from ON Semi 
- 5 mm^2 of this tech: ON Semi 0.7µ C07M-D 2M/1P
- Silicon Fab price list: https://europractice-ic.com/wp-content/uploads/2020/07/General-MPW-EUROPRACTICE-200714-v11.pdf
- Packaging: https://europractice-ic.com/packaging-integration/standard-packaging/
- Bond pad design for wirebonding https://europractice-ic.com/wp-content/uploads/2020/06/ASIC-Package-Design-Rules-10062020.pdf
- How many pins can the processor have? chip side length/distance between pads: sqrt(5mm^2) / 65um = 34. To be conservative, round to 30 pads per side. Therefore, estimate maximum 120 total pins for the entire chip. Ceramic quad flat pack (QFP) is available with that many pins from europractice.
- How much of the die area is dedicated to wire bonding pads? Assume bond pad is 60um. 4 * 60um * sqrt(5mm^2) = .536 mm^2
  - Therefore approximately 10% of the die ares is wire bonding pads. Not too bad.
- I would guess theres about 30000 to 8000 transistors per mm^2
- Therefore at 5mm^2, we have 150k to 40k transistors per chip. (it will be less due to the edge ring area being used for other stuff)
- It should be 4 transistors per gate
- so 37k to 10k gates per chip
- on-chip memory:
  - It looks like a CMOS SRAM cell has 6 transistors ... for 1 bit of storage.
  - If the entire die was made into SRAM we would therefore get 25kbit to 6.6kbit, or 3.2KB to .8KB
- The most basic ZPU (which is a tiny processor) calls for "about 1700 gates"


# Interesting Tools

- A Python toolbox for building complex digital hardware https://github.com/m-labs/migen
- Generates a custom CPU based on C code tailored to your code https://github.com/dawsonjon/Chips-2.0
- Open Source VLSI toolbox http://opencircuitdesign.com/magic/
- EDAlyze - python scripting of EDA tools https://github.com/olofk/edalize
- Package manager for IP cores https://github.com/olofk/fusesoc
- *** OpenLane - fully automated RTL to ASIC flow. https://github.com/efabless/openlane
- APIO - open ecosystem for FPGA boards https://github.com/FPGAwars/apio
- 130nm process design kit (PDK) from skywater https://github.com/google/skywater-pdk

# License 

- GPL v3
