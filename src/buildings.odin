package main

import rl "vendor:raylib"

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

buildings_init :: proc() {
    avilable_buildings = {
        // All buildings avilable in game
    }
}

buildings_update :: proc() {
    for building in standing_buildings {
        building.update_function()
    }
}

buildings_render :: proc() {
    for building in standing_buildings {
        rl.DrawTextureV(building.texture^, {building.rect.x, building.rect.y}, rl.WHITE)
    }
}

buildings_add :: proc(building_to_add: Building) {
    append(&standing_buildings, building_to_add)
}
