/**
 * Fetches instructions from the memory arbiter and holds
 * them in an internal queue/fifo. The size of the queue
 * is PREFETCH_SIZE, currently 4 instructions.
*/

module hs32_fetch (
    input clk,                       // 12 MHz Clock
    input reset_n,                   // Active Low Reset

    // Memory arbiter interface
    output  reg  [31:0] addr,        // Address
    input   wire [31:0] dtr,         // Data input
    output  reg  reqm,               // Valid address
    input   wire ackm,               // Valid data

    // Decode
    output  wire [31:0] instd,       // Next instruction
    input   wire reqd,               // Valid input
    output  wire ackd,               // Valid output

    // Pipeline controller
    input   wire[31:0] newpc,        // New program counter
    input   wire flush               // Flush
);
    
    // Idk how this fifo works... sorry :C
    parameter PREFETCH_SIZE = 4;
    parameter PBITS = 2;             // Must be Log2 of PREFETCH_SIZE

    reg[31:0] pc;                    // Program counter

    // Fifo Logic, fill is size of fifo
    reg [PBITS:0] wp = 0, rp = 0, fill;
    reg full;
    reg[31:0] fifo[PREFETCH_SIZE:0];
    assign instd = fifo[rp];
    assign ackd = fill > 1;

    // Combinatorial logic to update the values of fill and full
    always @(*) fill = wp - rp;
    always @(*) full = fill == { 1'b1, {(PBITS) {1'b0}} };

    // Reset
    always @ (posedge clk, negedge reset_n, posedge flush) begin
      if (reset_n || flush) begin     // Check if reset_n or flush
          pc = 32'd0;                 // Set PC to 0
      end
    end

    // Set New PC
    always @(posedge clk, posedge newpc) begin
        if (newpc != 0) begin
            pc = newpc;
        end
    end

    // Request Instruction
    always @(posedge clk) begin
        reqm = 1'd1;
        addr = pc;
        pc++;
    end

    // Fetch instruction
    always @(posedge clk, posedge ackm) begin
        if (ackm) begin               // If data is valid
            // Get instruction from memory
        end
    end

    // Output Instruction to Decode
    always @(posedge clk, posedge reqd) begin
        if (reqd) begin               // If Decode Request Received
            // Activate Decode Input
            // Send Instruction
        end 
        else begin
            // Deactivate Decode Input
        end
    end
endmodule