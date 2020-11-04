`include "programmer/main.v"
`timescale 1ns/1ns
module tb_prog_main ();
    parameter PERIOD = 2;
    reg clk = 0;
`ifdef SIM
    always #(PERIOD/2) clk=~clk;
`endif
    initial begin
`ifdef SIM
        $dumpfile("tb_prog_main.vcd");
        $dumpvars(0, prog_main);
        #(PERIOD*20)
        $finish;
`endif
    end
    main prog_main(
        .CLK(clk)
    );
endmodule
