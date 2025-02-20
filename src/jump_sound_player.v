module jump_sound_player (
    input wire clk,             // 50 MHz clock
    input wire enable,          // Enable this module
    input wire sound_trigger,   // One-shot pulse signal to generate sound
    output reg wave_out         // Square wave output (registered)
);

    localparam [18:0] PWM_ARR_PERIOD = 19'd333333;

    // Decay stages
    localparam [18:0] DECAY [0:30] = '{19'd166666, 19'd140522, 19'd118300, 19'd99999, 19'd84313, 19'd71241,  19'd60130,  19'd50326,  19'd42483, 19'd35947, 19'd30065,  19'd25490,  19'd21568,  19'd18300, 19'd15032, 19'd13071,  19'd10457,  19'd9150,   19'd7843,  19'd6535,        19'd5228,   19'd4575,   19'd3921,   19'd3267,  19'd2614,   19'd1960,   19'd1960,   19'd1307,   19'd1307,  19'd25,        19'd25 };

    // State machine states
    typedef enum logic [1:0] {
        IDLE  = 2'b00,
        PLAY  = 2'b01,
        DONE  = 2'b10
    } state_t;

    state_t state = IDLE;
    
    reg [4:0]  stage_index = 0;  // Decay stage index
    reg [18:0] counter     = 0;  // PWM period counter
    reg        active      = 0;  // Active flag

    // State Machine
    always @(posedge clk) begin
        if (!enable) begin
            state       <= IDLE;
            active      <= 0;
            stage_index <= 0;
            wave_out    <= 0;
        end
        else begin
            case (state)
                IDLE: begin
                    if (sound_trigger) begin
                        state       <= PLAY;
                        active      <= 1;
                        stage_index <= 0;
                        counter     <= 0;
                        wave_out    <= 1;
                    end
                end
                
                PLAY: begin
                    if (counter >= DECAY[stage_index]) begin
                        wave_out <= 0;  // Toggle waveform
                        counter  <= 0;
                    end
                    else begin
                        counter <= counter + 1;
                    end

                    if (counter >= PWM_ARR_PERIOD) begin  // Once we complete a full cycle
                        if (stage_index < 30)
                            wave_out    <= 1;
                            stage_index <= stage_index + 1;
                        else
                            state <= DONE;
                    end
                end
                
                DONE: begin
                    active   <= 0;
                    wave_out <= 0;
                    state    <= IDLE;
                end
                
                default: state <= IDLE;
            endcase
        end
    end
endmodule