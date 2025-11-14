package main

import "core:math"
import "core:fmt"
import "base:runtime"
import rl "vendor:raylib"

cursor_position: rl.Vector2

Transporter :: struct {
    is_occupied: bool,
    previous: ^Building,
    next: ^Building,
}

BUILDING_TYPE :: enum {
    NONE,
    POWER_POLE,
    MINER,
    WATER_PUMP,
    CENT, // (wirowka)
    REACTOR,
    TURBINE,
}

Building :: struct {
    rect: rl.Rectangle,
    type: BUILDING_TYPE,
    name: string,
    texture: ^rl.Texture,
    update_function: proc()
}

avilable_buildings: [dynamic]Building
standing_buildings: [dynamic]Building
standing_transporters: [dynamic]Transporter
selected_building: ^Building

// transporter
last_transporter_anchor: ^Building

is_position_occupied :: proc(position: rl.Vector2) -> (^Building, bool) {
    for &building in standing_buildings {
        if rl.CheckCollisionPointRec(position, building.rect) {
            return &building, true
        }
    }
    return nil, false
}

buildings_init :: proc() {
    registered_building := [?]Building{
        { rect = {0, 0, auto_cast gfx["mine"].width, auto_cast gfx["mine"].height}, type = .MINER, texture = &gfx["mine"]},
    }

    reserve(&standing_buildings, 1024)
    reserve(&standing_transporters, 1024)

    append(&avilable_buildings, ..registered_building[:])
}

@(private="file")
place_transporters :: proc() {
    if rl.IsMouseButtonPressed(.RIGHT) {
        building, is_occupied := is_position_occupied(cursor_position)

        if is_occupied == false {
            return
        }

        if last_transporter_anchor != nil && building != last_transporter_anchor {
            transporter: Transporter = {
                previous = last_transporter_anchor,
                next = building,
            }

            for t in standing_transporters {
                if (t.previous == transporter.previous && t.next == transporter.next) || 
                    (t.previous == transporter.next && t.next == transporter.previous) {
                    return
                }
            }

            append(&standing_transporters, transporter)
            last_transporter_anchor = nil

            return
        }
        else if is_occupied && building != nil {
            last_transporter_anchor = building
        }
    }
}

buildings_update :: proc() {
    cursor_position = rl.GetScreenToWorld2D(mouse_screen_position, main_camera)
    cursor_position = {
        (math.floor(cursor_position.x / SPRITE_SIZE) * SPRITE_SIZE),
        (math.floor(cursor_position.y / SPRITE_SIZE) * SPRITE_SIZE)
    }

    if rl.IsKeyPressed(.ONE) {
        selected_building = &avilable_buildings[0]
    }

    place_transporters()

    if selected_building != nil {
        if rl.IsMouseButtonPressed(.LEFT) {
            building, is_occupied := is_position_occupied(cursor_position)

            if is_occupied {
                return
            }

            building_copy: Building = selected_building^
            building_copy.rect.x = cursor_position.x
            building_copy.rect.y = cursor_position.y

            append(&standing_buildings, building_copy)
        }
    }

    for building in standing_buildings {
        if building.update_function == nil {
            continue
        }

        building.update_function()
    }
}

buildings_render :: proc() {
    // Building
    if selected_building != nil {
        rl.DrawTextureV(selected_building.texture^, cursor_position, {255.0, 255.0, 255.0, 150.0})
    }

    for building in standing_buildings {
        rl.DrawTextureV(building.texture^, {building.rect.x, building.rect.y}, rl.WHITE)
    }

    for transporter in standing_transporters {
        rl.DrawLineBezier(
            {transporter.previous.rect.x+8, transporter.previous.rect.y+8},
            {transporter.next.rect.x+8, transporter.next.rect.y+8},
            2.0,
            rl.RED,
        )
    }
}

