package main

import "core:fmt"
import "core:math"
import rl "vendor:raylib"

balance: f32 = 500.0

wattage: f32 = 0.0
target_watte: f32 = 50.0

temperature: f32 = 0.0
target_temperature: f32 = 0.0

max_temperature: f32 = 100.0
min_temperature: f32 = 0.0

max_wattage: f32 = 100.0
min_wattage: f32 = 0.0

ENERGY_PADDING: f32 = 8.0
ENERGY_GAP: f32 = 5.0

BALANCE_WIN_CONDITION: f32 = 3000.0

energy_update :: proc() {
    fmt.println(balance, BALANCE_WIN_CONDITION, balance >= BALANCE_WIN_CONDITION)
    if balance >= BALANCE_WIN_CONDITION {
        current_game_state = .WinScreen
        return
    }
}

energy_render :: proc() {
    target_temperature = math.max(target_temperature, 0.0)
    target_watte = math.max(target_watte, 0.0)
    target_watte = math.lerp(target_watte, 0, 0.03 * rl.GetFrameTime())

    wattage = math.lerp(wattage, target_watte, rl.GetFrameTime() / 2.0)
    temp := math.lerp(temperature, target_temperature, rl.GetFrameTime() / 2.0)
    temperature = math.clamp(temp, min_temperature, max_temperature)

    balance_text := rl.TextFormat("%v", math.floor(balance))
    balance_measure := rl.MeasureTextEx(font, balance_text, 12, 0)

    energy_rect: rl.Rectangle = {
        x = MARGIN,
        y = MARGIN,
        width = balance_measure.x + ENERGY_PADDING * 2 + SPRITE_SIZE + ENERGY_GAP,
        height = balance_measure.y + ENERGY_PADDING * 2
    }

    rl.DrawRectangleRounded(energy_rect, 0.25, 10, COLOR_PURPLE)
    rl.DrawTextureV(gfx["energy"], {
        energy_rect.x + ENERGY_PADDING,
        energy_rect.y + ENERGY_PADDING - 1,
    }, rl.WHITE)
    rl.DrawTextEx(font, balance_text, {energy_rect.x + ENERGY_PADDING + SPRITE_SIZE + ENERGY_GAP, energy_rect.y + ENERGY_PADDING}, 12, 0, {
        255,255,255,180
    })
}
