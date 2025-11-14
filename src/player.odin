package main

import "core:math"
import rl "vendor:raylib"

player_rect: rl.Rectangle = {0, 0, 16, 16}
player_speed: f32 = 2.0
player_direction: bool = true //true -> right ; false -> left

player_update :: proc() {
    initial_pos_h := player_rect.x

    if rl.IsKeyDown(.W){
        player_rect.y -= player_speed
    }
    if rl.IsKeyDown(.S){
        player_rect.y += player_speed
    }
    if rl.IsKeyDown(.A){
        player_rect.x -= player_speed
    }
    if rl.IsKeyDown(.D){
        player_rect.x += player_speed
    }
    player_direction = player_rect.x - initial_pos_h >= 0
}

player_render :: proc() {
    rl.DrawTextureRec(gfx["skin"], {0, 0, player_rect.width, player_rect.height}, {player_rect.x, player_rect.y}, rl.WHITE)
    if player_direction {
        player_rect.width = math.abs(player_rect.width)
    }else{
        player_rect.width = -math.abs(player_rect.width)
    }
}