module jump_sound_player (
    input wire clk,             // 50 MHz clock
    input wire enable,          // Enable this module
    input wire sound_trigger,   // One-shot trigger pulse to generate sound
    output reg wave_out         // Square wave output
);

    // Example: 50,000,000 / 150Hz = 333333
    localparam [18:0] PWM_ARR_PERIOD = 19'd333333; 

    // Declare localparams for decay stages
    localparam [18:0] DECAY_0  = 19'd166666;
    localparam [18:0] DECAY_1  = 19'd140522;
    localparam [18:0] DECAY_2  = 19'd118300;
    localparam [18:0] DECAY_3  = 19'd99999;
    localparam [18:0] DECAY_4  = 19'd84313;
    localparam [18:0] DECAY_5  = 19'd71241;
    localparam [18:0] DECAY_6  = 19'd60130;
    localparam [18:0] DECAY_7  = 19'd50326;
    localparam [18:0] DECAY_8  = 19'd42483;
    localparam [18:0] DECAY_9  = 19'd35947;
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

    // Registers
    reg [4:0]  CCR_stages = 0; 
    reg [18:0] ARR_count  = 0; 
    reg        active     = 0;
    reg        prev_sound_trigger = 0; 

    //----------------------------------------------------------------------
    // SINGLE SYNCHRONOUS ALWAYS BLOCK
    //---------------------------------------------------------------------- 
    always @(posedge clk) begin
        // Keep track of sound_trigger so we can detect falling edge
        prev_sound_trigger <= sound_trigger;

        if (enable) begin

            // Falling edge detection: previous=1, now=0
            if (prev_sound_trigger && !sound_trigger) begin
                // Start the sound
                active     <= 1'b1;
                CCR_stages <= 5'd0;
                ARR_count  <= 19'd0;
                wave_out   <= 1'b0; // can init to 0
            end 
            else if (active) begin
                // If active, update counter
                if (ARR_count >= PWM_ARR_PERIOD) begin
                    ARR_count  <= 19'd0;
                    CCR_stages <= CCR_stages + 1'b1;
                end 
                else begin
                    ARR_count <= ARR_count + 1'b1;
                end

                // Synthesize the wave based on stage
                case (CCR_stages)
                    0:  wave_out <= (ARR_count < DECAY_0);
                    1:  wave_out <= (ARR_count < DECAY_1);
                    2:  wave_out <= (ARR_count < DECAY_2);
                    3:  wave_out <= (ARR_count < DECAY_3);
                    4:  wave_out <= (ARR_count < DECAY_4);
                    5:  wave_out <= (ARR_count < DECAY_5);
                    6:  wave_out <= (ARR_count < DECAY_6);
                    7:  wave_out <= (ARR_count < DECAY_7);
                    8:  wave_out <= (ARR_count < DECAY_8);
                    9:  wave_out <= (ARR_count < DECAY_9);
                    10: wave_out <= (ARR_count < DECAY_10);
                    11: wave_out <= (ARR_count < DECAY_11);
                    12: wave_out <= (ARR_count < DECAY_12);
                    13: wave_out <= (ARR_count < DECAY_13);
                    14: wave_out <= (ARR_count < DECAY_14);
                    15: wave_out <= (ARR_count < DECAY_15);
                    16: wave_out <= (ARR_count < DECAY_16);
                    17: wave_out <= (ARR_count < DECAY_17);
                    18: wave_out <= (ARR_count < DECAY_18);
                    19: wave_out <= (ARR_count < DECAY_19);
                    20: wave_out <= (ARR_count < DECAY_20);
                    21: wave_out <= (ARR_count < DECAY_21);
                    22: wave_out <= (ARR_count < DECAY_22);
                    23: wave_out <= (ARR_count < DECAY_23);
                    24: wave_out <= (ARR_count < DECAY_24);
                    25: wave_out <= (ARR_count < DECAY_25);
                    26: wave_out <= (ARR_count < DECAY_26);
                    27: wave_out <= (ARR_count < DECAY_27);
                    28: wave_out <= (ARR_count < DECAY_28);
                    29: wave_out <= (ARR_count < DECAY_29);
                    30: wave_out <= (ARR_count < DECAY_30);
                    default: wave_out <= 1'b0;
                endcase

                // If we've completed all stages, stop
                if (CCR_stages == 5'd30) begin
                    CCR_stages <= 5'd0;
                    active     <= 1'b0;
                    wave_out   <= 1'b0;
                end

            end 
            else begin
                // Not active
                ARR_count  <= 19'd0;
                wave_out   <= 1'b0;
            end

        end 
        else begin
            // If not enabled, reset everything
            active     <= 1'b0;
            CCR_stages <= 5'd0;
            ARR_count  <= 19'd0;
            wave_out   <= 1'b0;
        end
    end

endmodule
