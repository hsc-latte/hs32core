`include "frontend/sram.v"
module main (
    input CLK, output wire LEDG_N, output reg LEDR_N,
    // I/O Bus
    inout IO0, inout IO1, inout IO2, inout IO3, inout IO4,
    inout IO5, inout IO6, inout IO7, inout IO8, inout IO9,
    inout IO10, inout IO11, inout IO12, inout IO13,
    inout IO14, inout IO15,
    // Control signals
    output OE_N, output WE_N, output ALE0, output ALE1, output BHE_N,
    // GPIO
    output wire GPIO8,
    output wire GPIO7, output wire GPIO6, output wire GPIO5, output wire GPIO4,
    output wire GPIO3, output wire GPIO2, output wire GPIO1, output wire GPIO0,

    // OE BYTEn
    output reg OE_BY0_N, output reg OE_BY1_N,
    output reg OE_BY2_N, output reg OE_BY3_N
);
    // Address latch OE pulldown
    initial OE_BY0_N = 0;
    initial OE_BY1_N = 0;
    initial OE_BY2_N = 0;
    initial OE_BY3_N = 0;

    // I/O signals
    wire we, oe, oe_neg, ale0_neg, ale1_neg, bhe, isout;
    wire[15:0] data_in;
    wire[15:0] data_out;
    assign { IO15, IO14, IO13, IO12, IO11, IO10, IO9, IO8,
             IO7, IO6, IO5, IO4, IO3, IO2, IO1, IO0 } = isout ? data_out : 16'bz;
    assign data_in = { IO15, IO14, IO13, IO12, IO11, IO10, IO9, IO8, IO7, IO6, IO5, IO4, IO3, IO2, IO1, IO0 };
    assign OE_N = !(oe & oe_neg);
    assign WE_N = !we;
    assign ALE0 = ale0_neg;
    assign ALE1 = ale1_neg;
    assign BHE_N = !bhe;

    wire done;
    reg valid, rw;
    reg [31:0] addri;
    reg [31:0] dtw;
    reg [31:0] data_final;
    initial data_final = 0;
    wire[31:0] dtr;
    assign { GPIO8, GPIO7, GPIO6, GPIO5, GPIO4, GPIO3, GPIO2, GPIO1, GPIO0 } = data_final[15:7]; //data_in[15:7];

    reg[23:0] ctr;
    wire clk1;
`ifdef SIM
    assign clk1 = CLK;
`else
    assign clk1 = CLK;
`endif
    assign LEDG_N = ~clk1;
    initial ctr = 0;
    always @(posedge CLK) begin
        ctr <= ctr + 1;
    end

    // Power on reset
    reg por, state;
    initial por = 0;
    initial state = 0;
    always @(posedge CLK) begin
        if(!state) begin
            por <= 1;
            state <= 1;
        end
        else por <= 0;
    end

    reg[2:0] fsm;
    initial fsm = 0;
    always @(posedge clk1) case(fsm)
        3'b000: begin
            rw <= 1;
            valid <= 1;
            dtw <= 32'haaaa_aaaa;
            addri <= { 32'h0000_0010 };
            fsm <= 3'b001;
            LEDR_N <= 1;
        end
        3'b001: if(done) begin
            rw <= 0;
            fsm <= 3'b010;
        end
        3'b010: begin
            fsm <= 3'b011;
            valid <= 0;
        end
        3'b011: if(done) begin
            fsm <= 3'b100;
            data_final <= dtr;
            LEDR_N <= 0;
        end
        default: begin end
    endcase

    ext_sram sram (
        .clk(clk1), .reset(por),
        // Memory requests
        .ready(done), .valid(valid), .rw(rw),
        .addri(addri), .dtw(dtw), .dtr(dtr),
        // External IO interface, active >> HIGH <<
        .din(data_in), .dout(data_out),
        .we(we), .oe(oe), .oe_negedge(oe_neg),
        .ale0_negedge(ale0_neg),
        .ale1_negedge(ale1_neg),
        .bhe(bhe), .isout(isout)
    );
endmodule