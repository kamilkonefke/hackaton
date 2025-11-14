package main

game_init :: proc() {
    tilemap_generate(42)
    buildings_init()
    toggle_button_icon = gfx["chevron_up"]    
}

game_update :: proc() {
    buildings_update()
    player_update()
}

game_render :: proc() {
    tilemap_render()
    buildings_render()
    player_render()
}
