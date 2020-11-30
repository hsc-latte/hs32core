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
 * @file   hs32_decode.v
 * @author Anthony Kung <hi@anth.dev>
 * @date   Created on October 24 2020, 10:34 PM
 */

`default_nettype none

//
// Decode Cycle: Determine how to pass
//               instruction to Execute Cycle
//

/* Include OP Codes Definitions */
`include "cpu/hs32_opcodes.v"

/* Include ALU OP Codes Definitions */
`include "cpu/hs32_aluops.v"

`define HS32_NULLI     16'b0
`define HS32_SHIFT     instd[11:7]
`define HS32_SHIFTDIR  instd[6:5]
`define HS32_BANK      instd[4:3]
`define HS32_IMM       instd[15:0]
`define HS32_RD        instd[23:20]
`define HS32_RM        instd[19:16]
`define HS32_RN        instd[15:12]

module hs32_decode (
    input clk,                  // 12 MHz Clock
    input reset,                // Reset

    // Fetch
    input   wire [31:0] instf,  // Next instruction
    output  wire reqd,          // Valid
    input   wire rdyd,          // Ready

    // Execute
    output  reg  [3:0]  aluop,  // ALU Operation
    output  reg  [4:0]  shift,  // 5-bit shift
    output  reg  [15:0] imm,    // Immediate value
    output  reg  [3:0]  rd,     // Register Destination Rd
    output  reg  [3:0]  rm,     // Register Source Rm
    output  reg  [3:0]  rn,     // Register Operand Rn
    output  reg  [1:0]  bank,   // Bank (bb)
    output  reg  [15:0] ctlsig, // Control signals

    // Execute pipeline logic
    output reg reqe,
    input  wire rdye,

    // Interrupts
    output wire [23:0] int_line
);
    reg [31:0] instd;
    assign reqd = rdye;

    reg activate;
    reg intloop;

    assign int_line[0]  = `HS32_IMM == 0  && activate ? 1 : 0;
    assign int_line[1]  = `HS32_IMM == 1  && activate ? 1 : 0;
    assign int_line[2]  = `HS32_IMM == 2  && activate ? 1 : 0;
    assign int_line[3]  = `HS32_IMM == 3  && activate ? 1 : 0;
    assign int_line[4]  = `HS32_IMM == 4  && activate ? 1 : 0;
    assign int_line[5]  = `HS32_IMM == 5  && activate ? 1 : 0;
    assign int_line[6]  = `HS32_IMM == 6  && activate ? 1 : 0;
    assign int_line[7]  = `HS32_IMM == 7  && activate ? 1 : 0;
    assign int_line[8]  = `HS32_IMM == 8  && activate ? 1 : 0;
    assign int_line[9]  = `HS32_IMM == 9  && activate ? 1 : 0;
    assign int_line[10] = `HS32_IMM == 10 && activate ? 1 : 0;
    assign int_line[11] = `HS32_IMM == 11 && activate ? 1 : 0;
    assign int_line[12] = `HS32_IMM == 12 && activate ? 1 : 0;
    assign int_line[13] = `HS32_IMM == 13 && activate ? 1 : 0;
    assign int_line[14] = `HS32_IMM == 14 && activate ? 1 : 0;
    assign int_line[15] = `HS32_IMM == 15 && activate ? 1 : 0;
    assign int_line[16] = `HS32_IMM == 16 && activate ? 1 : 0;
    assign int_line[17] = `HS32_IMM == 17 && activate ? 1 : 0;
    assign int_line[18] = `HS32_IMM == 18 && activate ? 1 : 0;
    assign int_line[19] = `HS32_IMM == 19 && activate ? 1 : 0;
    assign int_line[20] = `HS32_IMM == 20 && activate ? 1 : 0;
    assign int_line[21] = `HS32_IMM == 21 && activate ? 1 : 0;
    assign int_line[22] = `HS32_IMM == 22 && activate ? 1 : 0;
    assign int_line[23] = `HS32_IMM == 23 && activate ? 1 : 0;

    always @(posedge clk)
    if(reset) begin
        reqe <= 0;
        activate <= 0;
    end else begin
        if(rdyd && reqd) begin
            instd   <= instf;
            ctlsig  <= 0;
            aluop   <= 0;
            shift   <= 0;
            imm     <= 0;
            rd      <= 0;
            rm      <= 0;
            rn      <= 0;
            bank    <= 0;
            activate <= 0;
        end
        /* If Ready Received */
        if (rdye) begin
            reqe <= 1;
            
            /* ISA OP Code Decoding */

            /*************************************************************************/
            /*                            IMPORTANT NOTES                            */
            /* By [IGNORED] the value is being ignored (don't care) by Ececute unit  */
            /* By [ZERO] the value 0 is required and NOT ignored by Ececute unit     */
            /* Critical fields are marked with comments and indicate required values */
            /*************************************************************************/
            casez (instd[31:24])
                default: begin
                    activate <= 1;
                    //int <= 24'h000002;
                end

                /**************/
                /*    LDR     */
                /**************/

                /* LDR     Rd <- [Rm + imm] */
                `HS32_LDRI: begin
                    aluop <= `HS32A_ADD;     // ADD
                    shift <= 5'd0;   // [IGNORED] Shift
                    imm <= `HS32_IMM;       // Imm
                    rd <= `HS32_RD;
                    rm <= `HS32_RM;
                    rn <= `HS32_RN;         // [IGNORED] Rn
                    bank <= `HS32_BANK;     // [IGNORED] Bank
                    ctlsig <= { 13'b10_0_010_0000_000, `HS32_SHIFTDIR, 1'b0 };    // [IGNORED] SHIFTDIR
                end
                /* LDR     Rd <- [Rm] */
                `HS32_LDR: begin
                    aluop <= `HS32A_ADD;     // ADD
                    shift <= 5'd0;   // [IGNORED] Shift
                    imm <= `HS32_NULLI;     // [ZERO] Imm
                    rd <= `HS32_RD;
                    rm <= `HS32_RM;
                    rn <= `HS32_RN;         // [IGNORED] Rn
                    bank <= `HS32_BANK;     // [IGNORED] Bank
                    ctlsig <= { 13'b10_0_010_0000_000, `HS32_SHIFTDIR, 1'b0 };    // [IGNORED] SHIFTDIR
                end
                /* LDR     Rd <- [Rm + sh(Rn)] */
                `HS32_LDRA: begin
                    aluop <= `HS32A_ADD;     // ADD
                    shift <= `HS32_SHIFT;   // Shift
                    imm <= `HS32_NULLI;     // [IGNORED] Imm
                    rd <= `HS32_RD;
                    rm <= `HS32_RM;
                    rn <= `HS32_RN;
                    bank <= `HS32_BANK;     // [IGNORED] Bank
                    ctlsig <= { 13'b10_0_011_0000_000, `HS32_SHIFTDIR, 1'b0 };    // SHIFTDIR
                end

                /**************/
                /*    STR     */
                /**************/

                /* STR     [Rm + imm] <- Rd */
                `HS32_STRI: begin
                    aluop <= `HS32A_ADD;     // ADD
                    shift <= 5'd0;   // [IGNORED] Shift
                    imm <= `HS32_IMM;       // Imm
                    rd <= `HS32_RD;
                    rm <= `HS32_RM;
                    rn <= `HS32_RN;         // [IGNORED] Rn
                    bank <= `HS32_BANK;     // [IGNORED] Bank
                    ctlsig <= { 13'b11_0_101_0000_000, `HS32_SHIFTDIR, 1'b0 };    // [IGNORED] SHIFTDIR
                end
                /* STR     [Rm] <- Rd */
                `HS32_STR: begin
                    aluop <= `HS32A_ADD;     // ADD
                    shift <= 5'd0;   // [IGNORED] Shift
                    imm <= `HS32_NULLI;     // [ZERO] Imm
                    rd <= `HS32_RD;
                    rm <= `HS32_RM;
                    rn <= `HS32_RN;         // [IGNORED] Rn
                    bank <= `HS32_BANK;     // [IGNORED] Bank
                    ctlsig <= { 13'b11_0_101_0000_000, `HS32_SHIFTDIR, 1'b0 };    // [IGNORED] SHIFTDIR
                end
                /* STR     [Rm + sh(Rn)] <- Rd */
                `HS32_STRA: begin
                    aluop <= `HS32A_ADD;     // ADD
                    shift <= `HS32_SHIFT;   // Shift
                    imm <= `HS32_NULLI;     // [IGNORED] Imm
                    rd <= `HS32_RD;
                    rm <= `HS32_RM;
                    rn <= `HS32_RN;
                    bank <= `HS32_BANK;     // [IGNORED] Bank
                    ctlsig <= { 13'b11_0_110_0000_000, `HS32_SHIFTDIR, 1'b0 };    // SHIFTDIR
                end

                /**************/
                /*    MOV     */
                /**************/

                /* MOV     Rd <- imm */
                `HS32_MOVI: begin
                    aluop <= `HS32A_MOV;     // MOV
                    shift <= 5'd0;   // [IGNORED] Shift
                    imm <= `HS32_IMM;       // Imm
                    rd <= `HS32_RD;
                    rm <= `HS32_RM;         // [IGNORED] Rm
                    rn <= `HS32_RN;         // [IGNORED] Rn
                    bank <= `HS32_BANK;     // [IGNORED] Bank
                    ctlsig <= { 13'b01_0_001_0000_000, `HS32_SHIFTDIR, 1'b0 };    // [IGNORED] SHIFTDIR
                end
                /* MOV     Rd <- sh(Rn) */
                `HS32_MOVN: begin
                    aluop <= `HS32A_MOV;     // MOV
                    shift <= `HS32_SHIFT;   // Shift
                    imm <= `HS32_NULLI;     // [IGNORED] Imm
                    rd <= `HS32_RD;
                    rm <= `HS32_RM;         // [IGNORED] Rm
                    rn <= `HS32_RN;         // Rn
                    bank <= `HS32_BANK;     // [IGNORED] Bank
                    ctlsig <= { 13'b01_0_100_0000_000, `HS32_SHIFTDIR, 1'b0 };    // SHIFTDIR
                end
                /* MOV     Rd <- Rm_b */
                `HS32_MOV: begin
                    aluop <= `HS32A_MOV;     // MOV
                    shift <= 5'd0;   // [IGNORED] Shift
                    imm <= `HS32_NULLI;     // [ZERO] Imm
                    rd <= `HS32_RD;
                    rm <= `HS32_RM;
                    rn <= `HS32_RN;         // [IGNORED] Rn
                    bank <= `HS32_BANK;     // Bank
                    ctlsig <= { 13'b01_0_010_0000_000, `HS32_SHIFTDIR, 1'b1 };    // [IGNORED] SHIFTDIR
                end
                /* MOV     Rd_b <- Rm */
                `HS32_MOVR: begin
                    aluop <= `HS32A_MOV;     // MOV
                    shift <= 5'd0;   // [IGNORED] Shift
                    imm <= `HS32_NULLI;     // [ZERO] Imm
                    rd <= `HS32_RD;
                    rm <= `HS32_RM;
                    rn <= `HS32_RN;         // [IGNORED] Rn
                    bank <= `HS32_BANK;     // Bank
                    ctlsig <= { 13'b01_0_010_0000_100, `HS32_SHIFTDIR, 1'b1 };    // [IGNORED] SHIFTDIR
                end

                /**************/
                /*  MATH REG  */
                /**************/

                /* ADD     Rd <- Rm + sh(Rn) */
                `HS32_ADD: begin
                    aluop <= `HS32A_ADD;
                    shift <= `HS32_SHIFT;
                    imm <= `HS32_NULLI;     // [IGNORED]
                    rd <= `HS32_RD;
                    rm <= `HS32_RM;
                    rn <= `HS32_RN;
                    bank <= `HS32_BANK;     // [IGNORED] Bank
                    ctlsig <= { 13'b01_0_011_0000_010, `HS32_SHIFTDIR, 1'b0 };    // SHIFTDIR
                end
                /* ADDC    Rd <- Rm + sh(Rn) + C */
                `HS32_ADDC: begin
                    aluop <= `HS32A_ADC;
                    shift <= `HS32_SHIFT;
                    imm <= `HS32_NULLI;     // [IGNORED]
                    rd <= `HS32_RD;
                    rm <= `HS32_RM;
                    rn <= `HS32_RN;
                    bank <= `HS32_BANK;     // [IGNORED] Bank
                    ctlsig <= { 13'b01_0_011_0000_010, `HS32_SHIFTDIR, 1'b0 };
                end
                /* SUB     Rd <- Rm - sh(Rn) */
                `HS32_SUB: begin
                    aluop <= `HS32A_SUB;
                    shift <= `HS32_SHIFT;
                    imm <= `HS32_NULLI;     // [IGNORED]
                    rd <= `HS32_RD;
                    rm <= `HS32_RM;
                    rn <= `HS32_RN;
                    bank <= `HS32_BANK;     // [IGNORED] Bank
                    ctlsig <= { 13'b01_0_011_0000_010, `HS32_SHIFTDIR, 1'b0 };
                end
                /* RSUB    Rd <- sh(Rn) - Rm */
                `HS32_RSUB: begin
                    aluop <= `HS32A_SUB;
                    shift <= `HS32_SHIFT;
                    imm <= `HS32_NULLI;     // [IGNORED]
                    rd <= `HS32_RD;
                    rm <= `HS32_RM;
                    rn <= `HS32_RN;
                    bank <= `HS32_BANK;     // [IGNORED] Bank
                    ctlsig <= { 13'b01_1_011_0000_010, `HS32_SHIFTDIR, 1'b0 };
                end
                /* SUBC    Rd <- Rm - sh(Rn) - C */
                `HS32_SUBC: begin
                    aluop <= `HS32A_SBC;
                    shift <= `HS32_SHIFT;
                    imm <= `HS32_NULLI;
                    rd <= `HS32_RD;
                    rm <= `HS32_RM;
                    rn <= `HS32_RN;
                    bank <= `HS32_BANK;     // [IGNORED] Bank
                    ctlsig <= { 13'b01_0_011_0000_010, `HS32_SHIFTDIR, 1'b0 };
                end
                /* RSUBC   Rd <- sh(Rn) - Rm - C */
                `HS32_RSUBC: begin
                    aluop <= `HS32A_SBC;
                    shift <= `HS32_SHIFT;
                    imm <= `HS32_NULLI;
                    rd <= `HS32_RD;
                    rm <= `HS32_RM;
                    rn <= `HS32_RN;
                    bank <= `HS32_BANK;     // [IGNORED] Bank
                    ctlsig <= { 13'b01_1_011_0000_010, `HS32_SHIFTDIR, 1'b0 };
                end

`ifdef IMUL
                /* MUL     Rd <- Rm * sh(Rn) */
                `HS32_MUL: begin
                    aluop <= `HS32A_MUL;
                    shift <= `HS32_SHIFT;
                    imm <= `HS32_NULLI;     // [IGNORED]
                    rd <= `HS32_RD;
                    rm <= `HS32_RM;
                    rn <= `HS32_RN;
                    bank <= `HS32_BANK;     // [IGNORED] Bank
                    ctlsig <= { 13'b01_0_011_0000_010, `HS32_SHIFTDIR, 1'b0 };    // SHIFTDIR
                end
`endif

                /**************/
                /*  MATH IMM  */
                /**************/

                /* ADD     Rd <- Rm + imm */
                `HS32_ADDI: begin
                    aluop <= `HS32A_ADD;
                    shift <= `HS32_SHIFT;
                    imm <= `HS32_IMM;
                    rd <= `HS32_RD;
                    rm <= `HS32_RM;
                    rn <= `HS32_RN;
                    bank <= `HS32_BANK;     // [IGNORED] Bank
                    ctlsig <= { 13'b01_0_010_0000_010, `HS32_SHIFTDIR, 1'b0 };
                end
                /* ADDC    Rd <- Rm + imm + C */
                `HS32_ADDIC: begin
                    aluop <= `HS32A_ADC;
                    shift <= `HS32_SHIFT;
                    imm <= `HS32_IMM;
                    rd <= `HS32_RD;
                    rm <= `HS32_RM;
                    rn <= `HS32_RN;
                    bank <= `HS32_BANK;     // [IGNORED] Bank
                    ctlsig <= { 13'b01_0_010_0000_010, `HS32_SHIFTDIR, 1'b0 };
                end
                /* SUB     Rd <- Rm - imm */
                `HS32_SUBI: begin
                    aluop <= `HS32A_SUB;
                    shift <= `HS32_SHIFT;
                    imm <= `HS32_IMM;
                    rd <= `HS32_RD;
                    rm <= `HS32_RM;
                    rn <= `HS32_RN;
                    bank <= `HS32_BANK;     // [IGNORED] Bank
                    ctlsig <= { 13'b01_0_010_0000_010, `HS32_SHIFTDIR, 1'b0 };
                end
                /* RSUB    Rd <- imm - Rm */
                `HS32_RSUBI: begin
                    aluop <= `HS32A_SUB;
                    shift <= `HS32_SHIFT;
                    imm <= `HS32_IMM;
                    rd <= `HS32_RD;
                    rm <= `HS32_RM;
                    rn <= `HS32_RN;
                    bank <= `HS32_BANK;     // [IGNORED] Bank
                    ctlsig <= { 13'b01_1_010_0000_010, `HS32_SHIFTDIR, 1'b0 };
                end
                /* SUBC    Rd <- Rm - imm - C */
                `HS32_SUBIC: begin
                    aluop <= `HS32A_SBC;
                    shift <= `HS32_SHIFT;
                    imm <= `HS32_IMM;
                    rd <= `HS32_RD;
                    rm <= `HS32_RM;
                    rn <= `HS32_RN;
                    bank <= `HS32_BANK;     // [IGNORED] Bank
                    ctlsig <= { 13'b01_0_010_0000_010, `HS32_SHIFTDIR, 1'b0 };
                end
                /* RSUBC   Rd <- imm - Rm - C */
                `HS32_RSUBIC: begin
                    aluop <= `HS32A_SBC;
                    shift <= `HS32_SHIFT;
                    imm <= `HS32_IMM;
                    rd <= `HS32_RD;
                    rm <= `HS32_RM;
                    rn <= `HS32_RN;
                    bank <= `HS32_BANK;     // [IGNORED] Bank
                    ctlsig <= { 13'b01_1_010_0000_010, `HS32_SHIFTDIR, 1'b0 };
                end

                /**************/
                /* LOGIC REG  */
                /**************/

                /* AND     Rd <- Rm & sh(Rn) */
                `HS32_AND: begin
                    aluop <= `HS32A_AND;
                    shift <= `HS32_SHIFT;
                    imm <= `HS32_NULLI;
                    rd <= `HS32_RD;
                    rm <= `HS32_RM;
                    rn <= `HS32_RN;
                    bank <= `HS32_BANK;     // [IGNORED] Bank
                    ctlsig <= { 13'b01_0_011_0000_010, `HS32_SHIFTDIR, 1'b0 };
                end
                /* BIC     Rd <- Rm & ~sh(Rn) */
                `HS32_BIC: begin
                    aluop <= `HS32A_BIC;
                    shift <= `HS32_SHIFT;
                    imm <= `HS32_NULLI;
                    rd <= `HS32_RD;
                    rm <= `HS32_RM;
                    rn <= `HS32_RN;
                    bank <= `HS32_BANK;     // [IGNORED] Bank
                    ctlsig <= { 13'b01_0_011_0000_010, `HS32_SHIFTDIR, 1'b0 };
                end
                /* OR      Rd <- Rm | sh(Rn) */
                `HS32_OR: begin
                    aluop <= `HS32A_OR;
                    shift <= `HS32_SHIFT;
                    imm <= `HS32_NULLI;
                    rd <= `HS32_RD;
                    rm <= `HS32_RM;
                    rn <= `HS32_RN;
                    bank <= `HS32_BANK;     // [IGNORED] Bank
                    ctlsig <= { 13'b01_0_011_0000_010, `HS32_SHIFTDIR, 1'b0 };
                end
                /* XOR     Rd <- Rm ^ sh(Rn) */
                `HS32_XOR: begin
                    aluop <= `HS32A_XOR;
                    shift <= `HS32_SHIFT;
                    imm <= `HS32_NULLI;
                    rd <= `HS32_RD;
                    rm <= `HS32_RM;
                    rn <= `HS32_RN;
                    bank <= `HS32_BANK;     // [IGNORED] Bank
                    ctlsig <= { 13'b01_0_011_0000_010, `HS32_SHIFTDIR, 1'b0 };
                end

                /**************/
                /* LOGIC IMM  */
                /**************/

                /* AND     Rd <- Rm & imm */
                `HS32_ANDI: begin
                    aluop <= `HS32A_AND;
                    shift <= `HS32_SHIFT;
                    imm <= `HS32_IMM;
                    rd <= `HS32_RD;
                    rm <= `HS32_RM;
                    rn <= `HS32_RN;
                    bank <= `HS32_BANK;     // [IGNORED] Bank
                    ctlsig <= { 13'b01_0_010_0000_010, `HS32_SHIFTDIR, 1'b0 };
                end
                /* BIC     Rd <- Rm & ~imm */
                `HS32_BICI: begin
                    aluop <= `HS32A_BIC;
                    shift <= `HS32_SHIFT;
                    imm <= `HS32_IMM;
                    rd <= `HS32_RD;
                    rm <= `HS32_RM;
                    rn <= `HS32_RN;
                    bank <= `HS32_BANK;     // [IGNORED] Bank
                    ctlsig <= { 13'b01_0_010_0000_010, `HS32_SHIFTDIR, 1'b0 };
                end
                /* OR      Rd <- Rm | imm */
                `HS32_ORI: begin            // Halo are the Ori >:]
                    aluop <= `HS32A_OR;
                    shift <= `HS32_SHIFT;
                    imm <= `HS32_IMM;
                    rd <= `HS32_RD;
                    rm <= `HS32_RM;
                    rn <= `HS32_RN;
                    bank <= `HS32_BANK;     // [IGNORED] Bank
                    ctlsig <= { 13'b01_0_010_0000_010, `HS32_SHIFTDIR, 1'b0 };
                end
                /* XOR     Rd <- Rm ^ imm */
                `HS32_XORI: begin
                    aluop <= `HS32A_XOR;
                    shift <= `HS32_SHIFT;
                    imm <= `HS32_IMM;
                    rd <= `HS32_RD;
                    rm <= `HS32_RM;
                    rn <= `HS32_RN;
                    bank <= `HS32_BANK;     // [IGNORED] Bank
                    ctlsig <= { 13'b01_0_010_0000_010, `HS32_SHIFTDIR, 1'b0 };
                end

                /**************/
                /* CONDITIONS */
                /**************/

                /* CMP     Rm - sh(Rn) */
                `HS32_CMP: begin
                    aluop <= `HS32A_SUB;
                    shift <= `HS32_SHIFT;
                    imm <= `HS32_NULLI;
                    rd <= `HS32_RD;
                    rm <= `HS32_RM;
                    rn <= `HS32_RN;
                    bank <= `HS32_BANK;     // [IGNORED] Bank
                    ctlsig <= { 13'b00_0_011_0000_010, `HS32_SHIFTDIR, 1'b0 };
                end
                /* CMP     Rm - imm */
                `HS32_CMPI: begin
                    aluop <= `HS32A_SUB;
                    shift <= `HS32_SHIFT;
                    imm <= `HS32_IMM;
                    rd <= `HS32_RD;
                    rm <= `HS32_RM;
                    rn <= `HS32_RN;
                    bank <= `HS32_BANK;     // [IGNORED] Bank
                    ctlsig <= { 13'b00_0_010_0000_010, `HS32_SHIFTDIR, 1'b0 };
                end
                /* TST     Rm & sh(Rn) */
                `HS32_TST: begin
                    aluop <= `HS32A_AND;
                    shift <= `HS32_SHIFT;
                    imm <= `HS32_NULLI;
                    rd <= `HS32_RD;
                    rm <= `HS32_RM;
                    rn <= `HS32_RN;
                    bank <= `HS32_BANK;     // [IGNORED] Bank
                    ctlsig <= { 13'b00_0_011_0000_010, `HS32_SHIFTDIR, 1'b0 };
                end
                /* TST     Rm & imm */
                `HS32_TSTI: begin
                    aluop <= `HS32A_AND;
                    shift <= `HS32_SHIFT;
                    imm <= `HS32_IMM;
                    rd <= `HS32_RD;
                    rm <= `HS32_RM;
                    rn <= `HS32_RN;
                    bank <= `HS32_BANK;     // [IGNORED] Bank
                    ctlsig <= { 13'b00_0_010_0000_010, `HS32_SHIFTDIR, 1'b0 };
                end

                /**************/
                /*   BRANCH   */
                /**************/

                /* B<c>    PC + Offset */
                `HS32_BRCH: begin
                    aluop <= `HS32A_ADD;
                    shift <= `HS32_SHIFT;
                    imm <= `HS32_IMM;
                    rd <= `HS32_RD;
                    rm <= `HS32_RM;
                    rn <= `HS32_RN;
                    bank <= `HS32_BANK;     // [IGNORED] Bank
                    ctlsig <= { 6'b00_0_000, instd[27:24], 3'b00, `HS32_SHIFTDIR, 1'b0 };
                end
                /* B<c>L   PC + Offset */
                `HS32_BRCL: begin
                    aluop <= `HS32A_MOV;
                    shift <= `HS32_SHIFT;
                    imm <= `HS32_IMM;
                    rd <= `HS32_RD;
                    rm <= `HS32_RN;
                    rn <= `HS32_RN;
                    bank <= `HS32_BANK;     // [IGNORED] Bank
                    ctlsig <= { 6'b01_1_010, instd[27:24], 3'b000, `HS32_SHIFTDIR, 1'b0 };
                end

                /**************/
                /* INTERRUPTS */
                /**************/

                /* INT     imm8 */
                `HS32_INT: begin
                    if (!intloop) begin
                        activate <= 1;
                        intloop <= 1;
                        aluop <= `HS32A_NOP;
                        shift <= `HS32_SHIFT;
                        imm <= `HS32_IMM;
                        rd <= `HS32_RD;
                        rm <= `HS32_RM;
                        rn <= `HS32_RN;
                        bank <= `HS32_BANK;     // [IGNORED] Bank
                        ctlsig <= { 13'b00_0_000_0000_100, `HS32_SHIFTDIR, 1'b0 };
                    end
                    else begin
                        if (`HS32_IMM == 0) begin
                            intloop <= 0;
                        end
                    end
                end
            endcase
        end
    end
endmodule