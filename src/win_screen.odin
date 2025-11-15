
package main

import rl "vendor:raylib"
import "core:math"

win_timer: f32 = 0.0

win_exit_alpha: u8 = 180.0

exit_win_pos: rl.Vector2
exit_win_measure: rl.Vector2

win_screen_update :: proc() {
    win_timer += rl.GetFrameTime()

    exit_win_pos = rl.Vector2{
        auto_cast (VIRTUAL_WIDTH / 2 - rl.MeasureText("EXIT", 24) / 2),
        VIRTUAL_HEIGHT / 2 + rl.MeasureTextEx(font, "WYGRALES", 56, 0).y / 2
    }

    exit_win_measure = rl.Vector2{
        auto_cast rl.MeasureText("EXIT", 24),
        auto_cast rl.MeasureTextEx(font, "WYGRALES", 56, 0).y
    }

    if rl.CheckCollisionPointRec(mouse_screen_position, {
        x = exit_win_pos.x,
        y = exit_win_pos.y,
        width = exit_win_measure.x,
        height = exit_win_measure.y
    }) {
        win_exit_alpha = 225
        if rl.IsMouseButtonPressed(.LEFT) {
            window_should_close = true
            return
        }
    } else {
        win_exit_alpha = 180
    }
}

win_screen_render :: proc() {
    rl.ClearBackground(COLOR_PURPLE)

    y_scale := math.sin(game_over_timer)
    win_text := rl.TextFormat("WYGRALES")
    fontsize := 56 + (3 * y_scale)
    win_measure := rl.MeasureTextEx(font, win_text, fontsize, 0)
    rl.DrawTextEx(font, win_text, {
        VIRTUAL_WIDTH / 2 - win_measure.x / 2,
        VIRTUAL_HEIGHT / 2 - win_measure.y / 2 - 20
    }, fontsize, 0, rl.WHITE)

    rl.DrawTextEx(font, "EXIT", {
        auto_cast (VIRTUAL_WIDTH / 2 - rl.MeasureText("EXIT", 24) / 2),
        VIRTUAL_HEIGHT / 2 + win_measure.y / 2
    }, 24, 0, rl.Color{255, 255, 255, win_exit_alpha})
}
