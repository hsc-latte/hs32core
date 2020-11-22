// A UART serial transmitter.

module UART_TX #(
  parameter CLOCK_DIVIDER_WIDTH = 16
) (
  // Module reset.
  input reset_i,

  // Clock input.
  input clock_i,

  // Divides the `clock_i` signal to achieve the desired baud rate.
  // The transmitter can operate with a divider value of 1. A value of 0
  // implies 1.
  input [CLOCK_DIVIDER_WIDTH - 1:0] clock_divider_i,

  // UART serial output.
  output reg serial_o,

  // Data bus input.
  input [7:0] data_i,

  // Write a byte to transmit. Must go low after each write.
  input write_i,

  // Transmitter is busy and will not accept another write.
  output busy_o,
  
  // Transmit two stop bits if high, one stop bit if low.
  input two_stop_bits_i,

  // Use the parity bit if high, no parity if low.
  input parity_bit_i,

  // Use even parity if high, odd parity if low.
  input parity_even_i
);

localparam STATE_POST_RESET = 0;
localparam STATE_IDLE = 1;
localparam STATE_SEND_PACKET = 2;

reg [1:0] state = STATE_POST_RESET;
reg [CLOCK_DIVIDER_WIDTH - 1:0] bit_timer = 0;
reg [3:0] select_packet_bit = 0;
reg [7:0] data = 8'h00;
reg two_stop_bits = 1'b0;
reg parity_bit = 1'b0;
reg parity_even = 1'b0;
reg write_has_triggered = 1'b0;

wire [11:0] packet;
wire [CLOCK_DIVIDER_WIDTH - 1:0] clock_divider;
wire [CLOCK_DIVIDER_WIDTH - 1:0] bit_timer_start_value;
wire [3:0] total_bits_to_send = 4'd10 + two_stop_bits + parity_bit;
wire even_parity_value =
  1'h01 & (
    packet[8] +
    packet[7] +
    packet[6] +
    packet[5] +
    packet[4] +
    packet[3] +
    packet[2] +
    packet[1]
  );

assign busy_o = (state == STATE_IDLE && !reset_i) ? 1'b0 : 1'b1;
assign clock_divider = (clock_divider_i > 0) ? clock_divider_i - 1'd1 : 1'd0;
assign bit_timer_start_value = clock_divider;

assign packet[0] = 1'b0; // Start bit
assign packet[8:1] = data;
assign packet[9] = parity_bit
  ? (parity_even ? even_parity_value : ~even_parity_value) // Parity bit
  : 1'b1; // Stop bit
assign packet[11:10] = 2'b11; // Definitely stop bits

always @ (posedge clock_i) begin
  if (reset_i) begin
    state <= STATE_POST_RESET;
    serial_o <= 1'b1;
    bit_timer <= bit_timer_start_value;
    select_packet_bit <= 0;
    data <= 8'h00;
    two_stop_bits <= 1'b0;
    parity_bit <= 1'b0;
    parity_even <= 1'b0;
    write_has_triggered <= 1'b0;
  end
  else begin
    if (!write_i)
      write_has_triggered <= 1'b0;

    case (state)
      // This state delays operation for the length of 1 packet so that if the
      // module was reset in the middle of transmission the receiving side
      // will time out.
      STATE_POST_RESET:
        if (bit_timer != 0) begin
          bit_timer <= bit_timer - 1'd1;
        end
        // Reusing `select_packet_bit` as an overall bit counter for the packet.
        else if (select_packet_bit < 4'd12) begin
          bit_timer <= bit_timer_start_value;
          select_packet_bit <= select_packet_bit + 1'd1;
        end
        else begin
          state <= STATE_IDLE;
        end

      STATE_IDLE:
        begin
          serial_o <= 1'b1;
          bit_timer <= bit_timer_start_value;
          select_packet_bit <= 0;

          if (write_i && !write_has_triggered) begin
            data <= data_i;
            two_stop_bits <= two_stop_bits_i;
            parity_bit <= parity_bit_i;
            parity_even <= parity_even_i;
            write_has_triggered <= 1'b1;

            state <= STATE_SEND_PACKET;
          end
        end

      STATE_SEND_PACKET:
        if (select_packet_bit < total_bits_to_send) begin
          serial_o <= packet[select_packet_bit];

          if (bit_timer != 0) begin
            bit_timer <= bit_timer - 1'd1;
          end
          else begin
            bit_timer <= bit_timer_start_value;
            select_packet_bit <= select_packet_bit + 1'd1;
          end
        end
        else begin
          state <= STATE_IDLE;
        end

      default:
        state <= STATE_IDLE;
    endcase
  end
end

endmodule
