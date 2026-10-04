/*
 * Copyright (c) 2026 Brown Open Silicon
 * SPDX-License-Identifier: Apache-2.0
 *
 * Fixed-function UART transmitter (8N1, LSB first).
 * This is the "get a UART out of a pin" starting point. It gets replaced
 * by firmware running on the programmable pin engine later.
 */

`default_nettype none

module uart_tx #(
    parameter integer CLKS_PER_BIT = 434  // 50 MHz / 115200 baud
) (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       start,  // pulse high for one cycle to send `data`
    input  wire [7:0] data,
    output wire       tx,
    output wire       busy
);

  localparam integer CW = $clog2(CLKS_PER_BIT);
  localparam [CW-1:0] LAST = CLKS_PER_BIT[CW-1:0] - 1'b1;

  reg [9:0]    shreg;      // {stop, data[7:0], start}, shifted out LSB first
  reg [3:0]    bits_left;
  reg [CW-1:0] cnt;

  always @(posedge clk) begin
    if (!rst_n) begin
      shreg     <= 10'h3FF;  // line idles high
      bits_left <= 4'd0;
      cnt       <= {CW{1'b0}};
    end else if (bits_left == 4'd0) begin
      if (start) begin
        shreg     <= {1'b1, data, 1'b0};
        bits_left <= 4'd10;
        cnt       <= {CW{1'b0}};
      end
    end else if (cnt == LAST) begin
      cnt       <= {CW{1'b0}};
      shreg     <= {1'b1, shreg[9:1]};
      bits_left <= bits_left - 4'd1;
    end else begin
      cnt <= cnt + 1'b1;
    end
  end

  assign tx   = shreg[0];
  assign busy = (bits_left != 4'd0);

endmodule
