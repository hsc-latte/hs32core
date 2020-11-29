<!--
 - Copyright (c) 2020 The HSC Core Authors
 -
 - Licensed under the Apache License, Version 2.0 (the "License");
 - you may not use this file except in compliance with the License.
 - You may obtain a copy of the License at
 -
 -     https://www.apache.org/licenses/LICENSE-2.0
 -
 - Unless required by applicable law or agreed to in writing, software
 - distributed under the License is distributed on an "AS IS" BASIS,
 - WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 - See the License for the specific language governing permissions and
 - limitations under the License.
 -
 - @file   interrupts.md
 - @author Anthony Kung <hi@anth.dev>
 - @author Kevin Dai <kevindai02@outlook.com>
 - @date   Created on November 28 2020
 -->

# Interrupts

The interrupt bus consists of 24 wires, each corresponds to an interrupt.

Interrupt Address is mapped to MMIO addresses along with other MMIOs.

This table starts from wire [0] at 0000 0000 0000 0000 0000 0001 to
wire [23] at 1000 0000 0000 0000 0000 0000 and is represented in
hexadecimal for our conveniences.

## Types of Interrupts

This table support the following types of interrupts:

1. System Interrupts
2. Wishbone Interrupts
3. GPIO Interrupts - 10 GPIOs
4. Timer Interrupts - 1 Timer
5. Software Interrupts - 7 Interrupts
6. Privilege Violation

## System Interrupt Table

| Interrupt Code | Interrupt Address | Details |
| -------------- | ----------------- | ------- |
| 0x 000001      | 0x 0000_0004      | Reset   |
| 0x 000002      | 0x 0000_0008      | Invalid |

## Wishbone Interrupts

| Interrupt Code | Interrupt Address | Details |
| -------------- | ----------------- | ------- |
| 0x 000004      | 0x 0000_000C      | Request |

## GPIO Interrupts (10 GPIOs)

| Interrupt Code | Interrupt Address | Details |
| -------------- | ----------------- | ------- |
| 0x 000008      | 0x 0000_0010      | GPIO 25 |
| 0x 000010      | 0x 0000_0014      | GPIO 26 |
| 0x 000020      | 0x 0000_0018      | GPIO 27 |
| 0x 000040      | 0x 0000_001C      | GPIO 28 |
| 0x 000080      | 0x 0000_0020      | GPIO 29 |
| 0x 000100      | 0x 0000_0024      | GPIO 30 |
| 0x 000200      | 0x 0000_0028      | GPIO 31 |
| 0x 000400      | 0x 0000_002C      | GPIO 32 |
| 0x 000800      | 0x 0000_0030      | GPIO 33 |
| 0x 001000      | 0x 0000_0034      | GPIO 34 |

## Timer Interrupts (1 Timer)

| Interrupt Code | Interrupt Address | Details          |
| -------------- | ----------------- | ---------------- |
| 0x 002000      | 0x 0000_0038      | Timer Reset      |
| 0x 004000      | 0x 0000_003C      | Timer 1 Reached  |
| 0x 008000      | 0x 0000_0040      | Timer 1 Overflow |

## Software Interrupts (7 Available)

| Interrupt Code | Interrupt Address | Details              |
| -------------- | ----------------- | -------------------- |
| 0x 010000      | 0x 0000_0044      | Software Interrupt 1 |
| 0x 020000      | 0x 0000_0048      | Software Interrupt 2 |
| 0x 040000      | 0x 0000_004C      | Software Interrupt 3 |
| 0x 080000      | 0x 0000_0050      | Software Interrupt 4 |
| 0x 100000      | 0x 0000_0054      | Software Interrupt 5 |
| 0x 200000      | 0x 0000_0058      | Software Interrupt 6 |
| 0x 400000      | 0x 0000_005C      | Software Interrupt 7 |

## Privilege Violation

| Interrupt Code | Interrupt Address | Details             |
| -------------- | ----------------- | ------------------- |
| 0x 800000      | 0x 0000_0060      | Privilege Violation |