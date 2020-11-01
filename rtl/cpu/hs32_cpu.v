`include "cpu/hs32_mem.v"
`include "cpu/hs32_fetch.v"
`include "cpu/hs32_exec.v"
`include "cpu/hs32_decode.v"

// NO LATCHES ALLOWED!
module hs32_cpu (
    input clk, input reset,

    // External interface
    output  wire [31:0] addr,
    output  wire rw,
    input   wire[31:0] din,
    output  wire[31:0] dout,
    output  wire valid,
    input   wire done
);
    wire[31:0] addr_e, dtr_e, dtw_e;
    wire req_e, ack_e, rw_e;

    wire[31:0] addr_f, dtr_f;
    wire req_f, ack_f;
    hs32_mem MEM(
        // External interface
        .addr(addr), .rw(rw), .din(din), .dout(dout),
        .valid(valid), .done(done),
        
        // Channel 0 (Execute)
        .addr0(addr_e), .dtr0(dtr_e), .dtw0(dtw_e),
        .rw0(rw_e), .req0(req_e), .ack0(ack_e),

        // Channel 1 (Fetch)
        .addr1(addr_f), .dtr1(dtr_f), .dtw1(0),
        .rw1(0), .req1(req_f), .ack1(ack_f)
    );

    wire[31:0] inst_d;
    wire req_d, ack_d;
    hs32_fetch FETCH(
        .clk(clk),
        // Memory arbiter interface
        .addr(addr_f), .dtr(dtr_f), .reqm(req_f), .ackm(ack_f),
        // Decode
        .instd(inst_d), .reqd(req_d), .ackd(ack_d),
        // TODO: Pipeline controller
        .newpc(0), .flush(0)
    );

    wire [2:0]  aluop_e;
    wire [4:0]  shift_e;
    wire [15:0] imm_e;
    wire [3:0]  regdst_e;
    wire [3:0]  regsrc_e;
    wire [3:0]  regopd_e;
    wire [15:0] ctlsig_e;
    hs32_decode DECODE(
        .clk(clk), .reset(0),
        
        // Fetch
        .instd(inst_d), .reqd(req_d), .ackd(ack_d),

        // Execute
        .aluop(aluop_e),
        .imm(imm_e),
        .shift(shift_e),
        .regdst(regdst_e),
        .regsrc(regsrc_e),
        .regopd(regopd_e),
        .ctlsig(ctlsig_e)
    );

    hs32_exec EXEC(
        .clk(clk), .reset(0),
        // TODO: Pipeline controller
        .newpc(), .flush(),

        // Decode
        .aluop(aluop_e),
        .imm(imm_e),
        .shift(shift_e),
        .regdst(regdst_e),
        .regsrc(regsrc_e),
        .regopd(regopd_e),
        .ctlsig(ctlsig_e),
        
        // Memory arbiter interface
        .addr(addr_e), .dtr(dtr_e), .reqm(req_e), .ackm(ack_e),
        
        // Interrupts
        .intrq(0), .addi(0)
    );
endmodule
