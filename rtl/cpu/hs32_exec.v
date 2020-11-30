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
 * @file   hs32_exec.v
 * @author Kevin Dai <kevindai02@outlook.com>
 * @date   Created on October 24 2020, 10:33 PM
 */

`default_nettype none

`include "./cpu/hs32_reg.v"
`include "./cpu/hs32_alu.v"
`include "./cpu/hs32_xuconst.v"

module hs32_exec (
    input  wire clk,            // 12 MHz Clock
    input  wire reset,          // Active Low Reset
    input  wire req,            // Request line
    output wire rdy,            // Output ready

    // Fetch
    output  reg [31:0] newpc,   // New program
    output  reg flush,          // Flush

    // Decode
    input   wire [3:0]  aluop,  // ALU Operation
    input   wire [4:0]  shift,  // 5-bit shift
    input   wire [15:0] imm,    // Immediate value
    input   wire [3:0]  rd,     // Register Destination Rd
    input   wire [3:0]  rm,     // Register Source Rm
    input   wire [3:0]  rn,     // Register Operand Rn
    input   wire [15:0] ctlsig, // Control signals
    input   wire [1:0]  bank,   // Input bank

    // Memory arbiter interface
    output  wire [31:0] addr,   // Address
    input   wire [31:0] dtrm,   // Data input
    output  wire [31:0] dtwm,   // Data output
    output  reg  reqm,          // Valid address
    input   wire rdym,          // Valid data
    output  reg  rw_mem,        // Read write

    // Interrupts
    input   wire intrq,         // Interrupt signal
    input   wire nmi,           // Non maskable?
    input   wire [31:0] isr,    // Interrupt handler
    input   wire [4:0] code,    // Interrupt vector
    output  reg  iack           // Interrupt acknowledge
);
    // Assign ready signal (only when IDLE)
    assign rdy = state == `IDLE;

    // Latch incoming interrupts
    reg int_latch;
    reg[31:0] isr_latch;
    reg[4:0] code_latch;
    always @(posedge clk)
    if(reset)
        int_latch <= 0;
    else if(state == `INT)
        int_latch <= 0;
    // NMI forces an interrupt, otherwise check interrupt enable
    else if(intrq && (nmi || !(`MCR_INTEN))) begin
        int_latch <= 1;
        isr_latch <= isr;
        code_latch <= code;
    end

    //===============================//
    // Busses
    //===============================//

    wire [31:0] ibus1, ibus2, ibus2_sh, obus;
    // Memory address and data registers
    reg  [31:0] mar, dtw;
    assign addr = mar;
    assign dtwm = dtw;
    
    //===============================//
    // Banked registers control logic
    //===============================//

    // Special banked registers
    reg  [31:0] pc_u, pc_s, lr_i, sp_i, mcr_s, flags;
    // Register file control signals
    wire [3:0]  regadra, regadrb;
    // User bank
    wire reg_we_u;
    wire [31:0] regouta_u, regoutb_u;
    // Supervisor bank
    wire reg_we_s;
    wire [31:0] regouta_s, regoutb_s;
    // General access switching
    reg reg_we;
    wire[31:0] regouta, regoutb;
    assign reg_we_u = `IS_USR || `BANK_U ? reg_we : 0;
    assign reg_we_s = !(`IS_USR || `BANK_U) ? reg_we : 0;
    assign regouta =
        `IS_USR || `BANK_U ? regouta_u :
        (`IS_INT || `BANK_I) && regadra == 4'b1110 ? lr_i : regouta_s;
    assign regoutb =
        `IS_USR || `BANK_U ? regoutb_u :
        (`IS_INT || `BANK_I) && regadrb == 4'b1110 ? lr_i : regoutb_s;
    // Register select
    assign regadra =
        state == `TR1 ?
        (`CTL_s == `CTL_s_mid || `CTL_s == `CTL_s_mnd ?
            rd : rm)
        : rm;
    assign regadrb = rn;

    //===============================//
    // Bus assignments
    //===============================//

    assign ibus1 =
        regadra == 4'b1111 ?
        (`IS_USR || `BANK_U ? pc_u : pc_s)
        : regouta;
    assign ibus2 =
        (`CTL_s == `CTL_s_xix ||
         `CTL_s == `CTL_s_mix ||
         `CTL_s == `CTL_s_mid) ? { 16'b0, imm } : regoutb;
    assign obus =
        state == `TW2 ? dtrm :
        state == `IDLE ?
            (`CTL_d == `CTL_d_dt_ma ? dtrm : aluout)
        : aluout;
`ifdef BARREL_SHIFTER
    // Barrel shifter
    assign ibus2_sh =
        shift == 0 ? ibus2 :
        `CTL_d == `CTL_D_shl ? ibus2 << shift :
        `CTL_d == `CTL_D_shr ? ibus2 >> shift :
        `CTL_d == `CTL_D_ssr ? ibus2 >>> shift :
        ibus2 << shift | ibus2 >> (32-shift);
`else
    assign ibus2_sh = ibus2;
`endif

    //===============================//
    // FSM
    //===============================//

    // State transitions only (drive: state)
    reg[3:0] state;
    always @(posedge clk)
    if(reset) begin
        state <= 0;
    end else case(state)
        `IDLE: if(int_latch || intrq) begin
            state <= `INT;
        end else if(req) begin
            state <=
                // All states (except branch) start with `TR1
                (`CTL_b == 0) ? `TR1 :
                // Decide whether to branch or not
                (flags[{ 1'b0, `CTL_b }] == 1'b1) ? `TB1 :
                // No branch taken
                `IDLE;
        end
        `TB1: begin
            state <= `TR1;
        end
        `TB2: begin
            state <= `IDLE;
        end
        `TR1: case(`CTL_s)
            `CTL_s_mid, `CTL_s_mnd:
                state <= `TR2;
            default: case(`CTL_d)
                `CTL_d_none:
                    state <= `IDLE;
                `CTL_d_rd:
                    state <= (rd == 4'b1111) ? `TB2 : `IDLE;
                `CTL_d_dt_ma:
                    state <= `TM1;
                `CTL_d_ma: begin
                    // TODO: Error
                end
            endcase
        endcase
        `TR2: begin
            state <= `TM2;
        end
        `TM1: begin
            if(reqm && rdym)
                state <= `TW2;
            else
                state <= `TM1;
        end
        `TM2: begin
            if(reqm && rdym)
                state <= `IDLE;
            else
                state <= `TM2;
        end
        `TW2: begin
            state <= (rd == 4'b1111) ? `TB2 : `IDLE;
        end
        `INT: begin
            state <= `TB2;
        end
    endcase

    //===============================//
    // State processes
    //===============================//

    // Write to Rd (drive: reg_we, mcr_s, sp_i, lr_i)
    always @(posedge clk)
    if(reset) begin
        lr_i <= 0;
        sp_i <= 0;
        mcr_s <= 0;
        reg_we <= 0;
    end else case(state)
        `IDLE: begin
            reg_we <= 0;
            if(req && `CTL_b == 4'b1111) begin
                `MCR_USR <= `MCR_USRi;
                `MCR_MDE <= `MCR_MDEi;
            end
        end
        // On TR1, then we haven't written to MAR yet if CTL_s is mid/mnd.
        //         so we must check for CTL_d and CTL_s
        // On TW2, then we finished memory access and we just write.
        //         Since TW2 is only for LDR, we don't need to check ctlsigs
        `TW2, `TR1: if(
            (state == `TR1 && `CTL_s != `CTL_s_mid && `CTL_s != `CTL_s_mnd && `CTL_d == `CTL_d_rd) ||
            (state == `TW2)
        ) case(rd)
            // Deal with register bankings
            default: reg_we <= 1;
            4'b1100: if(`IS_SUP)
                mcr_s <= obus;
            else
                reg_we <= 1;
            4'b1101: if(`IS_INT || (!`IS_USR && `BANK_I))
                sp_i <= obus;
            else 
                reg_we <= 1;
            4'b1110: if(`IS_INT || (!`IS_USR && `BANK_I))
                lr_i <= obus;
            else
                reg_we <= 1;
            4'b1111: begin end
        endcase
        // Interrupt
        `INT: begin
            lr_i <= `IS_USR ? pc_u : pc_s;
            `MCR_USR <= 0;
            `MCR_MDE <= 1;
            `MCR_VEC <= code_latch;
            `MCR_NZCVi <= flags[31:28];
            `MCR_USRi <= `MCR_USR;
            `MCR_MDE <= `MCR_MDE;
        end
    endcase

    // Write to MAR (drive: mar, dtw)
    always @(posedge clk)
    if(reset) begin
        mar <= 0;
        dtw <= 0;
    end else case(state)
        `TR1: if(`CTL_d == `CTL_d_ma)
            dtw <= ibus1;
        else if(`CTL_d == `CTL_d_dt_ma)
            mar <= obus;
        `TR2: mar <= obus;
    endcase

    // Memory requests (drive: reqm, rw_mem)
    always @(posedge clk)
    if(reset) begin
        reqm <= 0;
        rw_mem <= 0;
    end else case(state)
        // Read from memory
        `TM1: begin
            if(reqm && rdym) begin
                reqm <= 0;
            end else begin
                reqm <= 1;
                rw_mem <= 0;
            end
        end
        // Write to memory
        `TM2: begin
            if(reqm && rdym) begin
                reqm <= 0;
            end else begin
                reqm <= 1;
                rw_mem <= 1;
            end
        end
    endcase

    // Branch (drive: flush, pc_u, pc_s)
    always @(posedge clk)
    if(reset) begin
        flush <= 0;
        pc_u <= 0;
        pc_s <= 0;
        iack <= 0;
    end else case(state)
        `IDLE: begin
            flush <= 0;
            if(req && !(int_latch || intrq)) begin
                // Increment PC before we change states
                if(`IS_USR)
                    pc_u <= pc_u+4;
                else
                    pc_s <= pc_s+4;
            end
        end
        // Update PC since we take the branch
        `TB1: begin
            newpc <= { 16'b0, imm } + (`IS_USR ? pc_u : pc_s);
            flush <= 1;
            if(`IS_USR)
                pc_u <= { 16'b0, imm } + pc_u;
            else
                pc_s <= { 16'b0, imm } + pc_s;
            if(`CTL_b == 4'b1111) begin
                iack <= 1;
            end
        end
        `INT: begin
            flush <= 1;
            pc_s <= isr_latch;
            newpc <= isr_latch;
        end
        `TB2: begin
            iack <= 0;
        end
        // Update the PC from a Rd instruction (see "write to Rd")
        `TW2, `TR1: if(
            ((state == `TR1 && `CTL_s != `CTL_s_mid && `CTL_s != `CTL_s_mnd && `CTL_d == `CTL_d_rd) ||
            (state == `TW2)) && rd == 4'b1111
        ) begin
            newpc <= obus;
            flush <= 1;
            if(`IS_USR || `BANK_U)
                pc_u <= obus;
            else
                pc_s <= obus;
        end
    endcase

    // Write to flags on `TR1 cycles only (drive: flags)
    always @(posedge clk) begin
        if(reset) begin
            flags <= { 16'b0, 16'h8001 };
        end else if(
            (state == `TR1 && `CTL_s != `CTL_s_mid && `CTL_s != `CTL_s_mnd && `CTL_d == `CTL_d_rd) ||
            (state == `TW2) && `BANK_F
        ) begin
            flags <= obus;
        end else if(state == `TR1 && `CTL_d == `CTL_d_rd && `CTL_f == 1'b1) begin
            flags <= { alu_nzcv, 12'b0, branch_conds };
        end
    end

    //===============================//
    // Register files
    //===============================//

    hs32_reg regfile_u (
        .clk(clk), .reset(reset),
        .we(reg_we_u),
        .wadr(rd), .din(obus),
        .dout1(regouta_u), .radr1(regadra),
        .dout2(regoutb_u), .radr2(regadrb)
    );

    hs32_reg regfile_s (
        .clk(clk), .reset(reset),
        .we(reg_we_s),
        .wadr(rd), .din(obus),
        .dout1(regouta_s), .radr1(regadra),
        .dout2(regoutb_s), .radr2(regadrb)
    );

    //===============================//
    // ALU
    //===============================//

    wire [31:0] aluout;
    wire [3:0] alu_nzcv, alu_nzcv_out;
    assign alu_nzcv = `CTL_f ? alu_nzcv_out : flags[31:28];
    hs32_alu alu (
        .i_a(`CTL_r ? ibus2_sh : ibus1),
        .i_b(`CTL_r ? ibus1 : ibus2_sh),
        .i_op(aluop), .o_r(aluout),
        .i_fl(flags[31:28]), .o_fl(alu_nzcv_out)
    );
    wire [15:0] branch_conds;
    assign branch_conds = {
        1'b1, // Always true
        `ALU_Z | (`ALU_N ^ `ALU_V),     // LE
        !`ALU_Z & !(`ALU_N ^ `ALU_V),   // GT
        `ALU_N ^ `ALU_V,                // LT
        !(`ALU_N ^ `ALU_V),             // GE
        !`ALU_C | `ALU_Z,               // BE
        `ALU_C | !`ALU_Z,               // AB
        !`ALU_V,                        // NV
        `ALU_V,                         // OV
        !`ALU_N,                        // NS
        `ALU_N,                         // SS
        !`ALU_C,                        // NC
        `ALU_C,                         // CS
        !`ALU_Z,                        // NE
        `ALU_Z,                         // EQ
        1'b1  // Always true
    };

`ifdef FORMAL
    // $past gaurd
    reg f_past_valid;
    initial f_past_valid = 0;
    always @(posedge clk)
        f_past_valid <= 1;

    // 0. 

    `include "cpu/hs32_exec_proof.v"
`endif
endmodule
