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

    // Check if there's interrupt(s)
    assign intrq = |interrupts && ~iack;

    // NMI
    assign nmi = interrupts[0] ||interrupts[1];

    // Interrupt Priority
    // LSB gets higher priority
    always @(*) begin
        if (interrupts[0])
            vec = 5'd0;
        else if (interrupts[1])
            vec = 5'd1;
        else if (interrupts[2])
            vec = 5'd2;
        else if (interrupts[3])
            vec = 5'd3;
        else if (interrupts[4])
            vec = 5'd4;
        else if (interrupts[5])
            vec = 5'd5;
        else if (interrupts[6])
            vec = 5'd6;
        else if (interrupts[7])
            vec = 5'd7;
        else if (interrupts[8])
            vec = 5'd8;
        else if (interrupts[9])
            vec = 5'd9;
        else if (interrupts[10])
            vec = 5'd10;
        else if (interrupts[11])
            vec = 5'd11;
        else if (interrupts[12])
            vec = 5'd12;
        else if (interrupts[13])
            vec = 5'd13;
        else if (interrupts[14])
            vec = 5'd14;
        else if (interrupts[15])
            vec = 5'd15;
        else if (interrupts[16])
            vec = 5'd16;
        else if (interrupts[17])
            vec = 5'd17;
        else if (interrupts[18])
            vec = 5'd18;
        else if (interrupts[19])
            vec = 5'd19;
        else if (interrupts[20])
            vec = 5'd20;
        else if (interrupts[21])
            vec = 5'd21;
        else if (interrupts[22])
            vec = 5'd22;
        else if (interrupts[23])
            vec = 5'd23;
    end

    assign handler = aict[vec + 1];

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
