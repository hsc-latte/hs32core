/**
 * Copyright (c) 2020 The HSC Core Authors
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 *     https://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * 
 * @file   tb_sram.v
 * @author Anthony Kung <hi@anth.dev>
 * @author Kevin Dai <kevindai02@outlook.com>
 * @date   Created on November 01 2020, 12:40 AM
 */

`ifdef SIM
`include "frontend/sram.v"
`timescale 1ns / 100ps
module tb_sram;

  reg clk;
  reg valid;          // Valid
  reg rw;             // Read/Write Write = 1
  reg [31:0] addri;   // Address
  reg [15:0] dtw;     // Data to write
  reg [15:0] din;     // Data in

  initial begin
    clk = 0;
    #10
    forever clk = #10 ~clk;
  end

  initial begin
    $dumpfile("sram_tb.vcd");
    $dumpvars(0,sram);

    // Initial Reset
    $display("%0t, Reset", $time);
    clk = 0;
    valid = 0;
    rw = 0;
    addri = 32'd0;
    dtw = 16'd0;
    din = 16'd0;

    repeat (10) begin
      /*************
       * READ MODE *
       *************/
      $display("%0t, READ MODE", $time);

      // Cycle 1
      $display("%0t, Cycle 1", $time);
      @ (posedge clk);
      valid = 1;
      rw = 0;
      addri = 32'hFFFFFFFF;
      dtw = 16'd0;
      din = 16'd0;

      // Cycle 2
      $display("%0t, Cycle 2", $time);
      @ (posedge clk);
      valid = 1;
      rw = 0;
      addri = 32'hFFFFFFFF;
      dtw = 16'd0;
      din = 16'd0;

      // Cycle 3
      $display("%0t, Cycle 3", $time);
      @ (posedge clk);
      valid = 1;
      rw = 0;
      addri = 32'd0;
      dtw = 16'd0;
      din = 16'hFFFF;

      // Cycle 4
      $display("%0t, Cycle 4", $time);
      @ (posedge clk);
      valid = 0;
      rw = 0;
      addri = 32'd0;
      dtw = 16'd0;
      din = 16'd0;

      /**************
       * WRITE MODE *
       **************/

      // Cycle 1
      @ (posedge clk);
      valid = 1;
      rw = 1;
      addri = 32'hFFFFFFFF;
      dtw = 16'hFFFF;
      din = 16'd0;

      // Cycle 2
      @ (posedge clk);
      valid = 1;
      rw = 1;
      addri = 32'hFFFFFFFF;
      dtw = 16'hFFFF;
      din = 16'd0;

      // Cycle 3
      @ (posedge clk);
      valid = 1;
      rw = 1;
      addri = 32'hFFFFFFFF;
      dtw = 16'hFFFF;
      din = 16'd0;

      // Cycle 4
      @ (posedge clk);
      valid = 0;
      rw = 0;
      addri = 32'd0;
      dtw = 16'd0;
      din = 16'd0;
    end
    $finish;
  end

  EXT_SRAM sram(
    .clk(clk),
    .valid(valid),
    .rw(rw),
    .addri(addri),
    .dtw(dtw),
    .din(din)
  );
endmodule
`endif
