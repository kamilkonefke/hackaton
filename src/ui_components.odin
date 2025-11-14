package main

import "core:math/linalg"
import rl "vendor:raylib"
import "core:math"

GAP: f32 = 10.0
MARGIN: f32 = 20.0

CLOCK_SIZE: f32 = 30.0
CLOCK_BORDER: f32 = 2.0
CLOCK_SEGMENTS: i32 = 40
CLOCK_LINE_THICKNESS: f32 = 2.0
CLOCK_DISPLAY_WARNING: f32 = 10.0

ui_clock :: proc(pos: rl.Vector2, max: f32, val: f32, label: string) -> bool {
    // Border
    rl.DrawCircleSector(pos, CLOCK_SIZE + CLOCK_BORDER, 180, 360, CLOCK_SEGMENTS, rl.BLACK)
    rl.DrawLineEx({
        pos.x - CLOCK_SIZE - CLOCK_BORDER,
        pos.y + 1 // 1 because to start after "main clock"
    }, {
        pos.x + CLOCK_SIZE + CLOCK_BORDER,
        pos.y + 1
    }, CLOCK_BORDER, rl.BLACK)
    
    // Main circle fill
    rl.DrawCircleSector(pos, CLOCK_SIZE, 180, 360, CLOCK_SEGMENTS, COLOR_PURPLE)
    
    // Progress
    percent := val/max
    
    angle := ((180 * percent) + 180)

    rl.DrawCircleSector({
        pos.x,
        pos.y
    }, CLOCK_SIZE, 180, angle, 20, COLOR_INDIGO)
    
    line_angle := angle * rl.DEG2RAD
    rl.DrawLineEx(pos, {
        pos.x + math.cos(line_angle) * CLOCK_SIZE,
        pos.y + math.sin(line_angle) * CLOCK_SIZE
    }, CLOCK_LINE_THICKNESS, rl.BLACK)
    
    // Label
    label_text := rl.TextFormat("%s", label)
    label_measure := rl.MeasureTextEx(font, label_text, 12, 0)

    rl.DrawTextEx(font, label_text, {
        pos.x - label_measure.x / 2,
        pos.y - CLOCK_SIZE - GAP - label_measure.y
    }, 12, 0, COLOR_PURPLE)

    // Warning
    if percent <= CLOCK_DISPLAY_WARNING {
        rl.DrawTextureV(gfx["warning_sign"], {
            pos.x - f32(gfx["warning_sign"].width) / 2,
            pos.y - CLOCK_SIZE - GAP * 2 - label_measure.y - f32(gfx["warning_sign"].height)
        }, rl.WHITE)

        if percent == 0 {
            return true   
        }
    }

    return false
}

TOGGLE_SIZE: f32 = 16.0
TOGGLE_PADDING: f32 = 4.0
BUILDINGS_CONTAINER_HEIGHT: f32 = 70
BUILDINGS_CONTAINER_WIDTH: f32 = VIRTUAL_WIDTH * 0.7

toggle_button_pos_target: rl.Vector2 = {
    MARGIN,
    VIRTUAL_HEIGHT - TOGGLE_SIZE - MARGIN - TOGGLE_PADDING,
}
toggle_button_pos := toggle_button_pos_target
toggle_button_icon: rl.Texture

toggle_rect: rl.Rectangle

buildings_container_pos_target: rl.Vector2 = {
    MARGIN,
    VIRTUAL_HEIGHT
}
buildings_container_pos := buildings_container_pos_target

is_building_toggled := false

ui_toggle_buildings_render :: proc() {
    toggle_button_pos = linalg.lerp(toggle_button_pos, toggle_button_pos_target, f32(rl.GetFrameTime() * 10))
    toggle_rect = {
        x = toggle_button_pos.x,
        y = toggle_button_pos.y,
        width = TOGGLE_SIZE + TOGGLE_PADDING * 2,
        height = TOGGLE_SIZE + TOGGLE_PADDING * 2,
    }

    // Button
    rl.DrawRectangleRounded(toggle_rect, 0.25, 10, COLOR_PURPLE)
    rl.DrawTextureV(toggle_button_icon, { toggle_rect.x + TOGGLE_PADDING, toggle_rect.y + TOGGLE_PADDING }, rl.Color{
        255,255,255, 150
    })
}

hovered_toggle := false

ui_toggle_buildings_update :: proc() {
    if rl.CheckCollisionPointRec(mouse_screen_position, toggle_rect) {
        hovered_toggle = true
        is_on_hover = true
        if rl.IsMouseButtonPressed(.LEFT) {
            is_building_toggled = !is_building_toggled

            // Container UP
            if is_building_toggled {
                toggle_button_icon = gfx["chevron_down"]
                toggle_button_pos_target = {
                    MARGIN,
                    VIRTUAL_HEIGHT - TOGGLE_SIZE - MARGIN - TOGGLE_PADDING - BUILDINGS_CONTAINER_HEIGHT - GAP, 
                }
                buildings_container_pos_target = {
                    MARGIN,
                    VIRTUAL_HEIGHT - BUILDINGS_CONTAINER_HEIGHT - MARGIN
                }
                // Container DOWN
            } else {
                toggle_button_icon = gfx["chevron_up"]
                toggle_button_pos_target = {
                    MARGIN,
                    VIRTUAL_HEIGHT - TOGGLE_SIZE - MARGIN - TOGGLE_PADDING,
                }
                buildings_container_pos_target = {
                    MARGIN,
                    VIRTUAL_HEIGHT
                }
            }
        }
    } else if hovered_toggle {
        is_on_hover = false
        hovered_toggle = false
    }
}

ui_buildings_container_render :: proc() {
    buildings_container_pos = linalg.lerp(buildings_container_pos, buildings_container_pos_target, f32(rl.GetFrameTime() * 10))
    container_rect: rl.Rectangle = {
        x = buildings_container_pos.x,
        y = buildings_container_pos.y,
        width = BUILDINGS_CONTAINER_WIDTH,
        height = BUILDINGS_CONTAINER_HEIGHT,
    }

    // Container Render
    rl.DrawRectangleRounded(container_rect, 0.25, 10, COLOR_PURPLE)
}

ui_buildings_container_update :: proc() {

}
