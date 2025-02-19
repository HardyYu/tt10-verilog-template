module jump_sound_player (
    input wire clk,             // 50 MHz clock
    input wire enable,          // Enable this module
    input wire sound_trigger,   // One-shot pulse signal to generate sound
    output reg wave_out         // Square wave output (registered)
);

    localparam [18:0] PWM_ARR_PERIOD = 19'd333333;

    // Define each decay value as a separate localparam
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

    reg [4:0]  CCR_stages = 0;
    reg [18:0] ARR_count = 0;
    reg        active = 0;
    reg        prev_sound_trigger = 0;

    always @(posedge clk) begin
        prev_sound_trigger <= sound_trigger;

        // Default to prevent latch inference
        wave_out <= 1'b0;

        if (!enable) begin
            active      <= 1'b0;
            CCR_stages  <= 5'd0;
            ARR_count   <= 19'd0;
        end 
        else if (prev_sound_trigger && !sound_trigger) begin
            active      <= 1'b1;
            CCR_stages  <= 5'd0;
            ARR_count   <= 19'd0;
        end 
        else if (active) begin
            if (ARR_count >= PWM_ARR_PERIOD) begin
                ARR_count  <= 19'd0;
                CCR_stages <= CCR_stages + 1'b1;
            end 
            else begin
                ARR_count <= ARR_count + 1'b1;
            end

            if (CCR_stages < 5'd30) begin
                case (CCR_stages)
                    5'd0:  wave_out <= (ARR_count < DECAY_0);
                    5'd1:  wave_out <= (ARR_count < DECAY_1);
                    5'd2:  wave_out <= (ARR_count < DECAY_2);
                    5'd3:  wave_out <= (ARR_count < DECAY_3);
                    5'd4:  wave_out <= (ARR_count < DECAY_4);
                    5'd5:  wave_out <= (ARR_count < DECAY_5);
                    5'd6:  wave_out <= (ARR_count < DECAY_6);
                    5'd7:  wave_out <= (ARR_count < DECAY_7);
                    5'd8:  wave_out <= (ARR_count < DECAY_8);
                    5'd9:  wave_out <= (ARR_count < DECAY_9);
                    5'd10: wave_out <= (ARR_count < DECAY_10);
                    5'd11: wave_out <= (ARR_count < DECAY_11);
                    5'd12: wave_out <= (ARR_count < DECAY_12);
                    5'd13: wave_out <= (ARR_count < DECAY_13);
                    5'd14: wave_out <= (ARR_count < DECAY_14);
                    5'd15: wave_out <= (ARR_count < DECAY_15);
                    5'd16: wave_out <= (ARR_count < DECAY_16);
                    5'd17: wave_out <= (ARR_count < DECAY_17);
                    5'd18: wave_out <= (ARR_count < DECAY_18);
                    5'd19: wave_out <= (ARR_count < DECAY_19);
                    5'd20: wave_out <= (ARR_count < DECAY_20);
                    5'd21: wave_out <= (ARR_count < DECAY_21);
                    5'd22: wave_out <= (ARR_count < DECAY_22);
                    5'd23: wave_out <= (ARR_count < DECAY_23);
                    5'd24: wave_out <= (ARR_count < DECAY_24);
                    5'd25: wave_out <= (ARR_count < DECAY_25);
                    5'd26: wave_out <= (ARR_count < DECAY_26);
                    5'd27: wave_out <= (ARR_count < DECAY_27);
                    5'd28: wave_out <= (ARR_count < DECAY_28);
                    5'd29: wave_out <= (ARR_count < DECAY_29);
                    5'd30: wave_out <= (ARR_count < DECAY_30);
                    default: wave_out <= 1'b0;
                endcase
            end 
            else begin
                active     <= 1'b0;
                CCR_stages <= 5'd0;
            end
        end 
        else begin
            ARR_count <= 19'd0;
        end
    end
endmodule
