package main

import "core:math"
import rl "vendor:raylib"

player_pos: rl.Vector2 = {0, 0}
player_rect: rl.Rectangle = {player_pos.x, player_pos.y, 16, 16}
player_speed: f32 = 60.0
player_velocity: rl.Vector2 = {0, 0}
player_direction: bool = true //true -> right ; false -> left

player_update :: proc() {
    initial_pos_h := player_rect.x

    if rl.IsKeyDown(.W){
        player_velocity.y -= player_speed
    }
    if rl.IsKeyDown(.S){
        player_velocity.y += player_speed
    }
    if rl.IsKeyDown(.A){
        player_velocity.x -= player_speed
    }
    if rl.IsKeyDown(.D){
        player_velocity.x += player_speed
    }
    player_pos += player_velocity * rl.GetFrameTime()
    player_rect.x = player_pos.x
    player_rect.y = player_pos.y
    player_velocity *= 0.75

    player_direction = player_rect.x - initial_pos_h >= 0
}

player_render :: proc() {
    rl.DrawTextureRec(gfx["skin"], {0, 0, player_rect.width, player_rect.height}, {player_rect.x, player_rect.y}, rl.WHITE)

    if player_velocity.x != 0 && player_velocity.y != 0 {
        if player_direction {
            player_rect.width = math.abs(player_rect.width)
        } else{
            player_rect.width = -math.abs(player_rect.width)
        }
    }
}