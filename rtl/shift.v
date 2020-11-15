module shift (
    input wire[31:0] a,
    input wire[4:0] s,
    output wire[31:0] r
);
    assign r = a << s;
endmodule