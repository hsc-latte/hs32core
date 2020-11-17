`ifdef FORMAL
    `include "bram.v"
`else
    `include "soc/bram.v"
`endif

module soc_bram_ctl (
    input   wire clk,
    input   wire[addr_width-1:0] addr,
    output  wire[31:0] dread,
    input   wire[31:0] dwrite,
    input   wire rw,
    input   wire valid,
    output  reg  done
);
    parameter addr_width = 8;
    initial done = 0;

    // 4 addresses for each bram
    // Selects between current dword and next dword
    wire [addr_width-3:0] a0, a1, a2, a3;
    assign a0 = (addr[1:0] == 2'b00) ?
        addr[addr_width-1:2] : addr[addr_width-1:2] + 1;
    assign a1 = (addr[1:0] == 2'b00) || (addr[1:0] == 2'b01) ?
        addr[addr_width-1:2] : addr[addr_width-1:2] + 1;
    assign a2 = (addr[1:0] == 2'b11) ?
        addr[addr_width-1:2] + 1 : addr[addr_width-1:2];
    assign a3 = addr[addr_width-1:2];
    //
    // The read buffer shifted over.
    // Regarding the ending 2 bits of the address:
    // x = read, . = ignore
    //       a'  a'+1   -> where a' = addr[addr_width-1:2]
    // 00 [xxxx][....]
    // 01 [.xxx][x...]
    // 10 [..xx][xx..]
    // 11 [...x][xxx.]
    //     0123  0123   -> bram# the byte came from
    // dbuf will always be in the form of [0123]
    // So, an address ending in 11 should be [3012]
    //
    wire[31:0] dread_wire;
    wire[31:0] dbuf, wbuf;
    assign dread =
        (addr[1:0] == 2'b00) ? { dbuf[31:0] } :
        (addr[1:0] == 2'b01) ? { dbuf[ 7:0], dbuf[31:8 ] } :
        (addr[1:0] == 2'b10) ? { dbuf[15:0], dbuf[31:16] } :
                               { dbuf[23:0], dbuf[31:24] } ;
    assign wbuf =
        (addr[1:0] == 2'b00) ? { dwrite[31:0] } :
        (addr[1:0] == 2'b01) ? { dwrite[ 7:0], dwrite[31:8 ] } :
        (addr[1:0] == 2'b10) ? { dwrite[15:0], dwrite[31:16] } :
                               { dwrite[23:0], dwrite[31:24] } ;

    // Write enable signal
    wire we; assign we = valid & rw;

    // FSM (needed?)
    reg[1:0] state = 0;
    always @(posedge clk) case(state)
        0: begin 
            if(valid) begin
                state <= 1;
            end
            done <= 0;
        end
        1: state <= 2;
        2: begin
            state <= 0;
            done <= 1;
        end
    endcase

    // 4 brams, each controlled by 1 address line
    soc_bram #(
        .addr_width(addr_width-2),
        .data_width(8)
    ) ice40_bram0(
        .clk(clk), .we(we), 
        .addr(a0), .din(wbuf[7:0]), .dout(dbuf[7:0])
    );
    soc_bram #(
        .addr_width(addr_width-2),
        .data_width(8)
    ) ice40_bram1(
        .clk(clk), .we(we), 
        .addr(a1), .din(wbuf[15:8]), .dout(dbuf[15:8])
    );
    soc_bram #(
        .addr_width(addr_width-2),
        .data_width(8)
    ) ice40_bram2(
        .clk(clk), .we(we), 
        .addr(a2), .din(wbuf[23:16]), .dout(dbuf[23:16])
    );
    soc_bram #(
        .addr_width(addr_width-2),
        .data_width(8)
    ) ice40_bram3(
        .clk(clk), .we(we), 
        .addr(a3), .din(wbuf[31:24]), .dout(dbuf[31:24])
    );

    /** FORMAL METHODS **/

`ifdef FORMAL
    // $past gaurd
    reg f_past_valid;
    initial f_past_valid = 0;
    always @(posedge clk)
        f_past_valid <= 1;
    
    // 1. Always assume data valid
    always @(*) begin
        assume(valid);
    end

    // 2. Formal bus interface contract
    always @(posedge clk)
    if(f_past_valid)
        if(!$fell(done))
            assume($stable(addr) && $stable(dwrite) && $stable(rw));

    // 3. Cover checks if done resets
    always @(posedge clk)
    if(f_past_valid)
        cover($fell(done));

    // 4. Formal contract
    // -- if write bytes [1234] to a
    // -> then read a   == [1234]
    // -> then read a+1 == [?123]
    // -> then read a+2 == [??12]
    // -> then read a+3 == [???1]
    (* anyconst *) reg[addr_width-1:0] f_addr;
    (* anyconst *) reg[31:0] f_data;
    reg[2:0] f_state;
    initial f_state = 0;
    always @(posedge clk)
    case(f_state)
        // 1. Write to address
        0: if(rw && f_addr == addr && f_data == dwrite)
            f_state <= 1;
        // 2. Read from same address
        1: if(done)
            f_state <= !rw && f_addr == addr ? 2 : 0;
        // 3. Read from a+1
        2: if(done)
            f_state <= !rw && f_addr == addr+1 ? 3 : 0;
        // 4. Read from a+2
        3: if(done)
            f_state <= !rw && f_addr == addr+2 ? 4 : 0;
        // 5. Read from a+3
        4: if(done)
            f_state <= !rw && f_addr == addr+3 ? 5 : 0;
        // Good job!
        5: if(done) f_state <= 6;
        6: f_state <= 0;
    endcase

    // 2. Check if we read the same data back
    always @(posedge clk)
    if(f_state == 2 && done) begin
        assert(f_data == dread);
    end

    // 3. a+1 (check byte addressing)
    always @(posedge clk)
    if(f_state == 3 && done) begin
        assert(f_data[31:8] == dread[23:0]);
    end

    // 4. a+2
    always @(posedge clk)
    if(f_state == 4 && done) begin
        assert(f_data[31:16] == dread[15:0]);
    end

    // 5. a+3
    always @(posedge clk)
    if(f_state == 5 && done) begin
        assert(f_data[31:24] == dread[7:0]);
    end
`endif
endmodule