package main

import rl "vendor:raylib"
import "core:math"

game_over_timer: f32 = 0.0

game_over_exit_alpha: u8 = 180.0

exit_pos: rl.Vector2
exit_measure: rl.Vector2

game_over_update :: proc() {
    game_over_timer += rl.GetFrameTime()

    exit_pos = rl.Vector2{
        auto_cast (VIRTUAL_WIDTH / 2 - rl.MeasureText("EXIT", 24) / 2),
        VIRTUAL_HEIGHT / 2 + rl.MeasureTextEx(font, "GAME OVER", 56, 0).y / 2
    }

    exit_measure = rl.Vector2{
        auto_cast rl.MeasureText("EXIT", 24),
        auto_cast rl.MeasureTextEx(font, "GAME OVER", 56, 0).y
    }

    if rl.CheckCollisionPointRec(mouse_screen_position, {
        x = exit_pos.x,
        y = exit_pos.y,
        width = exit_measure.x,
        height = exit_measure.y
    }) {
        game_over_exit_alpha = 225
        if rl.IsMouseButtonPressed(.LEFT) {
            window_should_close = true
            return
        }
    } else {
        game_over_exit_alpha = 180
    }
}

game_over_render :: proc() {
    rl.ClearBackground(COLOR_PURPLE)

    y_scale := math.sin(game_over_timer)
    game_over_text := rl.TextFormat("GAME OVER")
    fontsize := 56 + (3 * y_scale)
    game_over_measure := rl.MeasureTextEx(font, game_over_text, fontsize, 0)
    rl.DrawTextEx(font, game_over_text, {
        VIRTUAL_WIDTH / 2 - game_over_measure.x / 2,
        VIRTUAL_HEIGHT / 2 - game_over_measure.y / 2 - 20
    }, fontsize, 0, rl.WHITE)

    rl.DrawTextEx(font, "EXIT", {
        auto_cast (VIRTUAL_WIDTH / 2 - rl.MeasureText("EXIT", 24) / 2),
        VIRTUAL_HEIGHT / 2 + game_over_measure.y / 2
    }, 24, 0, rl.Color{255, 255, 255, game_over_exit_alpha})
}