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
    input   wire [31:0] addi    // Interrupt address
);
    //===============================//
    // Initial values
    //===============================//
    initial reqm = 0;
    initial rw_mem = 0;
    initial flush = 0;
    assign rdy = state == `IDLE;

    initial mar = 0;
    initial dtw = 0;
    initial pc_u = 0;
    initial pc_s = 0;
    initial lr_i = 0;
    initial sp_i = 0;
    initial mcr_s = 0;
    initial reg_we = 0;
    initial state = 0;

    // Three internal busses
    wire [31:0] ibus1, ibus2, obus;
    // Memory address and data registers
    reg  [31:0] mar, dtw;
    assign addr = mar;
    assign dtwm = dtw;
    
    //===============================//
    // Banked registers control logic
    //===============================//

    // Special banked registers
    reg  [31:0] pc_u, pc_s, lr_i, sp_i, mcr_s;
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
        (`IS_INT || `BANK_I) && regadra == 4'b1110 ? lr_i : regouta_s;
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

    assign ibus1 = regadra == 4'b1111 ? pc_u : regouta;
    assign ibus2 =
        (`CTL_s == `CTL_s_xix ||
         `CTL_s == `CTL_s_mix ||
         `CTL_s == `CTL_s_mid) ? { 16'b0, imm } : regoutb;
    assign obus = state == `TW2 ? dtrm : aluout;

    //===============================//
    // FSM
    //===============================//

    // State transitions only
    reg[3:0] state;
    always @(posedge clk) case(state)
        `IDLE: begin
            state <= req ? (`CTL_b == 0) ? `TR1 : `TB1 : `IDLE;
        end
        `TB1: begin
            
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
                `CTL_d_ma:
                    state <= `TM2;
            endcase
        endcase
        `TR2: begin
            state <= `TW1;
        end
        `TW1: case(`CTL_d)
            default:
                state <= `IDLE;
            `CTL_d_dt_ma:
                state <= `TM1;
            `CTL_d_ma:
                state <= `TM2;
        endcase
        `TM1: begin
            if(reqm && rdym) begin
                reqm <= 0;
                state <= `TW2;
            end else begin
                reqm <= 1;
                rw_mem <= 0;
                state <= `TM1;
            end
        end
        `TM2: begin
            if(reqm && rdym) begin
                reqm <= 0;
                state <= `TW2;
            end else begin
                reqm <= 1;
                rw_mem <= 1;
                state <= `TM1;
            end
        end
        `TW2: begin
            state <= `IDLE;
        end
    endcase

    //===============================//
    // State processes
    //===============================//

    // Write to Rd
    always @(posedge clk) case(state)
        `IDLE: reg_we <= 0;
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
    endcase

    // Write to MAR
    always @(posedge clk) case(state)
        `TR2: dtw <= ibus1;
        `TR1, `TW1: case(`CTL_d)
            `CTL_d_dt_ma, `CTL_d_ma:
                mar <= obus;
            default: begin end
        endcase
    endcase

    // Branch
    always @(posedge clk) case(state)
        `IDLE: begin
            if(`IS_USR || `BANK_U)
                pc_u <= pc_u+4;
            else
                pc_s <= pc_s+4;
            flush <= 0;
        end
        `TB2: begin
            newpc <= obus;
            if(`IS_USR || `BANK_U)
                pc_u <= obus;
            else
                pc_s <= obus;
            flush <= 1;
        end
    endcase

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
    hs32_alu alu (
        .a_i(ibus1), .b_i(ibus2),
        .op_i(aluop), .r_o(aluout),
        .fl_i(0), .fl_o()
    );

endmodule
