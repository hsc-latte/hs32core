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
 * @file   tb_sram.v
 * @author Anthony Kung <hi@anth.dev>
 * @author Kevin Dai <kevindai02@outlook.com>
 * @date   Created on November 01 2020, 12:40 AM
 */

`ifdef SIM
`define SRAM_LATCH_LAZY
`include "frontend/sram.v"
`timescale 1ns / 1ns
module tb_sram;
    parameter PERIOD = 2;
    
    reg clk = 0;
    reg reset = 1;

    reg valid = 1;
    reg rw = 0;
    reg[31:0] addri = 32'hAAAA_AAA1;
    reg[31:0] dtw = 32'hABCD_1234;
    
    wire[31:0] dtr;
    wire ready;

    always #(PERIOD/2) clk=~clk;

    initial begin
        $dumpfile("tb_sram.vcd");
        $dumpvars(0,sram);
    end

    initial begin
        #PERIOD
        reset <= 0;
        #(PERIOD*20)
        $finish;
    end
    
    ext_sram sram(
        .clk(clk),
        .reset(reset),
        .valid(valid),
        .ready(ready),
        .rw(rw),
        .addri(addri),
        .dtw(dtw),
        .dtr(dtr),
        .din(16'hABCD)
    );
endmodule
`endif
