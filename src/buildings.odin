package main

import "core:math"
import rl "vendor:raylib"

cursor_position: rl.Vector2

Transporter :: struct {
    is_occupied: bool,
    previous: ^Building,
    next: ^Building,
}

BUILDING_TYPE :: enum {
    MINER,
    FACTORY,
    WATER_PUMP,
    CENT, // (wirowka)
    COOLER,
    REACTOR,
}

Building :: struct {
    rect: rl.Rectangle,
    type: BUILDING_TYPE,
    cost: f32,
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
        { rect = {0, 0, auto_cast gfx["drill"].width, auto_cast gfx["drill"].height}, type = .MINER, texture = &gfx["drill"]},
        { rect = {0, 0, auto_cast gfx["cent_object"].width, auto_cast gfx["cent_object"].height}, type = .CENT, texture = &gfx["cent_object"]},
        { rect = {0, 0, auto_cast gfx["factory_object"].width, auto_cast gfx["factory_object"].height}, type = .FACTORY, texture = &gfx["factory_object"]},
        { rect = {0, 0, auto_cast gfx["waterpump_object"].width, auto_cast gfx["waterpump_object"].height}, type = .WATER_PUMP, texture = &gfx["waterpump_object"]},
        { rect = {0, 0, auto_cast gfx["reactor_block"].width, auto_cast gfx["reactor_block"].height}, type = .REACTOR, texture = &gfx["reactor_block"]},
        { rect = {0, 0, auto_cast gfx["cooler_object"].width, auto_cast gfx["cooler_object"].height}, type = .COOLER, texture = &gfx["cooler_object"]},
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

            append(&standing_buildings, building_cpy)
        }
    }

    for building in standing_buildings {
        if building.update_function == nil {
            continue
        }

        building.update_function()
    }
}

@(private="file")
is_connection_valid :: proc(transporter: Transporter) -> bool {
    if transporter.previous.type == .MINER && transporter.next.type == .CENT ||
        transporter.next.type == .CENT && transporter.previous.type == .MINER {
        return true
    }

    if transporter.previous.type == .CENT && transporter.next.type == .FACTORY || 
        transporter.previous.type == .FACTORY && transporter.next.type == .CENT {
        return true
    }

    if transporter.previous.type == .FACTORY && transporter.next.type == .REACTOR ||
        transporter.previous.type == .REACTOR && transporter.next.type == .FACTORY {
        return true
    }

    if transporter.previous.type == .WATER_PUMP && transporter.next.type == .REACTOR ||
        transporter.previous.type == .REACTOR && transporter.next.type == .WATER_PUMP {
        return true
    }

    if transporter.previous.type == .COOLER && transporter.next.type == .REACTOR ||
        transporter.previous.type == .REACTOR && transporter.next.type == .COOLER {
        return true
    }

    return false
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
        color := rl.RED
        if is_connection_valid(transporter) {
            color = rl.GREEN
        }

        rl.DrawLineBezier(
            {transporter.previous.rect.x+8, transporter.previous.rect.y+8},
            {transporter.next.rect.x+8, transporter.next.rect.y+8},
            2.0,
            color,
        )
    }
}

