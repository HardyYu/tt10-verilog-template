`default_nettype none

module game_over_sound_player (
    input wire clk,        // 50 MHz clock input
    input wire rst_n,      // reset on the negative edge
    input wire is_over,     // Posedge edge to indicate game is over
    output reg wave_out    // Jump sound square wave output
);

    localparam [18:0] PERIOD = 19'd200000;   // Clock speed / Frequency -> 50MHz / 660Hz 

    // Distinct localparams for decay values
    localparam [18:0] DECAY_0  = 37878;
    localparam [18:0] DECAY_1  = 33842;
    localparam [18:0] DECAY_2  = 30208;
    localparam [18:0] DECAY_3  = 26940;
    localparam [18:0] DECAY_4  = 24008;
    localparam [18:0] DECAY_5  = 21383;
    localparam [18:0] DECAY_6  = 19043;
    localparam [18:0] DECAY_7  = 16966;
    localparam [18:0] DECAY_8  = 15135;
    localparam [18:0] DECAY_9  = 13530;
    localparam [18:0] DECAY_10 = 12132;
    localparam [18:0] DECAY_11 = 10924;
    localparam [18:0] DECAY_12 = 9879;
    localparam [18:0] DECAY_13 = 8932;
    localparam [18:0] DECAY_14 = 8076;
    localparam [18:0] DECAY_15 = 7300;

    reg [3:0] CCR_stages = 0;   // 16 stages of decay values
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

            // Use the distinct localparams instead of array lookup
            case (CCR_stages)
                4'd0: wave_out <= (ARR_count < DECAY_0)  ? 1 : 0;
                4'd1: wave_out <= (ARR_count < DECAY_1)  ? 1 : 0;
                4'd2: wave_out <= (ARR_count < DECAY_2)  ? 1 : 0;
                4'd3: wave_out <= (ARR_count < DECAY_3)  ? 1 : 0;
                4'd4: wave_out <= (ARR_count < DECAY_4)  ? 1 : 0;
                4'd5: wave_out <= (ARR_count < DECAY_5)  ? 1 : 0;
                4'd6: wave_out <= (ARR_count < DECAY_6)  ? 1 : 0;
                4'd7: wave_out <= (ARR_count < DECAY_7)  ? 1 : 0;
                4'd8: wave_out <= (ARR_count < DECAY_8)  ? 1 : 0;
                4'd9: wave_out <= (ARR_count < DECAY_9)  ? 1 : 0;
                4'd10: wave_out <= (ARR_count < DECAY_10) ? 1 : 0;
                4'd11: wave_out <= (ARR_count < DECAY_11) ? 1 : 0;
                4'd12: wave_out <= (ARR_count < DECAY_12) ? 1 : 0;
                4'd13: wave_out <= (ARR_count < DECAY_13) ? 1 : 0;
                4'd14: wave_out <= (ARR_count < DECAY_14) ? 1 : 0;
                4'd15: wave_out <= (ARR_count < DECAY_15) ? 1 : 0;
            endcase

        end else begin
            wave_out    <= 0;  // Turn off the square wave when inactive
            ARR_count  <= 0;  // Reset counters when inactive
        end
    end

endmodule
