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
 * @file   mmio.v
 * @author Kevin Dai <kevindai02@outlook.com>
 * @date   Created on November 29 2020, 9:04 PM
 */

 `default_nettype none

module mmio(
    input wire clk,
    input wire reset,

    // Memory interface in
    input wire valid,
    output wire ready,
    input wire[31:0] addr,
    input wire[31:0] dtw,
    output wire[31:0] dtr,
    input wire rw,

    // SRAM Interface
    output wire sval,
    input wire srdy,
    output wire[31:0] saddr,
    output wire[31:0] sdtw,
    input wire[31:0] sdtr,
    output wire srw,

    // Interrupt controller
    input   wire[23:0] interrupts,  // Interrupt lines
    input   wire iack,              // Interrupt acknowledge
    output  wire[31:0] handler,     // ISR address
    output  wire intrq,             // Request interrupt
    output  wire[4:0] vec,          // Interrupt vector
    output  wire nmi                // Non maskable interrupt

    // TODO: Expose AICT Entries
    // (Input and output)
);
    parameter AICT_LENGTH = 25; // 24 IVT + 1 base

    // Advanced Interrupt Controller Table
    reg[31:0] aict[25:0];

    // Write ready
    reg wrdy;

    // AICT is from aict_base to aict_base + AICT_LENGTH*4
    wire is_aict;
    assign is_aict = aict[0] <= addr && addr <= aict[0] + AICT_LENGTH*4;

    // Calculate the aict index from the address
    wire[4:0] aict_idx;
    assign aict_idx = 5'((addr-aict[0]) >> 2);

    // Multiplex aict entry and sram signals
    // Ready is 1 only when reading
    assign ready = is_aict ? rw ? wrdy : 1 : srdy;
    assign dtr = is_aict ? aict[aict_idx] : sdtr;
    
    // Assign all sram output
    assign srw = rw;
    assign sval = valid && !is_aict;
    assign saddr = addr;
    assign sdtw = dtw;

    // Bus logic
    always @(posedge clk)
    if(reset)
        wrdy <= 0;
    else if(valid && rw)
        wrdy <= 1;
    else begin
        wrdy <= 0;
    end
endmodule
