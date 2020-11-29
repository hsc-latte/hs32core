/**
 * Copyright (c) 2020 The HSC Core Authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     https://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * @file   hs32_interrupts.v
 * @author Anthony Kung <hi@anth.dev>
 * @author Kevin Dai <kevindai02@outlook.com>
 * @date   Created on November 28 2020, 4:21 PM
 */

module hs32_interrupts (
  // Operation
  input wire clk,
  input wire reset,

  // Interrupt
  input wire activate,                // Interrupt Activation (Enable)
  input wire [IVT_BITS-1:0] int,      // Interrupt Code

  // MMIO
  input wire [31:0] base,             // MMIO Base Location

  // Execute
  output reg intrq,                   // Interrupt Request
  output reg [31:0] addi              // Interrupt Address
);

  parameter IVT_BITS = 24;     // Interrupt Code Length

  always @(posedge clk) begin
    if (activate) begin
      case (int)
        // Invalid
        default: begin
          intrq <= 0;
          addi <= 32'h0000_0008 + base;
        end

        // Reset
        24'h000001: begin
          intrq <= 1;
          addi <= 32'h0000_0004 + base;
        end

        // Invalid
        24'h000002: begin
          intrq <= 1;
          addi <= 32'h0000_0008 + base;
        end

        // Wishbone Request
        24'h000004: begin
          intrq <= 1;
          addi <= 32'h0000_000C + base;
        end

        // GPIO 25
        24'h000008: begin
          intrq <= 1;
          addi <= 32'h0000_0010 + base;
        end

        // GPIO 26
        24'h000010: begin
          intrq <= 1;
          addi <= 32'h0000_0014 + base;
        end

        // GPIO 27
        24'h000020: begin
          intrq <= 1;
          addi <= 32'h0000_0018 + base;
        end

        // GPIO 28
        24'h000040: begin
          intrq <= 1;
          addi <= 32'h0000_001C + base;
        end

        // GPIO 29
        24'h000080: begin
          intrq <= 1;
          addi <= 32'h0000_0020 + base;
        end

        // GPIO 30
        24'h000100: begin
          intrq <= 1;
          addi <= 32'h0000_0024 + base;
        end

        // GPIO 31
        24'h000200: begin
          intrq <= 1;
          addi <= 32'h0000_0028 + base;
        end

        // GPIO 32
        24'h000400: begin
          intrq <= 1;
          addi <= 32'h0000_002C + base;
        end

        // GPIO 33
        24'h000800: begin
          intrq <= 1;
          addi <= 32'h0000_0030 + base;
        end

        // GPIO 34
        24'h001000: begin
          intrq <= 1;
          addi <= 32'h0000_0034 + base;
        end

        // Timer Reset
        24'h002000: begin
          intrq <= 1;
          addi <= 32'h0000_0038 + base;
        end

        // Timer Reached
        24'h004000: begin
          intrq <= 1;
          addi <= 32'h0000_003C + base;
        end

        // Timer Overflow
        24'h008000: begin
          intrq <= 1;
          addi <= 32'h0000_0040 + base;
        end

        // Software Interrupt 1
        24'h010000: begin
          intrq <= 1;
          addi <= 32'h0000_0044 + base;
        end

        // Software Interrupt 2
        24'h020000: begin
          intrq <= 1;
          addi <= 32'h0000_0048 + base;
        end

        // Software Interrupt 3
        24'h040000: begin
          intrq <= 1;
          addi <= 32'h0000_004C + base;
        end

        // Software Interrupt 4
        24'h080000: begin
          intrq <= 1;
          addi <= 32'h0000_0050 + base;
        end

        // Software Interrupt 5
        24'h100000: begin
          intrq <= 1;
          addi <= 32'h0000_0054 + base;
        end

        // Software Interrupt 6
        24'h200000: begin
          intrq <= 1;
          addi <= 32'h0000_0058 + base;
        end

        // Software Interrupt 7
        24'h400000: begin
          intrq <= 1;
          addi <= 32'h0000_005C + base;
        end

        // Privilege Violation
        24'h800000: begin
          intrq <= 1;
          addi <= 32'h0000_0060 + base;
        end
      endcase
    end
  end

endmodule