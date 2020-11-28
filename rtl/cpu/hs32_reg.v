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
 * @file   hs32_reg.v
 * @author Anthony Kung <hi@anth.dev>
 * @author Kevin Dai <kevindai02@outlook.com>
 * @date   Created on October 24 2020, 11:35 PM
 */

`default_nettype none

// Dual-Port Register File

module hs32_reg (
    input clk,                  // 12 MHz Clock
    input reset,                // Reset

    // Register Control
    input we,                   // Write enable
    input wire [3:0]    wadr,   // Write address
    input wire [31:0]   din,    // Write data
    input wire [3:0]    radr1,  // Read address 1
    output reg [31:0]   dout1,  // Read data 1
    input wire [3:0]    radr2,  // Read address 2
    output reg [31:0]   dout2   // Read data 2
);
    parameter addr_width = 4;
    parameter data_width = 32;

    reg[data_width-1:0] regs[(1<<addr_width)-1:0];

`ifdef SIM
    integer i;
    initial begin
        for(i = 0; i < (1<<addr_width); i++)
            $dumpvars(1, regs[i]);
    end
`endif

    always @(posedge clk) if(we) begin
        regs[wadr] <= din;
    end

    always @(posedge clk) if(!we) begin
        dout1 <= regs[radr1];
        dout2 <= regs[radr2];
    end
endmodule
