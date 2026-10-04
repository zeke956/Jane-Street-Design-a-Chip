/*
 * Copyright (c) 2026 Brown Open Silicon
 * SPDX-License-Identifier: Apache-2.0
 *
 * Top level for the protocol emulator ASIC.
 *
 * Milestone 0: fixed UART TX. Put a byte on ui_in, pulse uio[0] high,
 * and the byte comes out of uo[0] at 115200 baud (50 MHz clock).
 */

`default_nettype none

module tt_um_bos_protocol_emu (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

  // uio[0] is an async button/pin, so synchronize it and detect the rising edge
  reg [2:0] send_sync;
  always @(posedge clk) begin
    if (!rst_n) send_sync <= 3'b000;
    else        send_sync <= {send_sync[1:0], uio_in[0]};
  end
  wire send_pulse = send_sync[1] & ~send_sync[2];

  wire tx, busy;

  uart_tx #(.CLKS_PER_BIT(434)) u_uart_tx (
      .clk  (clk),
      .rst_n(rst_n),
      .start(send_pulse),
      .data (ui_in),
      .tx   (tx),
      .busy (busy)
  );

  assign uo_out  = {6'b0, busy, tx};
  assign uio_out = 8'b0;
  assign uio_oe  = 8'b0;  // all uio pins are inputs for now

  wire _unused = &{ena, uio_in[7:1], 1'b0};

endmodule
