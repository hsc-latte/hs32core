# CPU Datasheet

## Pinout (tentative)

| Pin #  | Name      | Description                         |
|--------|-----------|-------------------------------------|
| 0-15   | IO0-15    | 16-bit Data/Address Multiplexed Bus |
| 16     | ALE0      | Low bits Address Latch Enable       |
| 17     | ALE1      | High bits Address Latch Enable      |
| 18     | WE#       | Write Enable (Inverted)             |
| 19     | OE#       | Output Enable (Inverted)            |
| 20     | BHE#      | Data Bus High 8-bits (Inverted)     |
| 21     | -         | No-connect (placeholder)            |
| 22, 23 | RX, TX    | 9600 Baud UART Interface            |
| 24-... | GPIO0-... | General Purpose Input/Output        |

**Notes:**
- By adding an extra ALE3 (24-bit address bus) and/or ALE4 (32-bit address bus), 8 more bits can be saved from the IO pins
- The PIO pin is no-connect and is there for the possibility of peripheral interfaces
- If IRQ signals are required, each GPIO signal should generate an interrupt
- GPIO pins are all digital without PWM support. ADCs and IO expansions can be attached later to this or to the IO/data bus with the help of the PIO pin. Someone just has to work out the timing waveforms.

**Recommended Chips:**
- CY62147G variant for 4M (512x16) SRAM (55ns rw cycle)
- 74xx373/573 for address latches (as fast as 1ns tpd)
- 74xx245 for tristate bus buffers if needed
- Some I2C/SPI GPIO expansion
- Some ADC for analogue input (I'm not sure what to use)

---
## Timing Waveforms

Various timing diagrams of the address and data buses

### Read Cycle

Clock Cycles: 4 minimum

Timing Requirements:
- Read cycle begins on the leading edge of the 2nd clock period (on diagram) when the lo bits of the address is being clocked.
- The duration of the 3rd read clock (no data input) is determined by the `tpd` of whichever memory chip used

![](images/cpu-wave1.svg)

### Write Cycle

Clock Cycles: 4 minimum

Timing Requirements:
- Write cycle begins on the leading edge of the 2nd clock period (on diagram) when the lo bits of the address is being clocked.
- The duration of the 3rd write clock (write data output) is determined by the `tpd` of whichever memory chip used

![](images/cpu-wave2.svg)

### Peripheral IO Write Cycle

Clock Cycles: 4 minimum

Timing Requirements:
- External circuitry required for latching if timing requirements not met
- I have not managed to get this to work properly yet

![](images/cpu-wave3.svg)
