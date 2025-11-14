package main

import "core:math/linalg"
import rl "vendor:raylib"
import "core:math"

GAP: f32 = 10.0
MARGIN: f32 = 20.0

CLOCK_SIZE: f32 = 20.0
CLOCK_BORDER: f32 = 2.0
CLOCK_SEGMENTS: i32 = 40
CLOCK_LINE_THICKNESS: f32 = 2.0
CLOCK_DISPLAY_WARNING: f32 = 90.0
CLOCK_PADDING: f32 = 8.0
CLOCK_GAP: f32 = 5.0

ui_clock :: proc(pos: rl.Vector2, max: f32, val: f32, label: string) -> bool {
    // Background
    background_rec: rl.Rectangle = {
        x = pos.x - CLOCK_SIZE - CLOCK_BORDER - CLOCK_PADDING,
        y = pos.y - CLOCK_SIZE * 2 - MARGIN,
        width = (CLOCK_SIZE + CLOCK_BORDER) * 2 + CLOCK_PADDING * 2,
        height = (CLOCK_SIZE + CLOCK_BORDER) * 2 + CLOCK_PADDING * 2,
    }
    rl.DrawRectangleRounded(background_rec, 0.20, 10, COLOR_PURPLE)
    center_point: rl.Vector2 = {
        background_rec.x + background_rec.width / 2,
        background_rec.y + background_rec.height / 2 + CLOCK_SIZE
    } 
    // Border
    rl.DrawCircleSector(center_point, CLOCK_SIZE + CLOCK_BORDER, 180, 360, CLOCK_SEGMENTS, rl.BLACK)
    rl.DrawLineEx({
        center_point.x - CLOCK_SIZE - CLOCK_BORDER,
        center_point.y + 1 // 1 because to start after "main clock"
    }, {
        center_point.x + CLOCK_SIZE + CLOCK_BORDER,
        center_point.y + 1
    }, CLOCK_BORDER, rl.BLACK)
    
    // Main circle fill
    rl.DrawCircleSector(center_point, CLOCK_SIZE, 180, 360, CLOCK_SEGMENTS, COLOR_BLUE)
    
    // Progress
    percent := val/max
    
    angle := ((180 * percent) + 180)

    rl.DrawCircleSector(center_point, CLOCK_SIZE, 180, angle, 20, COLOR_INDIGO)
    
    line_angle := angle * rl.DEG2RAD
    rl.DrawLineEx(center_point, {
        center_point.x + math.cos(line_angle) * CLOCK_SIZE,
        center_point.y + math.sin(line_angle) * CLOCK_SIZE
    }, CLOCK_LINE_THICKNESS, rl.BLACK)
    
    // Label
    label_text := rl.TextFormat("%s", label)
    label_measure := rl.MeasureTextEx(font, label_text, 12, 0)

    rl.DrawTextEx(font, label_text, {
        center_point.x - label_measure.x / 2,
        center_point.y - CLOCK_SIZE - CLOCK_GAP - f32(gfx["warning_sign"].height)
    }, 12, 0, {
        255,255,255,180
    })

    // Warning
    if percent * 100 <= CLOCK_DISPLAY_WARNING {
        rl.DrawTextureV(gfx["warning_sign"], {
            center_point.x - label_measure.x - CLOCK_GAP * 2,
            center_point.y - CLOCK_SIZE - CLOCK_GAP * 2 - f32(label_measure.x)
        }, rl.WHITE)

        if percent == 0 {   
            return true   
        }
    }

    return false
}

TOGGLE_SIZE: f32 = 12.0
TOGGLE_PADDING: f32 = 4.0

BUILDINGS_CONTAINER_HEIGHT: f32 = 50.0
BUILDINGS_CONTAINER_WIDTH: f32 = VIRTUAL_WIDTH * 0.7
BUILDINGS_CONTAINER_PADDING: f32 = 8.0
BUILDINGS_CONTAINER_GAP: f32 = GAP * 2 
BUILDINGS_CONTAINER_TEXTURE_SCALE: f32 = 2.0

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
    rl.DrawTextureEx(toggle_button_icon, { toggle_rect.x + TOGGLE_PADDING, toggle_rect.y + TOGGLE_PADDING }, 0, 1, rl.Color{
        255,255,255, 180
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
    new_pos: rl.Vector2 = {
        container_rect.x + BUILDINGS_CONTAINER_PADDING,
        container_rect.y + BUILDINGS_CONTAINER_HEIGHT / 2 - SPRITE_SIZE * BUILDINGS_CONTAINER_TEXTURE_SCALE / 2
    }

    for building in avilable_buildings {
        rl.DrawTextureEx(building.texture^, new_pos, 0, BUILDINGS_CONTAINER_TEXTURE_SCALE, rl.WHITE)

        new_pos.x += SPRITE_SIZE * BUILDINGS_CONTAINER_TEXTURE_SCALE + BUILDINGS_CONTAINER_GAP
    }
}

ui_buildings_container_update :: proc() {
    
}
