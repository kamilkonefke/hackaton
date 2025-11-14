package main

game_init :: proc() {
    
}

game_update :: proc() {
    player_update()
}

game_render :: proc() {
    tilemap_render()
    player_render()
}
