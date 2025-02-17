
module audio_interface(
    input wire clk,
    input wire rst_n,
    input wire game_is_over,
    input wire jump_pulse,
    output reg sound
);
    wire jump_sound;
    wire game_over_sound;

    always @(*) begin
        sound <= jump_sound | game_over_sound;
    end

    jump_sound_player i_jump(
        .clk(clk),
        .enable(~game_is_over),
        .sound_trigger(jump_pulse),
        .wave_out(jump_sound)
    );

    game_over_sound_player i_over(
        .clk(clk),
        .rst_n(rst_n),
        .is_over(game_is_over),
        .wave_out(game_over_sound)
    );

endmodule


