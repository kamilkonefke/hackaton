package main

import rl "vendor:raylib"

// COLOR PALETTE
COLOR_PURPLE: rl.Color = {55, 33, 52, 255}
COLOR_INDIGO: rl.Color = {71, 68, 118, 255}
COLOR_BLUE: rl.Color = {72, 136, 183, 255}
COLOR_TEAL: rl.Color = {109, 188, 185, 255}
COLOR_AQUA: rl.Color = {140, 239, 182, 255}

using_ui := false 

ui_update :: proc() {
    ui_toggle_buildings_update()
    ui_buildings_container_update()
}



ui_render :: proc() {
    ui_clock({VIRTUAL_WIDTH - CLOCK_SIZE - MARGIN, VIRTUAL_HEIGHT - MARGIN}, 100.0, 60.0, "60.0")
    ui_toggle_buildings_render()
    ui_buildings_container_render()

    energy_render()
    player_pos_render()
}
