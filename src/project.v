/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_example (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);
  // All output pins must be assigned. If not used, assign to 0.
  assign uo_out  = 0;  // Example: ou_out is the sum of ui_in and uio_in
  assign uio_out[6:0] = 0;
  assign uio_oe  = 8'hff;

  reg jump_pulse;

  audio_interface i_audio_interface(
    .clk(clk),
    .rst_n(rst_n),
    .game_is_over(0),   // needs to be replaced
    .jump_pulse(jump_pulse),     // needs to be replaced
    .sound(uio_out[7])
  );

  reg [31:0] jump_counter;
  always @(posedge clk) begin
      if (!rst_n) begin
          jump_counter <= 0;
          jump_pulse <= 0;
      end 
      else if (jump_counter == 20) begin
          jump_pulse <= 0;
      end else if (jump_counter == 10) begin
          jump_pulse <= 1;
      end
      else 
        jump_counter <= jump_counter + 1;

  end

  // List all unused inputs to prevent warnings
  wire _unused = &{ena, ui_in, uio_in, 1'b0};

endmodule
