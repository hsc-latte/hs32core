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
 * @file   hs32_cpu.v
 * @author Anthony Kung <hi@anth.dev>
 * @author Kevin Dai <kevindai02@outlook.com>
 * @date   Created on October 23 2020, 1:36 AM
 */

`default_nettype none

`include "cpu/hs32_mem.v"
`include "cpu/hs32_fetch.v"
`include "cpu/hs32_exec.v"
`include "cpu/hs32_decode.v"

// NO LATCHES ALLOWED!
module hs32_cpu (
    input wire i_clk,
    input wire reset,

    // External interface
    output  wire [31:0] addr,
    output  wire rw,
    input   wire[31:0] din,
    output  wire[31:0] dout,
    output  wire valid,
    input   wire ready,

    // Interrupt controller
    output  wire[23:0] interrupts,  // Interrupt lines
    output  wire iack,              // Interrupt acknowledge
    input   wire[31:0] handler,     // ISR address
    input   wire intrq,             // Request interrupt
    input   wire[4:0] vec,          // Interrupt vector
    input   wire nmi                // Non maskable interrupt
);
    parameter PREFETCH_SIZE = 3; // Depth of 2^PREFETCH_SIZE instructions

    wire flush;
    wire[31:0] newpc;

    wire[31:0] addr_e, dtr_e, dtw_e;
    wire req_e, rdy_e, rw_e;

    wire[31:0] addr_f, dtr_f;
    wire req_f, rdy_f;
    hs32_mem MEM(
        // External interface
        .addr(addr), .rw(rw), .din(din), .dout(dout),
        .valid(valid), .ready(ready),
        
        // Channel 0 (Execute)
        .addr0(addr_e), .dtr0(dtr_e), .dtw0(dtw_e),
        .rw0(rw_e), .req0(req_e), .rdy0(rdy_e),

        // Channel 1 (Fetch)
        .addr1(addr_f), .dtr1(dtr_f), .dtw1(0),
        .rw1(0), .req1(req_f), .rdy1(rdy_f)
    );

    wire[31:0] inst_d;
    wire req_d, rdy_d;
    hs32_fetch #(
        .PREFETCH_SIZE(PREFETCH_SIZE)
    ) FETCH(
        .clk(i_clk),
        // Memory arbiter interface
        .addr(addr_f), .dtr(dtr_f), .reqm(req_f), .rdym(rdy_f),
        // Decode
        .instd(inst_d), .reqd(req_d), .rdyd(rdy_d),
        // Pipeline controller
        .newpc(newpc), .flush(flush | reset)
    );

    wire [3:0]  aluop_e;
    wire [4:0]  shift_e;
    wire [15:0] imm_e;
    wire [3:0]  regdst_e;
    wire [3:0]  regsrc_e;
    wire [3:0]  regopd_e;
    wire [1:0]  bank_e;
    wire [15:0] ctlsig_e;
    hs32_decode DECODE(
        .clk(i_clk), .reset(reset | flush),
        // Fetch
        .instf(inst_d), .reqd(req_d), .rdyd(rdy_d),

        // Execute
        .reqe(req_ed),
        .rdye(rdy_ed),
        .aluop(aluop_e),
        .imm(imm_e),
        .shift(shift_e),
        .rd(regdst_e),
        .rm(regsrc_e),
        .rn(regopd_e),
        .ctlsig(ctlsig_e),
        .bank(bank_e)
    );

    wire req_ed, rdy_ed;
    hs32_exec EXEC(
        .clk(i_clk), .reset(reset),
        // Pipeline controller
        .newpc(newpc), .flush(flush),
        .req(req_ed), .rdy(rdy_ed),

        // Decode
        .aluop(aluop_e),
        .imm(imm_e),
        .shift(shift_e),
        .rd(regdst_e),
        .rm(regsrc_e),
        .rn(regopd_e),
        .ctlsig(ctlsig_e),
        .bank(bank_e),
        
        // Memory arbiter interface
        .reqm(req_e), .rdym(rdy_e),
        .addr(addr_e),
        .dtrm(dtr_e), .dtwm(dtw_e),
        .rw_mem(rw_e),
        
        // Interrupts
        .intrq(intrq),
        .isr(handler),
        .code(vec),
        .iack(iack),
        .nmi(nmi)
    );
endmodule
