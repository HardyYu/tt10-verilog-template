`default_nettype none

module jump_sound_player (
    input wire clk,        // 50 MHz clock input
    input wire enable,     // Signal to enable this module
    input wire sound_trigger,   // Pulse signal to generate sound
    output reg wave_out    // Jump sound square wave output
);

    localparam [18:0] PWM_ARR_PERIOD = 19'd333333;   // Clock speed / Frequency -> 50MHz / 150Hz 

    reg [18:0] decay_values [0:30];  // Lookup table for precomputed decay values

    initial begin
        decay_values[0] = 166666;
        decay_values[1] = 140522;
        decay_values[2] = 118300;
        decay_values[3] = 99999;
        decay_values[4] = 84313;
        decay_values[5] = 71241;
        decay_values[6] = 60130;
        decay_values[7] = 50326;
        decay_values[8] = 42483;
        decay_values[9] = 35947;
        decay_values[10] = 30065;
        decay_values[11] = 25490;
        decay_values[12] = 21568;
        decay_values[13] = 18300;
        decay_values[14] = 15032;
        decay_values[15] = 13071;
        decay_values[16] = 10457;
        decay_values[17] = 9150;
        decay_values[18] = 7843;
        decay_values[19] = 6535;
        decay_values[20] = 5228;
        decay_values[21] = 4575;
        decay_values[22] = 3921;
        decay_values[23] = 3267;
        decay_values[24] = 2614;
        decay_values[25] = 1960;
        decay_values[26] = 1960;
        decay_values[27] = 1307;
        decay_values[28] = 1307;
        decay_values[29] = 25;
    end

    reg [4:0] CCR_stages = 0;   // 30 stages of decay values
    reg [18:0] ARR_count = 0;   // 19-bit counter for a maximum period of 333333
    reg active;

    always @(posedge clk or negedge sound_trigger) begin
        if (enable) begin
            if (!sound_trigger) begin
                active <= 1;
                CCR_stages <= 0;
                ARR_count <= 0;
                wave_out <= 0;
            end else if (active)begin
                if (ARR_count >= PWM_ARR_PERIOD) begin // Start new cycle
                    ARR_count  <= 0;
                    wave_out    <= 1;
                    CCR_stages <= CCR_stages + 1;
                end else begin
                    ARR_count <= ARR_count + 1;
                end

                if (ARR_count < decay_values[CCR_stages]) begin
                    wave_out <= 1;  // Keep wave high
                end else begin
                    wave_out <= 0;  // Keep wave low
                end

                if (CCR_stages == 29 ) begin // Deactive when all stages are done
                    CCR_stages <= 0;
                    active <= 0;
                end
            end else begin
                wave_out    <= 0;  // Turn off the square wave when inactive
                ARR_count  <= 0;  // Reset counters when inactive
            end
        end else begin
            wave_out    <= 0;  // Turn off the square wave when inactive
            ARR_count  <= 0;  // Reset counters when inactive
        end

    end

endmodule