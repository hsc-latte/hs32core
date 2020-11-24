/**************************************
 * OP Code Definitions                *
 * Created with <3 by Anthony & Kevin *
 * Nov 14, 2020                       *
 **************************************/

`ifndef HS32_OPCODES
`define HS32_OPCODES

/* LDR     Rd <- [Rm + imm] */
`define HS32_LDRI     8'b000_10_100

/* LDR     Rd <- [Rm] */
`define HS32_LDR      8'b000_10_000

/* LDR     Rd <- [Rm + sh(Rn)] */
`define HS32_LDRA     8'b000_10_001

/* STR     [Rm + imm] <- Rd */
`define HS32_STRI     8'b001_10_100

/* STR     [Rm] <- Rd */
`define HS32_STR      8'b001_10_000

/* STR     [Rm + sh(Rn)] <- Rd */
`define HS32_STRA     8'b001_10_001

/* MOV     Rd <- imm */
`define HS32_MOVI     8'b001_00_100

/* MOV     Rd <- sh(Rn) */
`define HS32_MOVN     8'b001_00_000

/* MOV     Rd <- Rm_b */
`define HS32_MOV      8'b001_00_001

/* MOV     Rd_b <- Rm */
`define HS32_MOVR     8'b001_00_010

/* ADD     Rd <- Rm + sh(Rn) */
`define HS32_ADD      8'b010_00_000

/* ADDC    Rd <- Rm + sh(Rn) + c */
`define HS32_ADDC     8'b010_00_001

/* SUB     Rd <- Rm - sh(Rn) */
`define HS32_SUB      8'b011_00_000

/* RSUB    Rd <- sh(Rn) - Rm */
`define HS32_RSUB      8'b011_00_001

/* SUBC    Rd <- Rm - sh(Rn) + c */
`define HS32_SUBC      8'b011_00_010

/* RSUBC   Rd <- sh(Rn) - Rm + c */
`define HS32_RSUBC     8'b011_00_011

/* ADD     Rd <- Rm + imm */
`define HS32_ADDI      8'b010_00_100

/* ADDC    Rd <- Rm + imm + c */
`define HS32_ADDIC     8'b010_00_101

/* SUB     Rd <- Rm - imm */
`define HS32_SUBI      8'b011_00_100

/* RSUB    Rd <- imm - Rm */
`define HS32_RSUBI     8'b011_00_101

/* SUBC    Rd <- imm - Rm */
`define HS32_SUBIC     8'b011_00_110

/* RSUBC   Rd <- imm - Rm + c */
`define HS32_RSUBIC    8'b011_00_111

/* MUL     Rd <- Rm * sh(Rn) */
`define HS32_MUL       8'b010_00_010

/* AND     Rd <- Rm & sh(Rn) */
`define HS32_AND       8'b100_00_000

/* BIC     Rd <- Rm & ~sh(Rn) */
`define HS32_BIC       8'b100_00_001

/* OR      Rd <- Rm | sh(Rn) */
`define HS32_OR        8'b101_00_000

/* XOR     Rd <- Rm ^ sh(Rn) */
`define HS32_XOR       8'b110_00_000

/* AND     Rd <- Rm & imm */
`define HS32_ANDI      8'b100_00_100

/* BIC     Rd <- Rm & ~imm */
`define HS32_BICI      8'b100_00_101

/* OR      Rd <- Rm | imm */
`define HS32_ORI       8'b101_00_100

/* XOR     Rd <- Rm ^ imm */
`define HS32_XORI      8'b110_00_100

/* CMP     Rm - Rn */
`define HS32_CMP       8'b011_01_000

/* CMP     Rm - imm */
`define HS32_CMPI      8'b011_01_100

/* TST     Rm & Rn */
`define HS32_TST       8'b100_01_000

/* TST     Rm & imm */
`define HS32_TSTI      8'b100_01_100

/* B<c>    PC + Offset */
`define HS32_BRCH      8'b010_1?_???

/* B<c>L   PC + Offset */
`define HS32_BRCL      8'b011_1?_???

/* INT     imm8 */
`define HS32_INT       8'b100_10_000

`endif