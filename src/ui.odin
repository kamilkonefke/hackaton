package main

import rl "vendor:raylib"

// COLOR PALETTE
COLOR_PURPLE: rl.Color = {55, 33, 52, 255}
COLOR_INDIGO: rl.Color = {71, 68, 118, 255}
COLOR_BLUE: rl.Color = {72, 136, 183, 255}
COLOR_TEAL: rl.Color = {109, 188, 185, 255}
COLOR_AQUA: rl.Color = {140, 239, 182, 255}

ui_update :: proc() {

}


ui_render :: proc() {
    ui_clock({100, 100}, 100.0, 90.0, "Test Label")
}
