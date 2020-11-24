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
 * @file   main.v
 * @author Kevin Dai <kevindai02@outlook.com>
 * @date   Created on October 29 2020, 6:15 PM
 */

`include "cpu/hs32_cpu.v"
`include "soc/bram_ctl.v"

module main (
    input   wire CLK,
    input   wire RX,
    output  wire TX,
    output  wire LEDR_N,
    output  wire LEDG_N
);
    wire[31:0] addr, dread, dwrite;
    wire rw, valid, ready;
    reg por, state;
    initial por = 0;
    initial state = 0;

    always @(posedge CLK) begin
        if(!state) begin
            por <= 1;
            state <= 1;
        end
        else por <= 0;
    end

    hs32_cpu cpu(
        .clk(CLK), .reset(por),
        // External interface
        .addr(addr), .rw(rw),
        .din(dread), .dout(dwrite),
        .valid(valid), .ready(ready)
    );
    soc_bram_ctl #(
        .addr_width(8)
    ) bram_ctl(
        .clk(CLK),
        .addr(addr[7:0]), .rw(rw),
        .dread(dread), .dwrite(dwrite),
        .valid(valid), .ready(ready)
    );
endmodule