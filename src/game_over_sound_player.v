`default_nettype none

module game_over_sound_player (
    input wire clk,        // 50 MHz clock input
    input wire rst_n,      // reset on the negative edge
    input wire is_over,     // Posedge edge to indicate game is over
    output reg wave_out    // Jump sound square wave output
);

    localparam [18:0] PERIOD = 19'd200000;   // Clock speed / Frequency -> 50MHz / 660Hz 

    reg [18:0] decay_values [0:15];  // Lookup table for precomputed decay values

    initial begin
        decay_values[0]  = 37878;
        decay_values[1]  = 33842;
        decay_values[2]  = 30208;
        decay_values[3]  = 26940;
        decay_values[4]  = 24008;
        decay_values[5]  = 21383;
        decay_values[6]  = 19043;
        decay_values[7]  = 16966;
        decay_values[8]  = 15135;
        decay_values[9]  = 13530;
        decay_values[10] = 12132;
        decay_values[11] = 10924;
        decay_values[12] = 9879;
        decay_values[13] = 8932;
        decay_values[14] = 8076;
        decay_values[15] = 7300;
    end

    reg [3:0] CCR_stages = 0;   // 30 stages of decay values
    reg [18:0] ARR_count = 0;   // 19-bit counter for a maximum period of 333333
    reg beep_stage = 0; // width of 1 because there are only two beeps
    reg active;

    reg prev_is_over;

    always @(posedge clk or posedge is_over ) begin
        prev_is_over <= is_over;

        if (!rst_n) begin // Detect negative level of rst_n
            CCR_stages <= 0;
            ARR_count <= 0;
            active <= 0;
            beep_stage <= 0;
            wave_out <= 0;
        end else if (!prev_is_over && is_over) begin // Detect rising edge of is_over
            active <= 1;
            CCR_stages <= 0;
            ARR_count <= 0;
            beep_stage <= 0;
            wave_out <= 0;
        end else if (active) begin  // running state
            if (beep_stage == 0) begin
                if (CCR_stages == 15) begin
                    CCR_stages <= 0;
                    beep_stage <= 1;
                end
            end else if (beep_stage == 1) begin
                if (CCR_stages == 15) begin
                    CCR_stages <= 0;
                    active <= 0;
                end
            end

            if (ARR_count >= PERIOD) begin // Start new cycle
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

        end else begin
            wave_out    <= 0;  // Turn off the square wave when inactive
            ARR_count  <= 0;  // Reset counters when inactive
        end
    end

endmodule