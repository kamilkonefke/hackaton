package main

game_init :: proc() {
    tilemap_generate(42)
}

game_update :: proc() {
    player_update()
}

game_render :: proc() {
    tilemap_render()
    player_render()
}
