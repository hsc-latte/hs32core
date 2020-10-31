`ifdef SoC
    `include "soc/main.v"
`else
    `include "frontend/main.v"
`endif
