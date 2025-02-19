module jump_sound_player (
    input wire clk,             // 50 MHz clock
    input wire enable,          // Enable this module
    input wire sound_trigger,   // One-shot pulse signal to generate sound
    output reg wave_out         // PWM output
);

    // Constants
    localparam integer SAMPLE_COUNT = 32;  // Number of sine samples
    localparam integer PWM_PERIOD   = 512; // PWM period for duty cycle

    // Registers
    reg [5:0]  sample_index = 0;  // Sine wave step
    reg [8:0]  pwm_counter = 0;   // PWM counter
    reg        playing = 0;       // Playback flag
    reg        prev_trigger = 0;  // Edge detection

    // Function to return sine sample
    function [8:0] sine_sample;
        input [5:0] index;
        case (index)
            6'd0:  sine_sample = 9'd0;
            6'd1:  sine_sample = 9'd25;
            6'd2:  sine_sample = 9'd50;
            6'd3:  sine_sample = 9'd74;
            6'd4:  sine_sample = 9'd98;
            6'd5:  sine_sample = 9'd120;
            6'd6:  sine_sample = 9'd141;
            6'd7:  sine_sample = 9'd161;
            6'd8:  sine_sample = 9'd180;
            6'd9:  sine_sample = 9'd197;
            6'd10: sine_sample = 9'd213;
            6'd11: sine_sample = 9'd226;
            6'd12: sine_sample = 9'd238;
            6'd13: sine_sample = 9'd248;
            6'd14: sine_sample = 9'd255;
            6'd15: sine_sample = 9'd260;
            6'd16: sine_sample = 9'd263;
            6'd17: sine_sample = 9'd265;
            6'd18: sine_sample = 9'd263;
            6'd19: sine_sample = 9'd260;
            6'd20: sine_sample = 9'd255;
            6'd21: sine_sample = 9'd248;
            6'd22: sine_sample = 9'd238;
            6'd23: sine_sample = 9'd226;
            6'd24: sine_sample = 9'd213;
            6'd25: sine_sample = 9'd197;
            6'd26: sine_sample = 9'd180;
            6'd27: sine_sample = 9'd161;
            6'd28: sine_sample = 9'd141;
            6'd29: sine_sample = 9'd120;
            6'd30: sine_sample = 9'd98;
            6'd31: sine_sample = 9'd74;
            default: sine_sample = 9'd0;
        endcase
    endfunction

    always @(posedge clk) begin
        prev_trigger <= sound_trigger;

        if (!enable) begin
            playing       <= 1'b0;
            sample_index  <= 0;
            pwm_counter   <= 0;
            wave_out      <= 0;
        end 
        else if (!prev_trigger && sound_trigger) begin
            playing      <= 1'b1;
            sample_index <= 0;
            pwm_counter  <= 0;
        end 
        else if (playing) begin
            if (pwm_counter < PWM_PERIOD) begin
                pwm_counter <= pwm_counter + 1;
            end else begin
                pwm_counter  <= 0;
                sample_index <= sample_index + 1;
            end

            if (sample_index < SAMPLE_COUNT) begin
                wave_out <= (pwm_counter < sine_sample(sample_index));
            end else begin
                playing  <= 1'b0;
                wave_out <= 1'b0;
            end
        end
    end
endmodule
