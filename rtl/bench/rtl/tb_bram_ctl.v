`timescale 1ns/1ns
`include "soc/bram_ctl.v"

module tb_soc_bram_ctl ();
    parameter PERIOD = 2;

    reg clk = 0; // Posedge = 0
    wire[31:0] dread;
    wire done;
    reg [31:0] addr, dwrite;
    reg rw, valid;

`ifdef SIM
    always #(PERIOD/2) clk=~clk;
`endif

    initial begin
`ifdef SIM
        $dumpfile("tb_bram_ctl.vcd");
        $dumpvars(0, bram_ctl);

        rw <= 1;
        addr <= 0;
        dwrite <= 32'hABCD_1234;
        valid <= 1;
        #(PERIOD*3)

        rw <= 1;
        addr <= 4;
        dwrite <= 32'h5678_9013;
        valid <= 1;
        #(PERIOD*3)

        rw <= 0;
        addr <= 1;
        valid <= 1;
        #(PERIOD*3)

        #PERIOD

        $finish;
`endif
    end

    soc_bram_ctl #(
        .addr_width(8)
    ) bram_ctl(
        .clk(clk),
        .addr(addr[7:0]), .rw(rw),
        .dread(dread), .dwrite(dwrite),
        .valid(valid), .done(done)
    );
endmodule