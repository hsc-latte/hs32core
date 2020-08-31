module CPU (
    input CLK,    // 16MHz clock
    output LED,   // User/boot LED next to power LED
    output USBPU, // USB pull-up resistor
    // IO Pins
    inout PIN_1,  inout PIN_2,  inout PIN_3,  inout PIN_4,
    inout PIN_5,  inout PIN_6,  inout PIN_7,  inout PIN_8,
    inout PIN_9,  inout PIN_10, inout PIN_11, inout PIN_12,
    inout PIN_13, inout PIN_14, inout PIN_15, inout PIN_16,
    // Output pins
    output PIN_17, output PIN_18, output PIN_19, output PIN_20,
    output PIN_21, output PIN_22, output PIN_23, output PIN_24,
    // UART
    input PIN_25, output PIN_26
);
    // Nothing happens here :)
endmodule