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

    reg [4:0]  CCR_stages    = 0;
    reg [18:0] ARR_count     = 0;
    reg        active        = 0;
    reg        prev_sound_trigger = 0;
    reg        temp_wave_out = 0;

    // "Next state" signals
    reg [4:0]  next_CCR_stages;
    reg [18:0] next_ARR_count;
    reg        next_active;
    reg        next_temp_wave_out;
    reg        next_prev_sound_trigger;

    always @(*) begin
        // Default next values = hold current values
        next_CCR_stages       = CCR_stages;
        next_ARR_count        = ARR_count;
        next_active           = active;
        next_temp_wave_out    = temp_wave_out;
        next_prev_sound_trigger = sound_trigger;  // always track the current trigger

        if (enable) begin
            // Detect falling edge: (prev_sound_trigger == 1 && sound_trigger == 0)
            if ((prev_sound_trigger == 1'b1) && (sound_trigger == 1'b0)) begin
                next_active        = 1'b1;
                next_CCR_stages    = 5'd0;
                next_ARR_count     = 19'd0;
                next_temp_wave_out = 1'b0;
            end 
            else if (active) begin
                // If still active, handle ARR_count
                if (ARR_count >= PWM_ARR_PERIOD) begin
                    next_ARR_count     = 0;
                    next_CCR_stages    = CCR_stages + 1;
                end else begin
                    next_ARR_count     = ARR_count + 1;
                end

                // Update temp_wave_out based on decay stage
                case (CCR_stages)
                    0:  next_temp_wave_out = (ARR_count < DECAY_0);
                    1:  next_temp_wave_out = (ARR_count < DECAY_1);
                    2:  next_temp_wave_out = (ARR_count < DECAY_2);
                    3:  next_temp_wave_out = (ARR_count < DECAY_3);
                    // ...
                    29: next_temp_wave_out = (ARR_count < DECAY_29);
                    30: next_temp_wave_out = (ARR_count < DECAY_30);
                    default: next_temp_wave_out = 1'b0;
                endcase

                // If finished all decay stages, turn off
                if (CCR_stages == 5'd30) begin
                    next_CCR_stages    = 5'd0;
                    next_active        = 1'b0;
                    next_temp_wave_out = 1'b0;
                end

            end 
            else begin
                // Not active
                next_temp_wave_out = 1'b0;
                next_ARR_count     = 19'd0;
            end
        end
        else begin
            // If not enabled
            next_active        = 1'b0;
            next_CCR_stages    = 5'd0;
            next_ARR_count     = 19'd0;
            next_temp_wave_out = 1'b0;
        end
    end

    // Synchronous update of all registers
    always @(posedge clk) begin
        CCR_stages       <= next_CCR_stages;
        ARR_count        <= next_ARR_count;
        active           <= next_active;
        temp_wave_out    <= next_temp_wave_out;
        prev_sound_trigger <= next_prev_sound_trigger;
    end

    assign wave_out = temp_wave_out;

endmodule