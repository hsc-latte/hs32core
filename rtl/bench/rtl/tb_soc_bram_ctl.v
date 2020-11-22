`timescale 1ns/1ns
`include "soc/bram_ctl.v"

module tb_soc_bram_ctl ();
    parameter PERIOD = 2;

    reg clk = 0; // Posedge = 0
    wire[31:0] dread;
    wire done;
    reg [31:0] dwrite;
    reg [7:0] addr;
    reg rw, valid;

`ifdef SIM
    always #(PERIOD/2) clk=~clk;
`endif

    initial begin
`ifdef SIM
        $dumpfile("tb_bram_ctl.vcd");
        $dumpvars(0, bram_ctl, f_state);
        
        rw <= 1;
        addr <= 32;
        dwrite <= 32'h1122_3344;
        #(PERIOD*3)

        rw <= 1;
        addr <= 36;
        dwrite <= 32'h5566_7788;
        #(PERIOD*3)

        rw <= 0;
        addr <= 36;
        #(PERIOD*3)
        
        $finish;
`endif
    end

    initial valid = 1;

    reg[7:0] f_addr = 128;
    reg[31:0] f_data = 32'h1122_3344;
    reg[2:0] f_state;
    initial f_state = 0;
    /*always @(posedge clk)
    case(f_state)
        // First, write to address
        0: begin
            rw <= 1;
            addr <= f_addr;
            dwrite <= f_data;
            f_state <= 1;
        end
        // Second, read from same address
        1: if(done) begin
            addr <= f_addr+1;
            rw <= 0;
            f_state <= 2;
        end
        2: if(done) f_state <= 3;
        3: f_state <= 0;
    endcase*/

    soc_bram_ctl #(
        .addr_width(8)
    ) bram_ctl(
        .clk(clk),
        .addr(addr), .rw(rw),
        .dread(dread), .dwrite(dwrite),
        .valid(valid), .ready(done)
    );
endmodule