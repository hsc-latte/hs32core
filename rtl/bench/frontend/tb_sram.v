`include "frontend/sram.v"

`timescale 1ns / 1ps

module TB_EXT_SRAM;

  reg clk;
  reg valid;          // Valid
  reg rw;             // Read/Write Write = 1
  reg [31:0] addri;   // Address
  reg [15:0] dtw;     // Data to write
  reg [15:0] din;     // Data in

  EXT_SRAM sram(
    .clk(clk),
    .valid(valid),
    .rw(rw),
    .addri(addri),
    .dtw(dtw),
    .din(din)
  );

  `ifdef SIMULATION

    initial begin
      clk = 0;
      valid = 0;
      rw = 0;
      addri = 32'd0;
      dtw = 16'd0;
      din = 16'd0;
      $dumpfile("sram_tb.vcd");
      $dumpvars(0, sram);
      #20
      $finish;
    end

    always begin
      #10 clk = ~clk;
    end

    reg [2:0] count = 3'd0;

    always @(posedge clk) begin
      count <= count + 1;
    end

    /*************
     * READ MODE *
     *************/

    // Cycle 1
    #20;
    valid = 1;
    rw = 0;
    addri = 32'hFFFFFFFF;
    dtw = 16'd0;
    din = 16'hFFFF;

    // Cycle 2
    #20;
    valid = 1;
    rw = 0;
    addri = 32'hFFFFFFFF;
    dtw = 16'd0;
    din = 16'hFFFF;

    // Cycle 3
    #20;
    valid = 1;
    rw = 0;
    addri = 32'hFFFFFFFF;
    dtw = 16'd0;
    din = 16'd0;

    // Cycle 4
    #20;
    valid = 1;
    rw = 0;
    addri = 32'hFFFFFFFF;
    dtw = 16'd0;
    din = 16'd0;

    /**************
     * WRITE MODE *
     **************/

    // Cycle 1
    #20;
    valid = 1;
    rw = 1;
    addri = 32'hFFFFFFFF;
    dtw = 16'hFFFF;
    din = 16'd0;

    // Cycle 2
    #20;
    valid = 1;
    rw = 1;
    addri = 32'hFFFFFFFF;
    dtw = 16'hFFFF;
    din = 16'd0;

    // Cycle 3
    #20;
    valid = 1;
    rw = 1;
    addri = 32'hFFFFFFFF;
    dtw = 16'hFFFF;
    din = 16'd0;

    // Cycle 4
    #20;
    valid = 1;
    rw = 1;
    addri = 32'hFFFFFFFF;
    dtw = 16'hFFFF;
    din = 16'd0;

    /*************
     * READ MODE *
     *************/

    // Cycle 1
    #20;
    valid = 1;
    rw = 0;
    addri = 32'hFFFFFFFF;
    dtw = 16'd0;
    din = 16'hFFFF;

    // Cycle 2
    #20;
    valid = 1;
    rw = 0;
    addri = 32'hFFFFFFFF;
    dtw = 16'd0;
    din = 16'hFFFF;

    // Cycle 3
    #20;
    valid = 1;
    rw = 0;
    addri = 32'hFFFFFFFF;
    dtw = 16'd0;
    din = 16'd0;

    // Cycle 4
    #20;
    valid = 1;
    rw = 0;
    addri = 32'hFFFFFFFF;
    dtw = 16'd0;
    din = 16'd0;

    /**************
     * WRITE MODE *
     **************/

    // Cycle 1
    #20;
    valid = 1;
    rw = 1;
    addri = 32'hFFFFFFFF;
    dtw = 16'hFFFF;
    din = 16'd0;

    // Cycle 2
    #20;
    valid = 1;
    rw = 1;
    addri = 32'hFFFFFFFF;
    dtw = 16'hFFFF;
    din = 16'd0;

    // Cycle 3
    #20;
    valid = 1;
    rw = 1;
    addri = 32'hFFFFFFFF;
    dtw = 16'hFFFF;
    din = 16'd0;

    // Cycle 4
    #20;
    valid = 1;
    rw = 1;
    addri = 32'hFFFFFFFF;
    dtw = 16'hFFFF;
    din = 16'd0;
  `endif
endmodule