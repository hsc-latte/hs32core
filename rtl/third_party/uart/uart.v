// A UART serial transceiver.
`include "third_party/uart/uart_tx.v"
`include "third_party/uart/uart_rx.v"

module UART #(
  // Tune the clock divider bit width to your design to avoid wasting gates.
  // 
  // Example:
  // Assuming a 10MHz clock and a desired baud rate of 115200, the divider
  // value is 87. 87 fits into 7 bits, and therefore `CLOCK_DIVIDER_WIDTH`
  // in this instance can be set to 7.
  parameter CLOCK_DIVIDER_WIDTH = 16
) (
  // Module reset.
  input reset_i,

  // Clock input.
  input clock_i,

  // Divides the `clock_i` signal to achieve the desired baud rate. This value
  // must be a minimum of 2 for the receiver to operate.
  input [CLOCK_DIVIDER_WIDTH - 1:0] clock_divider_i,

  // UART serial input (receive).
  input serial_i,

  // UART serial output (transmit).
  output serial_o,

  // Data bus input (to transmitter).
  input [7:0] data_i,

  // Data bus output (from receiver).
  output [7:0] data_o,

  // Write a byte to transmit. Must go low after each write.
  input write_i,

  // Transmitter is busy and will not accept another write.
  output write_busy_o,

  // Receiver has received a packet and will not overwrite `data_o` until the
  // data is acknowledged with `ack_i`.
  output read_ready_o,

  // Acknowledge byte received.
  input ack_i,

  // Transmit two stop bits if high, one stop bit if low.
  input two_stop_bits_i,

  // Use the parity bit if high, no parity if low.
  input parity_bit_i,

  // Use even parity if high, odd parity if low.
  input parity_even_i
);

UART_TX #(
  .CLOCK_DIVIDER_WIDTH(CLOCK_DIVIDER_WIDTH)
)
uart_tx (
  .reset_i(reset_i),
  .clock_i(clock_i),
  .write_i(write_i),
  .two_stop_bits_i(two_stop_bits_i),
  .parity_bit_i(parity_bit_i),
  .parity_even_i(parity_even_i),
  .clock_divider_i(clock_divider_i),
  .data_i(data_i),
  .busy_o(write_busy_o),
  .serial_o(serial_o)
);

UART_RX #(
  .CLOCK_DIVIDER_WIDTH(CLOCK_DIVIDER_WIDTH)
)
uart_rx (
  .reset_i(reset_i),
  .clock_i(clock_i),
  .ack_i(ack_i),
  .parity_bit_i(parity_bit_i),
  .parity_even_i(parity_even_i),
  .serial_i(serial_i),
  .clock_divider_i(clock_divider_i),
  .data_o(data_o),
  .ready_o(read_ready_o)
);

endmodule
