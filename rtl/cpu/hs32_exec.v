/**



*/

`include "./cpu/hs32_reg.v"

`define CTL_D   12:11
`define CTL_S   10:8
`define CTL_M   7:6
`define CTL_B   5:2
`define CTL_I   1
`define CTL_F   0
`define T1      1

module hs32_exec (
    input clk,                  // 12 MHz Clock
    input reset,                // Active Low Reset

    // Fetch
    output  reg [31:0] newpc,   // New program
    output  reg flush,          // Flush

    // Decode
    input wire  [2:0]  aluop,   // ALU Operation
    input wire  [4:0]  shift,   // 5-bit shift
    input wire  [15:0] imm,     // Immediate value
    input wire  [3:0]  rd,      // Register Destination Rd
    input wire  [3:0]  rm,      // Register Source Rm
    input wire  [3:0]  rn,      // Register Operand Rn
    input wire  [15:0] ctlsig,  // Control signals

    // Memory arbiter interface
    output  reg  [31:0] addr,   // Address
    input   wire [31:0] dtrm,   // Data input
    output  reg  reqm,          // Valid address
    input   wire ackm,          // Valid data

    // Interrupts
    input   wire intrq,         // Interrupt signal
    input   wire [31:0] addi    // Interrupt address
);
    wire [31:0] ibus1;
    wire [31:0] ibus2;
    wire [31:0] obus;

    reg [31:0] mar, dtw, dtr, pc;

    reg[2:0] state;

    wire reg_we;
    wire [3:0] regadra;
    wire [31:0] regouta;
    wire [3:0] regadrb;
    wire [31:0] regoutb;
    wire [3:0] regwadr;
    wire [31:0] reginp;

    always @(posedge clk) case(state)
        
    endcase

    assign ibus1 = regouta;
    assign ibus2 = ctlsig[`CTL_S] == 3'b001
                || ctlsig[`CTL_S] == 3'b010
                || ctlsig[`CTL_S] == 3'b101 ? { 16'b0, imm }
                 : regoutb;
    assign reginp = obus;
    assign regadra = rm;
    assign regadrb = rn;
    assign regwadr = rd;
    assign reg_we = (state == `T1 && ctlsig[`CTL_D] == 2'b01);

    hs32_reg regfile (
        .clk(clk), .reset(reset),
        .we(reg_we),
        .wadr(regwadr), .din(reginp),
        .dout1(regouta), .radr1(regadra),
        .dout2(regoutb), .radr2(regadrb)
    );

endmodule
