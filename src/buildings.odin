package main

import "core:mem"
import "core:fmt"
import "core:math"
import rl "vendor:raylib"

cursor_position: rl.Vector2

MATERIAL_TYPE :: enum {
    NONE,
    RAW_ORE,
    REFINED_ORE,
    FUEL_ROD,
    WATER,
    STEAM,
    ENERGY,
}

Material :: struct {
    type: MATERIAL_TYPE,
    amount: i16,
    progress: f32,
}

Transporter :: struct {
    previous: ^Building,
    next: ^Building,
    materials: [dynamic]Material,
    speed: f32,
    capacity: i16,
}

@(private="file")
is_position_occupied :: proc(position: rl.Vector2) -> (^Building, bool) {
    for &building in standing_buildings {
        if rl.CheckCollisionPointRec(position, building.rect) {
            return &building, true
        }
    }
    return nil, false
}

Production_Config :: struct {
    input_type: MATERIAL_TYPE,
    input_amount: i16,
    output_type: MATERIAL_TYPE, 
    output_amount: i16, 
    time: f32
}

@(private="file")
get_production_config :: proc(building_type: BUILDING_TYPE) -> Production_Config {
    switch building_type { // Tak chcialo mi sie to recznie pisac.
    case .MINER:
        return { input_type = .NONE, input_amount = 0, output_type = .RAW_ORE, output_amount = 1, time = 2.0}
    case .CENT:
        return { input_type = .RAW_ORE, input_amount = 1, output_type = .REFINED_ORE, output_amount = 1, time = 1.5}
    case .FACTORY:
        return { input_type = .REFINED_ORE, input_amount = 1, output_type = .FUEL_ROD, output_amount = 1, time = 3.0}
    case .WATER_PUMP:
        return { input_type = .NONE, input_amount = 0, output_type = .WATER, output_amount = 1, time = 1.0}
    case .REACTOR:
        return { input_type = .FUEL_ROD, input_amount = 1, output_type = .STEAM, output_amount = 1, time = 8.0}
    case .COOLER:
        return { input_type = .STEAM, input_amount = 1, output_type = .NONE, output_amount = 0, time = 1.0}
    }
    return { input_type = .NONE, input_amount = 0, output_type = .NONE, output_amount = 0, time = 0}
}

transporter_init :: proc(transporter: ^Transporter) {
    transporter.speed = 0.5
    transporter.capacity = 1

    append(&transporter.previous.output_connections, transporter)
    append(&transporter.next.input_connections, transporter)
}

transporter_update :: proc(transporter: ^Transporter) {
    for &material in transporter.materials {
        material.progress += transporter.speed * rl.GetFrameTime()

        if material.progress >= 1.0 {
            if transporter.next.input_buffer[material.type] + material.amount <= transporter.next.buffer_capacity {
                transporter.next.input_buffer[material.type] += material.amount
                material.amount = 0
            }
        }
    }

    for i := len(transporter.materials) - 1; i >= 0; i -= 1 {
        if transporter.materials[i].amount <= 0 {
            ordered_remove(&transporter.materials, i)
        }
    }

    if auto_cast len(transporter.materials) < transporter.capacity {
        config := get_production_config(transporter.previous.type)

        if config.output_type != .NONE && transporter.previous.output_buffer[config.output_type] >= 1.0 {
            material := Material{
                type = config.output_type,
                amount = 1.0,
                progress = 0.0,
            }

            append(&transporter.materials, material)
            transporter.previous.output_buffer[config.output_type] -= 1.0
        }
    }
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
    input_buffer: [MATERIAL_TYPE]i16,
    output_buffer: [MATERIAL_TYPE]i16,
    buffer_capacity: i16,
    production_timer: f32,
    production_time: f32,
    is_producing: bool,
    input_connections: [dynamic]^Transporter,
    output_connections: [dynamic]^Transporter,
}

avilable_buildings: [dynamic]Building
standing_buildings: [dynamic]Building
standing_transporters: [dynamic]Transporter
selected_building: ^Building

last_transporter_anchor: ^Building

building_init_production :: proc(building: ^Building) {
    config := get_production_config(building.type)
    building.production_time = config.time
    building.buffer_capacity = 2
    building.production_timer = 0
    building.is_producing = false
}

buildings_init :: proc() {
    registered_building := [?]Building{
        { rect = {0, 0, SPRITE_SIZE, SPRITE_SIZE}, type = .MINER, texture = &gfx["drill"], cost = 100.0},
        { rect = {0, 0, SPRITE_SIZE, SPRITE_SIZE}, type = .CENT, texture = &gfx["cent_object"], cost = 100.0},
        { rect = {0, 0, SPRITE_SIZE, SPRITE_SIZE}, type = .FACTORY, texture = &gfx["factory_object"], cost = 100.0},
        { rect = {0, 0, SPRITE_SIZE, SPRITE_SIZE}, type = .WATER_PUMP, texture = &gfx["waterpump_object"], cost = 100.0},
        { rect = {0, 0, SPRITE_SIZE, SPRITE_SIZE}, type = .REACTOR, texture = &gfx["radioactive_sign"], cost = 100.0},
        { rect = {0, 0, SPRITE_SIZE, SPRITE_SIZE}, type = .COOLER, texture = &gfx["cooler_object"], cost = 100.0},
    }

    reserve(&standing_buildings, 1024)
    reserve(&standing_transporters, 1024)

    append(&avilable_buildings, ..registered_building[:])

    reactor_init()
}

@(private="file")
place_transporters :: proc() {

    // Add transporter
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
            
            transporter_init(&standing_transporters[len(standing_transporters)-1])

            last_transporter_anchor = nil

            return
        }
        else if is_occupied && building != nil {
            last_transporter_anchor = building
        }
    }

    // Remove transporter
    if rl.IsMouseButtonPressed(.MIDDLE) {
        building, is_occupied := is_position_occupied(cursor_position)

        if is_occupied == false {
            return
        }

        if last_transporter_anchor != nil && building != last_transporter_anchor {
            transporter: Transporter = {
                previous = last_transporter_anchor,
                next = building,
            }

            for t, i in standing_transporters {
                if (t.previous == transporter.previous && t.next == transporter.next) || 
                    (t.previous == transporter.next && t.next == transporter.previous) {
                        last_transporter_anchor = nil
                        unordered_remove(&standing_transporters, i)
                        return
                }
            }
            return
        }
        else if is_occupied && building != nil {
            last_transporter_anchor = building
        }
    }
}

@(private="file")
place_buildings :: proc() {
    if selected_building != nil && using_ui == false {
        if rl.IsKeyPressed(.Q) {
            selected_building = nil

            // Remove buildings
            building, is_occupied := is_position_occupied(cursor_position)
            if is_occupied {
                for b, i in standing_buildings {
                    if b.rect.x == building.rect.x && b.rect.y == building.rect.y {
                        ordered_remove(&standing_buildings, i)
                        break
                    }
                }
            }
        }

        if rl.IsMouseButtonPressed(.LEFT) {
            building, is_occupied := is_position_occupied(cursor_position)
            tile := tilemap_get_tile(auto_cast cursor_position.x / SPRITE_SIZE, auto_cast cursor_position.y / SPRITE_SIZE)
            if is_occupied {
                return
            }

            if balance < selected_building.cost {
                return
            }

            if selected_building.type == .MINER && tile.sprite != "ore" {
                return
            }

            if selected_building.type == .WATER_PUMP && tile.sprite != "water" {
                return
            }

            if selected_building.type != .WATER_PUMP && tile.sprite == "water" {
                return
            }

            building_copy: Building = selected_building^
            building_copy.rect.x = cursor_position.x
            building_copy.rect.y = cursor_position.y
            append(&standing_buildings, building_copy)
            
            balance -= selected_building.cost
            building_init_production(&standing_buildings[len(standing_buildings)-1])
        }
    }
}

building_update_production :: proc(building: ^Building) {
    config := get_production_config(building.type)
    
    if building.type == .REACTOR {
        has_fuel := building.input_buffer[.FUEL_ROD] >= 1.0
        has_water := building.input_buffer[.WATER] >= 1.0
        
        if building.is_producing == false && has_fuel && has_water {
            building.is_producing = true
            building.production_timer = 0
            building.input_buffer[.FUEL_ROD] -= 1.0
            building.input_buffer[.WATER] -= 1.0
        }
    } else {
        if building.is_producing == false {
            can_produce := true
            
            if config.input_type != .NONE {
                can_produce = building.input_buffer[config.input_type] >= config.input_amount
            }
            
            if config.output_type != .NONE {
                can_produce = can_produce && (building.output_buffer[config.output_type] + config.output_amount <= building.buffer_capacity)
            }
            
            if can_produce {
                building.is_producing = true
                building.production_timer = 0
                
                if config.input_type != .NONE {
                    building.input_buffer[config.input_type] -= config.input_amount
                }
            }
        }
    }
    
    if building.is_producing {
        building.production_timer += rl.GetFrameTime()
        
        if building.production_timer >= building.production_time {
            building.is_producing = false
            building.production_timer = 0
            if building.type == .COOLER {
                balance += 100.0
            } else if building.type == .REACTOR {
                target_temperature += 25.0
                target_watte += 5.0
            } else if building.type == .WATER_PUMP {
                target_temperature -= 5.0
            }
            
            if config.output_type != .NONE {
                building.output_buffer[config.output_type] += config.output_amount
            }
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
    place_buildings()
    
    for &building in standing_buildings {
        building_update_production(&building)
    }
    
    for &transporter in standing_transporters {
        transporter_update(&transporter)
    }
}

@(private="file")
is_connection_valid :: proc(transporter: Transporter) -> bool {
    if transporter.previous.type == .MINER && transporter.next.type == .CENT {
        return true
    }

    if transporter.previous.type == .CENT && transporter.next.type == .FACTORY {
        return true
    }

    if transporter.previous.type == .FACTORY && transporter.next.type == .REACTOR {
        return true
    }

    if transporter.previous.type == .WATER_PUMP && transporter.next.type == .REACTOR {
        return true
    }

    if transporter.previous.type == .REACTOR && transporter.next.type == .COOLER {
        return true
    }

    return false
}

buildings_render :: proc() {
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
    
    for transporter in standing_transporters {
        for material in transporter.materials {
            if material.progress < 0.0 || material.progress > 1.0 {
                continue
            }

            start := rl.Vector2{transporter.previous.rect.x + 8, transporter.previous.rect.y + 8}
            end := rl.Vector2{transporter.next.rect.x + 8, transporter.next.rect.y + 8}

            pos := rl.Vector2{
                start.x + (end.x - start.x) * material.progress,
                start.y + (end.y - start.y) * material.progress,
            }
            
            color := rl.WHITE
            switch material.type {
                case .RAW_ORE: color = {139, 69, 19, 255}
                case .REFINED_ORE: color = {192, 192, 192, 255}
                case .FUEL_ROD: color = {0, 255, 0, 255}
                case .WATER: color = {0, 191, 255, 255}
                case .STEAM: color = {211, 211, 211, 255}
                case .ENERGY: color = {255, 215, 0, 255}
                case .NONE: color = rl.WHITE
            }
            
            rl.DrawCircleV(pos, 3, color)
        }
    }
    
    for building in standing_buildings {
        pos := rl.Vector2{building.rect.x, building.rect.y - 20}
        
        config := get_production_config(building.type)
        if config.output_type != .NONE {
            rl.DrawTextEx(font, rl.TextFormat("%v", building.output_buffer[config.output_type]), {pos.x+4, pos.y}, 12, 0, rl.WHITE)
        }
        
        if building.is_producing {
            progress := building.production_timer / building.production_time
            bar_width := building.rect.width
            rl.DrawRectangle(i32(building.rect.x), i32(building.rect.y - 5), i32(bar_width * progress), 3, rl.GREEN)
        }
    }
}
