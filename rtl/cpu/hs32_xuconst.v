// Control signals bit selects
`define CTL_d       ctlsig[15:14]
`define CTL_r       ctlsig[13   ]
`define CTL_s       ctlsig[12:10]
`define CTL_b       ctlsig[9:6  ]
`define CTL_i       ctlsig[5:4  ]
`define CTL_f       ctlsig[3    ]
`define CTL_l       ctlsig[2    ]
`define CTL_D       ctlsig[1    ]
`define CTL_B       ctlsig[0    ]

// Source signal types
`define CTL_s_xxx   3'b000
`define CTL_s_xix   3'b001
`define CTL_s_mix   3'b010
`define CTL_s_mnx   3'b011
`define CTL_s_xnx   3'b100
`define CTL_s_mid   3'b101
`define CTL_s_mnd   3'b110

// Destination signal types
`define CTL_d_none  2'b00
`define CTL_d_rd    2'b01
`define CTL_d_dt_ma 2'b10
`define CTL_d_ma    2'b11

// FSM States
`define IDLE        0
`define TB1         1
`define TB2         2
`define TR1         3
`define TR2         4
`define TW1         5
`define TM1         6
`define TM2         7
`define TW2         8

// MCR defines current machine mode
`define MCR_USR     mcr_s[2]
`define MCR_MDE     mcr_s[1]

// Mode check macros
`define IS_USR  (`MCR_USR == 1)
`define IS_SUP  (`MCR_USR == 0)
`define IS_INT  (`MCR_USR == 0 && `MCR_MDE == 1)
`define BANK_U  (`CTL_B == 1 && bank == 0)
`define BANK_S  (`CTL_B == 1 && bank == 1)
`define BANK_I  (`CTL_B == 1 && bank == 2)
