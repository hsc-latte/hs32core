// A UART serial receiver.

module UART_RX #(
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
  
  // UART serial input.
  input serial_i,

  // Data bus output.
  output reg [7:0] data_o = 8'h00,

  // Receiver has received a packet and will not overwrite `data_o` until the
  // data is acknowledged with `ack_i`.
  output reg ready_o = 1'b0,

  // Acknowledge byte received.
  input ack_i,

  // Use the parity bit if high, no parity if low.
  input parity_bit_i,

  // Use even parity if high, odd parity if low.
  input parity_even_i
);

localparam STATE_IDLE = 0;
localparam STATE_RECEIVE_PACKET = 1;
localparam STATE_VALIDATE_PACKET = 2;

localparam START_BIT_NUM = 6'd0;
localparam PARITY_BIT_NUM = 4'd9;

reg [1:0] state = STATE_IDLE;
reg [CLOCK_DIVIDER_WIDTH - 1:0] bit_timer = 0;
reg [5:0] select_packet_bit = 0;
reg parity_bit = 1'b0;
reg parity_even = 1'b0;
reg ack_has_triggered = 1'b0;
reg [11:0] packet = 12'h000;

wire [CLOCK_DIVIDER_WIDTH - 1:0] bit_timer_start_value = clock_divider_i - 1'd1;
wire [CLOCK_DIVIDER_WIDTH - 1:0] sample_position = clock_divider_i / 2'd2;
wire [3:0] total_bits_to_receive = 4'd10 + parity_bit;

wire start_bit_valid = packet[0] == 1'b0;

wire [3:0] stop_bit_offset = parity_bit ? PARITY_BIT_NUM + 1'd1 : PARITY_BIT_NUM;
wire stop_bit_valid = packet[stop_bit_offset] == 1'b1;

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

wire even_parity_valid = packet[PARITY_BIT_NUM] == even_parity_value;
wire odd_parity_valid = packet[PARITY_BIT_NUM] == ~even_parity_value;

wire parity_valid = parity_bit
  ? (parity_even ? even_parity_valid : odd_parity_valid)
  : 1'b1;

wire packet_valid =
  start_bit_valid &&
  parity_valid &&
  stop_bit_valid;

always @ (posedge clock_i) begin
  if (reset_i) begin
    state <= STATE_IDLE;
    data_o <= 8'h00;
    ready_o <= 1'b0;
    bit_timer <= 0;
    select_packet_bit <= 0;
    packet <= 12'h000;
    parity_bit <= 1'b0;
    parity_even <= 1'b0;
    ack_has_triggered <= 1'b0;
  end
  else begin
    if (!ack_i)
      ack_has_triggered <= 1'b0;

    if (ack_i && !ack_has_triggered) begin
      ready_o <= 1'b0;
      ack_has_triggered <= 1'b1;
    end

    case (state)
      STATE_IDLE:
        begin
          bit_timer <= bit_timer_start_value;
          select_packet_bit <= 0;

          if (!serial_i && clock_divider_i >= 2'd2) begin
            packet <= 12'h000;
            parity_bit <= parity_bit_i;
            parity_even <= parity_even_i;

            state <= STATE_RECEIVE_PACKET;
          end
        end

      STATE_RECEIVE_PACKET:
        begin
          if (bit_timer == sample_position) begin
            packet[select_packet_bit] <= serial_i;
            select_packet_bit <= select_packet_bit + 1'd1;

            if (select_packet_bit == START_BIT_NUM && serial_i == 1'b1)
              // Start bit not valid. May have triggered due to noise.
              state <= STATE_IDLE;
            else if (select_packet_bit >= total_bits_to_receive - 1'd1)
              state <= STATE_VALIDATE_PACKET;
          end

          if (bit_timer != 0)
            bit_timer <= bit_timer - 1'd1;
          else
            bit_timer <= bit_timer_start_value;
        end

      STATE_VALIDATE_PACKET:
        begin
          if (packet_valid && !ready_o) begin
            data_o <= packet[8:1];
            ready_o <= 1'b1;
          end

          state <= STATE_IDLE;
        end

      default:
        state <= STATE_IDLE;
    endcase
  end
end

endmodule
