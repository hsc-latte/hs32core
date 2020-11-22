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
 * @file   tb_exec.v
 * @author Kevin Dai <kevindai02@outlook.com>
 * @date   Created on November 21 2020, 11:29 PM
 */

`ifdef SIM
`include "cpu/hs32_exec.v"
`include "soc/bram_ctl.v"

`timescale 1ns / 1ns
module tb_exec;
    parameter PERIOD = 2;

    reg clk = 0;
    reg [3:0]  aluop    = 4'b0010;
    reg [4:0]  shift    = 0;
    reg [15:0] imm      = 16'hABCD;
    reg [3:0]  rd       = 0;
    reg [3:0]  rm       = 1;
    reg [3:0]  rn       = 0;
    reg [15:0] ctlsig   = 16'b01_0_001_0000_000_000;
    reg [1:0]  bank     = 0;

    wire[31:0] addr, dtr, dtw;
    wire rw, valid, ready;

    always #(PERIOD/2) clk=~clk;

    initial begin
        $dumpfile("tb_exec.vcd");
        $dumpvars(0, exec);
        #(PERIOD*20);
        $finish;
    end

    hs32_exec exec(
        .clk(clk),
        .reset(0),
        .req(1),
        .rdy(),

        .flush(),
        .newpc(),

        .aluop(aluop),
        .shift(shift),
        .imm(imm),
        .rd(rd),
        .rm(rm),
        .rn(rn),
        .ctlsig(ctlsig),
        .bank(bank),

        .addr(addr),
        .dtrm(16'hCAFE),
        .dtwm(dtw),
        .reqm(valid),
        .rdym(ready),
        .rw_mem(rw),

        .intrq(0),
        .addi(0)
    );

     soc_bram_ctl #(
        .addr_width(8)
    ) bram_ctl(
        .clk(clk),
        .addr(addr[7:0]), .rw(rw),
        .dread(dtr), .dwrite(dtw),
        .valid(valid), .ready(ready)
    );
endmodule
`endif
