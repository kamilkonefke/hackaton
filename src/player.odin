package main

import "core:fmt"
import rl "vendor:raylib"

player_pos: rl.Vector2 = {0, 0}
player_size: rl.Vector2 = {16, 16}
player_speed: f32 = 2.0

player_update :: proc() {
    if rl.IsKeyDown(.W){
        player_pos.y -= player_speed
    }
    if rl.IsKeyDown(.S){
        player_pos.y += player_speed
    }
    if rl.IsKeyDown(.A){
        player_pos.x -= player_speed
    }
    if rl.IsKeyDown(.D){
        player_pos.x += player_speed
    }
}

player_render :: proc() {
    rl.DrawRectangleV(player_pos, player_size, rl.RED)
}