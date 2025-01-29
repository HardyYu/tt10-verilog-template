`default_nettype none

module jump_sound_player (
    input wire clk,
    input wire rst_n,
    input wire enable,               // Signal to trigger the jump sound effect

    output wire [11:0] divider      // Divider input for pwm_sine module
);

    // Define the number of steps in the jump sound sequence
    localparam NUM_STEPS = 9;

    // Define divider values for each step (replace with calculated dividers)
    localparam [11:0] DIVIDER_0 = 12'd129;  // 1500 Hz
    localparam [11:0] DIVIDER_1 = 12'd150;  // 1300 Hz
    localparam [11:0] DIVIDER_2 = 12'd176;  // 1100 Hz
    localparam [11:0] DIVIDER_3 = 12'd194;  // 1000 Hz
    localparam [11:0] DIVIDER_4 = 12'd216;  // 900 Hz
    localparam [11:0] DIVIDER_5 = 12'd243;  // 800 Hz
    localparam [11:0] DIVIDER_6 = 12'd275;  // 700 Hz
    localparam [11:0] DIVIDER_7 = 12'd324;  // 600 Hz
    localparam [11:0] DIVIDER_8 = 12'd389;  // 500 Hz

    // State Machine States
    localparam STATE_IDLE = 3'd0;
    localparam STATE_PLAY = 3'd1;
    localparam STATE_FINISH = 3'd2;

    reg [2:0] state, next_state;

    // Step Counter
    reg [3:0] step_idx;

    // Timing Control: Duration for each step in clock cycles
    // Assuming each step should last 100ms
    localparam STEP_DURATION_MS = 100; // Duration per step in milliseconds

    // Calculate the number of clock cycles per step
    // clk = 50MHz, so cycles_per_ms = 50,000
    localparam CLK_FREQ = 50_000_000; // 50 MHz
    localparam CYCLES_PER_MS = CLK_FREQ / 1_000; // 50,000 cycles/ms
    localparam CYCLES_PER_STEP = STEP_DURATION_MS * CYCLES_PER_MS; // 100 * 50,000 = 5,000,000

    reg [31:0] cycle_counter; // Needs to count up to 5,000,000 (~23 bits)

    // Output Divider Register
    reg [11:0] current_divider;

    assign divider = current_divider;

    // State Register
    always @(posedge clk) begin
        if (!rst_n)
            state <= STATE_IDLE;
        else
            state <= next_state;
    end

    reg start;

    // Next State Logic
    always @(*) begin
        case (state)
            STATE_IDLE: begin
                if (start)
                    next_state = STATE_PLAY;
                else
                    next_state = STATE_IDLE;
            end

            STATE_PLAY: begin
                if (step_idx == NUM_STEPS-1 && cycle_counter == CYCLES_PER_STEP - 1)
                    next_state = STATE_FINISH;
                else if (cycle_counter == CYCLES_PER_STEP - 1)
                    next_state = STATE_PLAY;
                else
                    next_state = STATE_PLAY;
            end

            STATE_FINISH: begin
                next_state = STATE_IDLE;
            end

            default: next_state = STATE_IDLE;
        endcase
    end

    // Step and Cycle Counter Logic
    always @(posedge clk or negedge enable) begin
        if (!rst_n) begin
            step_idx <= 0;
            cycle_counter <= 0;
            current_divider <= 12'd0;
            start <= 0;
        end else if (!enable) begin
            step_idx <= 0;
            cycle_counter <= 0;
            current_divider <= 12'd0;
            start <= 1;
        end else begin
            case (state)
                STATE_IDLE: begin
                    step_idx <= 0;
                    cycle_counter <= 0;
                    current_divider <= 12'd0;
                end

                STATE_PLAY: begin
                    if (cycle_counter < CYCLES_PER_STEP - 1) begin
                        cycle_counter <= cycle_counter + 1;
                    end
                    else begin
                        cycle_counter <= 0;
                        if (step_idx < NUM_STEPS-1)
                            step_idx <= step_idx + 1;
                        else
                            step_idx <= step_idx;
                    end

                    // Update divider based on current step
                    case (step_idx)
                        4'd0: current_divider <= DIVIDER_0;
                        4'd1: current_divider <= DIVIDER_1;
                        4'd2: current_divider <= DIVIDER_2;
                        4'd3: current_divider <= DIVIDER_3;
                        4'd4: current_divider <= DIVIDER_4;
                        4'd5: current_divider <= DIVIDER_5;
                        4'd6: current_divider <= DIVIDER_6;
                        4'd7: current_divider <= DIVIDER_7;
                        4'd8: current_divider <= DIVIDER_8;
                        default: current_divider <= 12'd0;
                    endcase
                end

                STATE_FINISH: begin
                    // Optionally, set divider to 0 or another default value
                    current_divider <= 12'd0;
                    start <= 0;
                end

                default: begin
                    step_idx <= 0;
                    cycle_counter <= 0;
                    current_divider <= 12'd0;
                    start <= 0;
                end
            endcase
        end
    end

endmodule
