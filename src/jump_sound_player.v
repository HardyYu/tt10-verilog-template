module jump_sound_player (
    input wire clk,             // 50 MHz clock
    input wire enable,          // Enable this module
    input wire sound_trigger,   // One-shot pulse signal to generate sound
    output reg wave_out         // Square wave output (registered)
);

    localparam [18:0] PWM_ARR_PERIOD = 19'd333333;

    localparam [18:0] DECAY [0:30] = {
        19'd166666, 19'd140522, 19'd118300, 19'd99999, 19'd84313,
        19'd71241, 19'd60130, 19'd50326, 19'd42483, 19'd35947,
        19'd30065, 19'd25490, 19'd21568, 19'd18300, 19'd15032,
        19'd13071, 19'd10457, 19'd9150, 19'd7843, 19'd6535,
        19'd5228, 19'd4575, 19'd3921, 19'd3267, 19'd2614,
        19'd1960, 19'd1960, 19'd1307, 19'd1307, 19'd25, 19'd25
    };

    reg [4:0]  CCR_stages = 0;
    reg [18:0] ARR_count = 0;
    reg        active = 0;
    reg        prev_sound_trigger = 0;

    always @(posedge clk) begin
        prev_sound_trigger <= sound_trigger;

        if (!enable) begin
            active      <= 1'b0;
            CCR_stages  <= 5'd0;
            ARR_count   <= 19'd0;
            wave_out    <= 1'b0;
        end else if (prev_sound_trigger && !sound_trigger) begin
            active      <= 1'b1;
            CCR_stages  <= 5'd0;
            ARR_count   <= 19'd0;
            wave_out    <= 1'b0;
        end else if (active) begin
            if (CCR_stages == 5'd30) begin
                active     <= 1'b0;
                CCR_stages <= 5'd0;
                wave_out   <= 1'b0;
            end else begin
                if (ARR_count >= PWM_ARR_PERIOD) begin
                    ARR_count  <= 19'd0;
                    CCR_stages <= CCR_stages + 1'b1;
                end else begin
                    ARR_count <= ARR_count + 1'b1;
                end
                wave_out <= (ARR_count < DECAY[CCR_stages]);
            end
        end else begin
            ARR_count <= 19'd0;
            wave_out  <= 1'b0;
        end
    end
endmodule
