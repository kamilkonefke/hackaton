package main

import rl "vendor:raylib"

timer: f32 = 10 * 60 // 10min

game_init :: proc() {
    tilemap_generate(52532)
    buildings_init()
    toggle_button_icon = gfx["chevron_up"]    
    BUILDINGS_CONTAINER_WIDTH = BUILDINGS_CONTAINER_PADDING

    for building in avilable_buildings {
        append(&buildings_in_container, building_in_container{
            pos = {0,0},
            building = building,
        })
        BUILDINGS_CONTAINER_WIDTH += BUILDINGS_CONTAINER_TEXTURE_SCALE * SPRITE_SIZE + BUILDINGS_CONTAINER_GAP
    }
    player_init()
}

game_update :: proc() {
    timer -= rl.GetFrameTime()

    if timer <= 0 {
        current_game_state = .GameOver
        return
    }

    buildings_update()
    player_update()
    energy_update()
}

game_render :: proc() {
    tilemap_render()
    buildings_render()
    player_render()
    reactor_arrow_render()
}
