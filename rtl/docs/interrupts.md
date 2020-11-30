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

## Types of Interrupts

This table support the following types of interrupts:

1. System Interrupts
2. Wishbone Interrupts
3. GPIO Interrupts - 10 GPIOs
4. Timer Interrupts - 1 Timer
5. Software Interrupts - 7 Interrupts
6. Privilege Violation

## System Interrupt Table (Non-Maskable)

| Interrupt Code | Interrupt Address | Details             |
| -------------- | ----------------- | ------------------- |
| 0x 00          | 0x 0000_0004      | Invalid             |
| 0x 01          | 0x 0000_0008      | Privilege Violation |

## Wishbone Interrupts

| Interrupt Code | Interrupt Address | Details |
| -------------- | ----------------- | ------- |
| 0x 02          | 0x 0000_000C      | Request |

## UART Interrupts

| Interrupt Code | Interrupt Address | Details |
| -------------- | ----------------- | ------- |
| 0x 03          | 0x 0000_0010      | UART Rx |

## GPIO Interrupts (8 GPIOs)

| Interrupt Code | Interrupt Address | Details |
| -------------- | ----------------- | ------- |
| 0x 04          | 0x 0000_0014      | GPIO 0  |
| 0x 05          | 0x 0000_0018      | GPIO 1  |
| 0x 06          | 0x 0000_001C      | GPIO 2  |
| 0x 07          | 0x 0000_0020      | GPIO 3  |
| 0x 08          | 0x 0000_0024      | GPIO 4  |
| 0x 09          | 0x 0000_0028      | GPIO 5  |
| 0x 0A          | 0x 0000_002C      | GPIO 6  |
| 0x 0B          | 0x 0000_0030      | GPIO 7  |

## Reserved (2 Reserved)

| Interrupt Code | Interrupt Address | Details  |
| -------------- | ----------------- | -------- |
| 0x 0C          | 0x 0000_0034      | Reserved |
| 0x 0D          | 0x 0000_0038      | Reserved |

## Timer Interrupts (3 Timers)

| Interrupt Code | Interrupt Address | Details       |
| -------------- | ----------------- | ------------- |
| 0x 0E          | 0x 0000_003C      | Timer 1 Match |
| 0x 0F          | 0x 0000_0040      | Timer 2 Match |
| 0x 10          | 0x 0000_0044      | Timer 3 Match |

## Software Interrupts (7 Available)

| Interrupt Code | Interrupt Address | Details              |
| -------------- | ----------------- | -------------------- |
| 0x 11          | 0x 0000_0048      | Software Interrupt 0 |
| 0x 12          | 0x 0000_004C      | Software Interrupt 1 |
| 0x 13          | 0x 0000_0050      | Software Interrupt 2 |
| 0x 14          | 0x 0000_0054      | Software Interrupt 3 |
| 0x 15          | 0x 0000_0058      | Software Interrupt 4 |
| 0x 16          | 0x 0000_005C      | Software Interrupt 5 |
| 0x 17          | 0x 0000_0060      | Software Interrupt 6 |