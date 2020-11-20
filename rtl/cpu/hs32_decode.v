/**
 * Decode Cycle: Determine how to pass
 *               instruction to Execute Cycle
*/

/* Include OP Codes Definitions */
`include "hs32_opcodes.v"

/* Include ALU OP Codes Definitions */
`include "hs32_aluops.v"

`define HS32_NULLI     16'b0
`define HS32_SHIFT     5'b0
`define HS32_SHIFT     instd[15:11]
`define HS32_SHIFTDIR  instd[10:9]
`define HS32_BANK      instd[8:7]
`define HS32_IMM       instd[15:0]
`define HS32_RD        instd[23:20]
`define HS32_RM        instd[19:16]
`define HS32_RN        instd[15:12]

module hs32_decode (
    input clk,                  // 12 MHz Clock
    input reset,                // Reset

    // Fetch
    input   wire [31:0] instd,  // Next instruction
    output  reg  reqd,          // Valid
    input   wire rdyd,          // Ready

    // Execute
    output  reg  [3:0]  aluop,  // ALU Operation
    output  reg  [4:0]  shift,  // 5-bit shift
    output  reg  [15:0] imm,    // Immediate value
    output  reg  [3:0]  rd,     // Register Destination Rd
    output  reg  [3:0]  rm,     // Register Source Rm
    output  reg  [3:0]  rn,     // Register Operand Rn
    output  reg  [1:0]  bank,   // Bank (bb)
    output  reg  [15:0] ctlsig  // Control signals
);

    always @ (posedge clk) begin
        /* If Ready Received */
        if (rdyd) begin
            /* ISA OP Code Decoding */

            /*************************************************************************/
            /*                            IMPORTANT NOTES                            */
            /* By [IGNORED] the value is being ignored (don't care) by Ececute unit  */
            /* By [ZERO] the value 0 is required and NOT ignored by Ececute unit     */
            /* Critical fields are marked with comments and indicate required values */
            /*************************************************************************/
            casez (instd[31:24])

                /**************/
                /*    LDR     */
                /**************/

                /* LDR     Rd <- [Rm + imm] */
                `HS32_LDRI: begin
                    aluop <= `HS32A_ADD;     // ADD
                    shift <= `HS32_SHIFT;   // [IGNORED] Shift
                    imm <= `HS32_IMM;       // Imm
                    rd <= `HS32_RD;
                    rm <= `HS32_RM;
                    rn <= `HS32_RN;         // [IGNORED] Rn
                    bank <= `HS32_BANK;     // [IGNORED] Bank
                    ctlsig <= { 12'b10_0_010_0000_000, `HS32_SHIFTDIR, 1'b0 };    // [IGNORED] SHIFTDIR
                end
                /* LDR     Rd <- [Rm] */
                `HS32_LDR: begin
                    aluop <= `HS32A_ADD;     // ADD
                    shift <= `HS32_SHIFT;   // [IGNORED] Shift
                    imm <= `HS32_NULLI;     // [ZERO] Imm
                    rd <= `HS32_RD;
                    rm <= `HS32_RM;
                    rn <= `HS32_RN;         // [IGNORED] Rn
                    bank <= `HS32_BANK;     // [IGNORED] Bank
                    ctlsig <= { 12'b10_0_010_0000_000, `HS32_SHIFTDIR, 1'b0 };    // [IGNORED] SHIFTDIR
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
                    ctlsig <= { 12'b10_0_011_0000_000, `HS32_SHIFTDIR, 1'b0 };    // SHIFTDIR
                end

                /**************/
                /*    STR     */
                /**************/

                /* STR     [Rm + imm] <- Rd */
                `HS32_STRI: begin
                    aluop <= `HS32A_ADD;     // ADD
                    shift <= `HS32_SHIFT;   // [IGNORED] Shift
                    imm <= `HS32_IMM;       // Imm
                    rd <= `HS32_RD;
                    rm <= `HS32_RM;
                    rn <= `HS32_RN;         // [IGNORED] Rn
                    bank <= `HS32_BANK;     // [IGNORED] Bank
                    ctlsig <= { 12'b11_0_101_0000_000, `HS32_SHIFTDIR, 1'b0 };    // [IGNORED] SHIFTDIR
                end
                /* STR     [Rm] <- Rd */
                `HS32_STR: begin
                    aluop <= `HS32A_ADD;     // ADD
                    shift <= `HS32_SHIFT;   // [IGNORED] Shift
                    imm <= `HS32_NULLI;     // [ZERO] Imm
                    rd <= `HS32_RD;
                    rm <= `HS32_RM;
                    rn <= `HS32_RN;         // [IGNORED] Rn
                    bank <= `HS32_BANK;     // [IGNORED] Bank
                    ctlsig <= { 12'b11_0_101_0000_000, `HS32_SHIFTDIR, 1'b0 };    // [IGNORED] SHIFTDIR
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
                    ctlsig <= { 12'b11_0_110_0000_000, `HS32_SHIFTDIR, 1'b0 };    // SHIFTDIR
                end

                /**************/
                /*    MOV     */
                /**************/

                /* MOV     Rd <- imm */
                `HS32_MOVI: begin
                    aluop <= `HS32A_MOV;     // MOV
                    shift <= `HS32_SHIFT;   // [IGNORED] Shift
                    imm <= `HS32_IMM;       // Imm
                    rd <= `HS32_RD;
                    rm <= `HS32_RM;         // [IGNORED] Rm
                    rn <= `HS32_RN;         // [IGNORED] Rn
                    bank <= `HS32_BANK;     // [IGNORED] Bank
                    ctlsig <= { 12'b01_0_001_0000_000, `HS32_SHIFTDIR, 1'b0 };    // [IGNORED] SHIFTDIR
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
                    ctlsig <= { 12'b01_0_100_0000_000, `HS32_SHIFTDIR, 1'b0 };    // SHIFTDIR
                end
                /* MOV     Rd <- Rm_b */
                `HS32_MOV: begin
                    aluop <= `HS32A_MOV;     // MOV
                    shift <= `HS32_SHIFT;   // [IGNORED] Shift
                    imm <= `HS32_NULLI;     // [ZERO] Imm
                    rd <= `HS32_RD;
                    rm <= `HS32_RM;
                    rn <= `HS32_RN;         // [IGNORED] Rn
                    bank <= `HS32_BANK;     // Bank
                    ctlsig <= { 12'b01_0_010_0000_000, `HS32_SHIFTDIR, 1'b1 };    // [IGNORED] SHIFTDIR
                end
                /* MOV     Rd_b <- Rm */
                `HS32_MOVR: begin
                    aluop <= `HS32A_MOV;     // MOV
                    shift <= `HS32_SHIFT;   // [IGNORED] Shift
                    imm <= `HS32_NULLI;     // [ZERO] Imm
                    rd <= `HS32_RD;
                    rm <= `HS32_RM;
                    rn <= `HS32_RN;         // [IGNORED] Rn
                    bank <= `HS32_BANK;     // Bank
                    ctlsig <= { 12'b01_0_010_0000_100, `HS32_SHIFTDIR, 1'b1 };    // [IGNORED] SHIFTDIR
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
                    ctlsig <= { 12'b01_0_011_0000_010, `HS32_SHIFTDIR, 1'b0 };    // SHIFTDIR
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
                    ctlsig <= { 12'b01_0_011_0000_010, `HS32_SHIFTDIR, 1'b0 };
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
                    ctlsig <= { 12'b01_0_011_0000_010, `HS32_SHIFTDIR, 1'b0 };
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
                    ctlsig <= { 12'b01_1_011_0000_010, `HS32_SHIFTDIR, 1'b0 };
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
                    ctlsig <= { 12'b01_0_011_0000_010, `HS32_SHIFTDIR, 1'b0 };
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
                    ctlsig <= { 12'b01_1_011_0000_010, `HS32_SHIFTDIR, 1'b0 };
                end

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
                    ctlsig <= { 12'b01_0_010_0000_010, `HS32_SHIFTDIR, 1'b0 };
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
                    ctlsig <= { 12'b01_0_010_0000_010, `HS32_SHIFTDIR, 1'b0 };
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
                    ctlsig <= { 12'b01_0_010_0000_010, `HS32_SHIFTDIR, 1'b0 };
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
                    ctlsig <= { 12'b01_1_010_0000_010, `HS32_SHIFTDIR, 1'b0 };
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
                    ctlsig <= { 12'b01_0_010_0000_010, `HS32_SHIFTDIR, 1'b0 };
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
                    ctlsig <= { 12'b01_1_010_0000_010, `HS32_SHIFTDIR, 1'b0 };
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
                    ctlsig <= { 12'b01_0_011_0000_010, `HS32_SHIFTDIR, 1'b0 };
                end
                /* BIC     Rd <- Rm & ~sh(Rn) */
                `HS32_BIC: begin
                    aluop <= `HS32A_NOT;
                    shift <= `HS32_SHIFT;
                    imm <= `HS32_NULLI;
                    rd <= `HS32_RD;
                    rm <= `HS32_RM;
                    rn <= `HS32_RN;
                    bank <= `HS32_BANK;     // [IGNORED] Bank
                    ctlsig <= { 12'b01_0_011_0000_010, `HS32_SHIFTDIR, 1'b0 };
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
                    ctlsig <= { 12'b01_0_011_0000_010, `HS32_SHIFTDIR, 1'b0 };
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
                    ctlsig <= { 12'b01_0_011_0000_010, `HS32_SHIFTDIR, 1'b0 };
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
                    ctlsig <= { 12'b01_0_010_0000_010, `HS32_SHIFTDIR, 1'b0 };
                end
                /* BIC     Rd <- Rm & ~imm */
                `HS32_BICI: begin
                    aluop <= `HS32A_NOT;
                    shift <= `HS32_SHIFT;
                    imm <= `HS32_IMM;
                    rd <= `HS32_RD;
                    rm <= `HS32_RM;
                    rn <= `HS32_RN;
                    bank <= `HS32_BANK;     // [IGNORED] Bank
                    ctlsig <= { 12'b01_0_010_0000_010, `HS32_SHIFTDIR, 1'b0 };
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
                    ctlsig <= { 12'b01_0_010_0000_010, `HS32_SHIFTDIR, 1'b0 };
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
                    ctlsig <= { 12'b01_0_010_0000_010, `HS32_SHIFTDIR, 1'b0 };
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
                    ctlsig <= { 12'b00_0_011_0000_010, `HS32_SHIFTDIR, 1'b0 };
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
                    ctlsig <= { 12'b00_0_010_0000_010, `HS32_SHIFTDIR, 1'b0 };
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
                    ctlsig <= { 12'b00_0_011_0000_010, `HS32_SHIFTDIR, 1'b0 };
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
                    ctlsig <= { 12'b00_0_010_0000_010, `HS32_SHIFTDIR, 1'b0 };
                end

                /**************/
                /*   BRANCH   */
                /**************/

                /* B<c>    PC + Offset */
                `HS32_BRCH: begin
                    aluop <= `HS32A_ADD;
                    shift <= `HS32_SHIFT;
                    imm <= `HS32_NULLI;
                    rd <= `HS32_RD;
                    rm <= `HS32_RM;
                    rn <= `HS32_RN;
                    bank <= `HS32_BANK;     // [IGNORED] Bank
                    ctlsig <= { 12'b00_0_000, instd[27:24], 000, `HS32_SHIFTDIR, 1'b0 };
                end
                /* B<c>L   PC + Offset */
                `HS32_BRCL: begin
                    aluop <= `HS32A_ADD;
                    shift <= `HS32_SHIFT;
                    imm <= `HS32_NULLI;
                    rd <= `HS32_RD;
                    rm <= `HS32_RM;
                    rn <= `HS32_RN;
                    bank <= `HS32_BANK;     // [IGNORED] Bank
                    ctlsig <= { 12'b00_0_000, instd[27:24], 001, `HS32_SHIFTDIR, 1'b0 };
                end

                /**************/
                /* INTERRUPTS */
                /**************/

                /* INT     imm8 */
                `HS32_INT: begin
                    aluop <= `HS32A_NOP;
                    shift <= `HS32_SHIFT;
                    imm <= `HS32_IMM;
                    rd <= `HS32_RD;
                    rm <= `HS32_RM;
                    rn <= `HS32_RN;
                    bank <= `HS32_BANK;     // [IGNORED] Bank
                    ctlsig <= { 12'b00_0_000_0000_100, `HS32_SHIFTDIR, 1'b0 };
                end
            endcase
            reqd <= 1;
        end
        else begin
            reqd <= 0;
        end
    end
endmodule