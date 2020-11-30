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
 * @file   tb_decode_exec.v
 * @author Kevin Dai <kevindai02@outlook.com>
 * @date   Created on November 23 2020, 10:26 PM
 */

`define IMUL
`define BARREL_SHIFTER

`ifdef SIM
`include "cpu/hs32_aluops.v"
`include "cpu/hs32_exec.v"
`include "cpu/hs32_decode.v"
`include "soc/bram_ctl.v"

`timescale 1ns / 1ns
module tb_decode;
    parameter PERIOD = 2;

    reg[31:0] instd = 32'h4200_1000;

    reg clk = 0;
    reg reset = 1;
    wire reqe, rdye;
    wire [3:0]  aluop ;
    wire [4:0]  shift ;
    wire [15:0] imm   ;
    wire [3:0]  rd    ;
    wire [3:0]  rm    ;
    wire [3:0]  rn    ;
    wire [15:0] ctlsig;
    wire [1:0]  bank  ;

    wire[31:0] addr, dtw;
    reg [31:0] dtr = 32'hCAFEBABE;
    wire rw, valid;
    reg ready = 1;

    always #(PERIOD/2) clk=~clk;

    initial begin
        $dumpfile("tb_exec_decode.vcd");
        $dumpvars(0, decode, exec);
        // Initialize some registers
        exec.regfile_s.regs[0] = 32'h6;
        exec.regfile_s.regs[1] = 32'h2;

        // Power on reset, no touchy >:[
        #PERIOD
        reset <= 0;
        exec.pc_s = 32'h0000_1000;
        #(PERIOD*20);
        $finish;
    end

    hs32_exec exec(
        .clk(clk),
        .reset(reset),
        .req(reqe),
        .rdy(rdye),

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
        .dtrm(32'hCAFE),
        .dtwm(dtw),
        .reqm(valid),
        .rdym(ready),
        .rw_mem(rw),

        .intrq(1'b0),
        .isr(0)
    );

    hs32_decode decode(
        .clk(clk),
        .reset(reset),
        .instf(instd),
        .reqd(),
        .rdyd(1'b1),
        .aluop(aluop),
        .shift(shift),
        .imm(imm),
        .rd(rd),
        .rm(rm),
        .rn(rn),
        .bank(bank),
        .ctlsig(ctlsig),
        .reqe(reqe),
        .rdye(rdye)
    );

    /*soc_bram_ctl #(
        .addr_width(8)
    ) bram_ctl(
        .clk(clk),
        .addr(addr[7:0]), .rw(rw),
        .dread(dtr), .dwrite(dtw),
        .valid(valid), .ready(ready)
    );*/
endmodule
`endif
