module jump_sound_player (
    input wire clk,        // 50 MHz clock input
    input wire enable,     // Signal to enable this module
    input wire sound_trigger,   // Pulse signal to generate sound
    output reg wave_out    // Jump sound square wave output
);

    localparam [18:0] PWM_ARR_PERIOD = 19'd333333;   // Clock speed / Frequency -> 50MHz / 150Hz 

    // Declare individual localparam values for each stage of decay
    localparam [18:0] DECAY_0 = 19'd166666;
    localparam [18:0] DECAY_1 = 19'd140522;
    localparam [18:0] DECAY_2 = 19'd118300;
    localparam [18:0] DECAY_3 = 19'd99999;
    localparam [18:0] DECAY_4 = 19'd84313;
    localparam [18:0] DECAY_5 = 19'd71241;
    localparam [18:0] DECAY_6 = 19'd60130;
    localparam [18:0] DECAY_7 = 19'd50326;
    localparam [18:0] DECAY_8 = 19'd42483;
    localparam [18:0] DECAY_9 = 19'd35947;
    localparam [18:0] DECAY_10 = 19'd30065;
    localparam [18:0] DECAY_11 = 19'd25490;
    localparam [18:0] DECAY_12 = 19'd21568;
    localparam [18:0] DECAY_13 = 19'd18300;
    localparam [18:0] DECAY_14 = 19'd15032;
    localparam [18:0] DECAY_15 = 19'd13071;
    localparam [18:0] DECAY_16 = 19'd10457;
    localparam [18:0] DECAY_17 = 19'd9150;
    localparam [18:0] DECAY_18 = 19'd7843;
    localparam [18:0] DECAY_19 = 19'd6535;
    localparam [18:0] DECAY_20 = 19'd5228;
    localparam [18:0] DECAY_21 = 19'd4575;
    localparam [18:0] DECAY_22 = 19'd3921;
    localparam [18:0] DECAY_23 = 19'd3267;
    localparam [18:0] DECAY_24 = 19'd2614;
    localparam [18:0] DECAY_25 = 19'd1960;
    localparam [18:0] DECAY_26 = 19'd1960;
    localparam [18:0] DECAY_27 = 19'd1307;
    localparam [18:0] DECAY_28 = 19'd1307;
    localparam [18:0] DECAY_29 = 19'd25;
    localparam [18:0] DECAY_30 = 19'd25;

    reg [4:0] CCR_stages = 0;   // 30 stages of decay values
    reg [18:0] ARR_count = 0;   // 19-bit counter for a maximum period of 333333
    reg active = 0;
    reg prev_sound_trigger = 0;
    reg temp_wave_out; 

    always @(posedge clk) begin
        prev_sound_trigger <= sound_trigger;
        if (enable) begin
            if (prev_sound_trigger && !sound_trigger) begin
                active <= 1;
                CCR_stages <= 0;
                ARR_count <= 0;
                temp_wave_out <= 0;
            end else if (active) begin
                if (ARR_count >= PWM_ARR_PERIOD) begin // Start new cycle
                    ARR_count <= 0;
                    temp_wave_out <= 1;  // Set temp_wave_out to 1
                    CCR_stages <= CCR_stages + 1;
                end else begin
                    ARR_count <= ARR_count + 1;
                end

                // Use the localparam decay values instead of the array
                case (CCR_stages)
                    0: temp_wave_out <= (ARR_count < DECAY_0);
                    1: temp_wave_out <= (ARR_count < DECAY_1);
                    2: temp_wave_out <= (ARR_count < DECAY_2);
                    3: temp_wave_out <= (ARR_count < DECAY_3);
                    4: temp_wave_out <= (ARR_count < DECAY_4);
                    5: temp_wave_out <= (ARR_count < DECAY_5);
                    6: temp_wave_out <= (ARR_count < DECAY_6);
                    7: temp_wave_out <= (ARR_count < DECAY_7);
                    8: temp_wave_out <= (ARR_count < DECAY_8);
                    9: temp_wave_out <= (ARR_count < DECAY_9);
                    10: temp_wave_out <= (ARR_count < DECAY_10);
                    11: temp_wave_out <= (ARR_count < DECAY_11);
                    12: temp_wave_out <= (ARR_count < DECAY_12);
                    13: temp_wave_out <= (ARR_count < DECAY_13);
                    14: temp_wave_out <= (ARR_count < DECAY_14);
                    15: temp_wave_out <= (ARR_count < DECAY_15);
                    16: temp_wave_out <= (ARR_count < DECAY_16);
                    17: temp_wave_out <= (ARR_count < DECAY_17);
                    18: temp_wave_out <= (ARR_count < DECAY_18);
                    19: temp_wave_out <= (ARR_count < DECAY_19);
                    20: temp_wave_out <= (ARR_count < DECAY_20);
                    21: temp_wave_out <= (ARR_count < DECAY_21);
                    22: temp_wave_out <= (ARR_count < DECAY_22);
                    23: temp_wave_out <= (ARR_count < DECAY_23);
                    24: temp_wave_out <= (ARR_count < DECAY_24);
                    25: temp_wave_out <= (ARR_count < DECAY_25);
                    26: temp_wave_out <= (ARR_count < DECAY_26);
                    27: temp_wave_out <= (ARR_count < DECAY_27);
                    28: temp_wave_out <= (ARR_count < DECAY_28);
                    29: temp_wave_out <= (ARR_count < DECAY_29);
                    30: temp_wave_out <= (ARR_count < DECAY_30);
                    default: temp_wave_out <= 0;
                endcase

                if (CCR_stages == 30) begin // Deactivate when all stages are done
                    CCR_stages <= 0;
                    active <= 0;
                end
            end else begin
                temp_wave_out <= 0;  // Turn off the square wave when inactive
                ARR_count <= 0;  // Reset counters when inactive
            end
        end else begin
            temp_wave_out <= 0;  // Turn off the square wave when inactive
            ARR_count <= 0;  // Reset counters when inactive
        end
    end

    assign wave_out = temp_wave_out;  // Assign the final output

endmodule