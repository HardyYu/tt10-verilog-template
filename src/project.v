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

  // I will only use clk, rst_n as input, uio_out as output for now
  // Later on, we will have another signel to control when audio effect is played
  reg pwm;
  reg jump_enable;
  wire jump_wire;
  assign uio_out[7] = pwm;
  assign jump_wire = jump_enable;
  audio_player i_audio(
    .clk(clk),
    .rst_n(rst_n),
    .enable(jump_wire),
    .pwm(pwm)
  );

  localparam CLK_FREQ = 50_000_000; // 50 MHz
  localparam CYCLES_PER_JUMP = CLK_FREQ * 3; // Jump once per 3 seconds


  reg [31:0] jump_counter;
  always @(posedge clk) begin
      if (!rst_n) begin
          jump_counter <= 0;
          jump_enable <= 0;
      end 
      else if (jump_counter >= (CYCLES_PER_JUMP - 1)) begin
          jump_counter <= 0;
          jump_enable <= 1;
      end 
      else if (jump_counter < 3) begin
          jump_counter <= jump_counter + 1;
      end 
      else begin
          jump_counter <= jump_counter + 1;
          jump_enable <= 0;
      end
  end

  // All output pins must be assigned. If not used, assign to 0.
  assign uo_out  = 0;  // Example: ou_out is the sum of ui_in and uio_in
  assign uio_out[6:0] = 0;
  assign uio_oe  = 0;

  // List all unused inputs to prevent warnings
  wire _unused = &{ena, ui_in, uio_in, 1'b0};

endmodule
