package main

game_init :: proc() {
    buildings_init()
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
