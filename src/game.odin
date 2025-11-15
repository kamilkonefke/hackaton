package main

import rl "vendor:raylib"

timer: f32 = 10 * 60 // 10min

game_init :: proc() {
    tilemap_generate(42)
    buildings_init()
    toggle_button_icon = gfx["chevron_up"]    

    for building in avilable_buildings {
        append(&buildings_in_container, building_in_container{
            pos = {0,0},
            building = building,
        })
    }
    player_init()
}

game_update :: proc() {
    timer -= rl.GetFrameTime()
    buildings_update()
    player_update()
}

game_render :: proc() {
    tilemap_render()
    buildings_render()
    player_render()
    reactor_arrow_render()
}
