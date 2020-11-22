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
 * @file   bram.v
 * @author Kevin Dai <kevindai02@outlook.com>
 * @date   Created on October 26 2020, 7:12 PM
 */

module soc_bram (
    input clk,
    input we,
    input wire [addr_width-1:0] addr,
    input wire [data_width-1:0] din,
    output reg [data_width-1:0] dout
);
    parameter addr_width = 8;
    parameter data_width = 8;

    reg[data_width-1:0] mem[(1<<addr_width)-1:0];
    
    integer i;
    initial begin
        for(i = 0; i < (1<<addr_width); i++)
            mem[i] = 0;
    end

    always @(posedge clk) begin
        if(we) begin
            mem[addr] <= din;
        end else begin
            dout <= mem[addr];
        end
    end
endmodule