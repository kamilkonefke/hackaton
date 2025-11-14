package main

import rl "vendor:raylib"
import "core:math"

GAP: f32 = 10.0
MARGIN: f32 = 20.0

CLOCK_SIZE: f32 = 30.0
CLOCK_BORDER: f32 = 2.0
CLOCK_SEGMENTS: i32 = 40
CLOCK_LINE_THICKNESS: f32 = 2.0

ui_clock :: proc(pos: rl.Vector2, max: f32, val: f32, label: string) -> bool {
    // Border
    rl.DrawCircleSector(pos, CLOCK_SIZE + CLOCK_BORDER, 180, 360, CLOCK_SEGMENTS, COLOR_PURPLE)
    rl.DrawLineEx({
        pos.x - CLOCK_SIZE - CLOCK_BORDER,
        pos.y + 1 // 1 because to start after "main clock"
    }, {
        pos.x + CLOCK_SIZE + CLOCK_BORDER,
        pos.y + 1
    }, CLOCK_BORDER, COLOR_PURPLE)
    
    // Main circle fill
    rl.DrawCircleSector(pos, CLOCK_SIZE, 180, 360, CLOCK_SEGMENTS, COLOR_INDIGO)
    
    // Progress
    percent := val/max
    
    if percent <= 10 {
        // Display warning

        if percent == 0 {
            return true   
        }
    }
    
    angle := ((180 * percent) + 180)

    rl.DrawCircleSector({
        pos.x,
        pos.y
    }, CLOCK_SIZE, 180, angle, 20, COLOR_BLUE)
    
    line_angle := angle * rl.DEG2RAD
    rl.DrawLineEx(pos, {
        pos.x + math.cos(line_angle) * CLOCK_SIZE,
        pos.y + math.sin(line_angle) * CLOCK_SIZE
    }, CLOCK_LINE_THICKNESS, COLOR_PURPLE)
    
    // Label
    label_text := rl.TextFormat("%s", label)
    label_measure := rl.MeasureTextEx(font, label_text, 12, 0)

    rl.DrawTextEx(font, label_text, {
        pos.x - label_measure.x / 2,
        pos.y - CLOCK_SIZE - GAP - label_measure.y
    }, 12, 0, COLOR_PURPLE)

    return false
}
