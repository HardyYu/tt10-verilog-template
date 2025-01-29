
module audio_player(
    input wire clk,
    input wire rst_n,
    input wire enable,
    output reg pwm
);
    wire [11:0] divider;

    jump_sound_player i_jump(
        .clk(clk),
        .rst_n(rst_n),
        .enable(enable),
        .divider(divider)
    );

    pwm_sine i_sine(
        .clk(clk),
        .rst_n(rst_n),
        .divider(divider),
        .pwm(pwm)
    );
    
endmodule


