/**
 * HSC FPGA Verilog Template
 * https://github.com/HomebrewSiliconClub/Processor
 * Created with <3 by Anthony Kung <hi@anth.dev>
 */

module hsc (input clk, output ledr, ledg);

    reg [24:0] second = 24'b0;

    assign ledg = second[24] ^ 8'hff;
    assign ledr = ~ledg;

    always @ (posedge clk) begin
        second <= second + 1;
    end

endmodule