package main

import rl "vendor:raylib"
import "core:math"

SPLASH_SCREEN_DURATION : f32 : 8.0
SPLASH_SCREEN_SPRITE : string : "logo"
splash_screen_timer: f32 = 0.0

SPLASH_SCREEN_SCALE_TIME : f32 : 5.0
SPLASH_SCREEN_DEST_SCALE : f32 : 4.0
SPLASH_SCREEN_INITIAL_SCALE : f32 : 3.0

SPLASH_SCREEN_FADE_TIME : f32 : 2.0
SPLASH_SCREEN_FADE_DELAY : f32 : SPLASH_SCREEN_DURATION - SPLASH_SCREEN_FADE_TIME
SPLASH_SCREEN_FADE_START_ALPHA : f32 : 1.0
SPLASH_SCREEN_FADE_END_ALPHA : f32 : 0.0

splash_screen_init :: proc() {
    splash_screen_timer = 0.0
}

splash_screen_update :: proc() {
    splash_screen_timer += rl.GetFrameTime()
    if splash_screen_timer > SPLASH_SCREEN_DURATION {
        current_game_state = .PauseMenu
    }
}

splash_screen_render :: proc() {
    rl.ClearBackground(rl.WHITE)

    scale_time := math.clamp(splash_screen_timer / SPLASH_SCREEN_SCALE_TIME, 0, 1)
    scale := (SPLASH_SCREEN_DEST_SCALE - SPLASH_SCREEN_INITIAL_SCALE) * scale_time + SPLASH_SCREEN_INITIAL_SCALE
    tex := gfx[SPLASH_SCREEN_SPRITE]

    fade_time := math.clamp((splash_screen_timer - SPLASH_SCREEN_FADE_DELAY) / SPLASH_SCREEN_FADE_TIME, 0, 1)
    alpha := (SPLASH_SCREEN_FADE_END_ALPHA - SPLASH_SCREEN_FADE_START_ALPHA) * fade_time + SPLASH_SCREEN_FADE_START_ALPHA
    rl.DrawTexturePro(
        tex,
        rl.Rectangle{0, 0, f32(tex.width), f32(tex.height)},
        rl.Rectangle{
            (VIRTUAL_WIDTH - f32(tex.width) * scale) / 2,
            (VIRTUAL_HEIGHT - f32(tex.height) * scale) / 2,
            f32(tex.width) * scale,
            f32(tex.height) * scale
        },
        rl.Vector2{0.0, 0.0},
        0.0,
        rl.Color{255, 255, 255, u8(255 * alpha)}
    )
}
