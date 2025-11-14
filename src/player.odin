package main

import "core:flags/example"
import "core:fmt"
import rl "vendor:raylib"

player_rect: rl.Rectangle = {0, 0, 16, 16}
player_speed: f32 = 2.0
player_direction: bool = true //true -> right ; false -> left
player_changed_direction: bool = false

player_update :: proc() {
    if rl.IsKeyDown(.W){
        player_rect.y -= player_speed
    }
    if rl.IsKeyDown(.S){
        player_rect.y += player_speed
    }
    if rl.IsKeyDown(.A){
        player_rect.x -= player_speed
        if player_direction {player_changed_direction = true}
        player_direction = false
    }
    if rl.IsKeyDown(.D){
        player_rect.x += player_speed
        if !player_direction {player_changed_direction = true}
        player_direction = true
    }
}

player_render :: proc() {
    rl.DrawTextureRec(gfx["skin"], {0, 0, player_rect.width, player_rect.height}, {player_rect.x, player_rect.y}, rl.WHITE)
    fmt.println(player_direction)
    if player_changed_direction {
        player_rect.width = -player_rect.width
        player_changed_direction = false
    }
}