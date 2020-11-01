module EXT_SRAM (
    input clk,

    // Request interface
    output  reg  done,
    input   wire valid,
    input   wire rw, // Write = 1
    input   wire[31:0] addri,
    input   wire[15:0] dtw,
    output  wire[15:0] dtr,

    // External IO, all active > HIGH <
    input   wire[15:0] din,
    output  reg [15:0] dout,
    output  reg we,
    output  reg oe,
    output  reg oe_negedge,
    output  reg ale0_negedge,
    output  reg ale1_negedge,
    output  reg bhe,
    output  reg isout
);
    assign dtr = din;
    reg[2:0] fsm = 3'b000;
    // For waveforms and cycle names, see CPU.md
    always @(posedge clk) case(fsm)
        // T1
        3'b000: begin
            fsm     <= { 2'b0, valid };
            dout    <= addri[16:1];
            isout   <= valid;
            done    <= 0;
        end
        // T2
        3'b001: begin
            fsm     <= { 3'b010 };
            // The BLE is active iff
            // we're in write mode and the LSB is zero
            dout    <= { !addri[0] & rw, addri[31:17] };
            we      <= rw;
            // Output enable only in read mode
            oe      <= !rw;
        end
        // TW (wait 1 cycle)
        3'b010: begin
            fsm     <= 3'b100;
            // I/O output mode only in write mode
            isout   <= rw;
            dout    <= rw ? dtw : 16'b0;
            // BHE is active iff
            // we're in write mode and the LSB is one
            bhe     <= addri[0] & rw;
        end
        // T3 (wait for oe_negedge)
        3'b100: begin
            fsm     <= 3'b000;
            done    <= 1;
            // No output during T3
            isout   <= 0;
        end
        // So Anthony doesn't complain
        default: begin
            fsm <= 3'b000;
        end
    endcase

    always @(negedge clk) case(fsm)
        // Before T1
        3'b000: begin
            oe_negedge   <= 0;
            ale0_negedge <= valid;
        end
        // Before T2
        3'b001: begin
            ale0_negedge <= 0;
            ale1_negedge <= 1;
        end
        // Before TW
        3'b010: begin
            oe_negedge   <= 0;
        end
        // So verilator doesn't complain
        default: begin end
    endcase
endmodule