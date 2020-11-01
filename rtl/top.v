`ifdef SOC
    `include "soc/main.v"
`else
    `ifdef PROG
        `include "programmer/main.v"
    `else
        `include "frontend/main.v"
    `endif
`endif
