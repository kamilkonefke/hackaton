package main

import rl "vendor:raylib"
import math "core:math"

// COLOR PALETTE
COLOR_PURPLE: rl.Color = {55, 33, 52, 255}
COLOR_INDIGO: rl.Color = {71, 68, 118, 255}
COLOR_BLUE: rl.Color = {72, 136, 183, 255}
COLOR_TEAL: rl.Color = {109, 188, 185, 255}
COLOR_AQUA: rl.Color = {140, 239, 182, 255}

using_ui := false 

ui_update :: proc() {
    if current_game_state == .SplashScreen {
        splash_screen_update()
        return
    }
    ui_toggle_buildings_update()
    ui_buildings_container_update()
}

ui_render :: proc() {
    if current_game_state == .SplashScreen {
        splash_screen_render()
        return
    }

    ui_clock({VIRTUAL_WIDTH - CLOCK_SIZE - MARGIN, VIRTUAL_HEIGHT - MARGIN}, 100.0, 60.0, "60.0")
    ui_toggle_buildings_render()
    ui_buildings_container_render()

    energy_render()
    player_pos_render()

    minutes := math.floor(timer / 60)
    seconds := i32(timer) % 60
    rl.DrawTextEx(font, rl.TextFormat("%v:%v", minutes, seconds), {VIRTUAL_WIDTH / 2 - auto_cast rl.MeasureText(rl.TextFormat("%v:%v", minutes, seconds), 12) / 2, VIRTUAL_HEIGHT / 2 - 128}, 12, 0, rl.WHITE)
}
