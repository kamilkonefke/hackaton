package main

import rl "vendor:raylib"
import "core:math/rand"

reactor_pos: rl.Vector2 = {0, 0}
reactor_show_arrow: bool = true

reactor_init :: proc() {
    reactor: Building = avilable_buildings[4]

    pos_array: [dynamic]f32 = {}
    defer delete(pos_array)
    for i:f32 = 0; i < 256; i += 1 {
        append(&pos_array, i)
    }
    reactor_pos = {rand.choice(pos_array[:]) * SPRITE_SIZE, rand.choice(pos_array[:]) * SPRITE_SIZE}
    for tilemap_get_tile(int(reactor_pos.x / SPRITE_SIZE), int(reactor_pos.y / SPRITE_SIZE)).sprite == "water" {
        reactor_pos = {rand.choice(pos_array[:]) * SPRITE_SIZE, rand.choice(pos_array[:]) * SPRITE_SIZE}
    }

    reactor.rect.x = reactor_pos.x
    reactor.rect.y = reactor_pos.y

    append(&standing_buildings, reactor)
    building_init_production(&standing_buildings[0])
}

reactor_arrow_render :: proc() {
    temp_player_pos := player_pos + SPRITE_SIZE / 2
    temp_reactor_pos := reactor_pos + SPRITE_SIZE / 2
    if rl.Vector2Distance(temp_player_pos, temp_reactor_pos) > VIRTUAL_HEIGHT && reactor_show_arrow {
        rl.DrawLineEx(temp_player_pos, temp_reactor_pos, 2, rl.Color{248, 204, 0, 255})
    } else {
        reactor_show_arrow = false
    }
}