package main

game_init :: proc() {
    toggle_button_icon = gfx["chevron_up"]    
}

game_update :: proc() {
    player_update()
}

game_render :: proc() {
    tilemap_render()
    player_render()
}
