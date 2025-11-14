package main

import "core:math"
import rl "vendor:raylib"

player_pos: rl.Vector2 = {0, 0}
player_rect: rl.Rectangle = {player_pos.x, player_pos.y, 16, 16}
player_speed: f32 = 175.0
player_velocity: rl.Vector2 = {0, 0}
player_direction: bool = true //true -> right ; false -> left

player_check_collisions :: proc() -> bool{
    for building in standing_buildings {
        if rl.Vector2Distance(player_pos, {building.rect.x, building.rect.y}) <= 12 {
            player_pos -= player_velocity * rl.GetFrameTime()
            return true
        }
    }
    return false
}

player_update :: proc() {
    initial_pos_h := player_rect.x
    input_dir: rl.Vector2 = {0, 0}

    if rl.IsKeyDown(.W){
        input_dir.y -= player_speed
    }
    if rl.IsKeyDown(.S){
        input_dir.y += player_speed
    }
    if rl.IsKeyDown(.A){
        input_dir.x -= player_speed
    }
    if rl.IsKeyDown(.D){
        input_dir.x += player_speed
    }

    player_velocity = rl.Vector2Normalize(input_dir) * player_speed
    player_pos += player_velocity * rl.GetFrameTime()
    player_velocity *= 0.99
    if !player_check_collisions() {
        player_rect.x = player_pos.x
        player_rect.y = player_pos.y
    }

    player_direction = player_rect.x - initial_pos_h >= 0

    adjust_camera_to_player()
}

player_render :: proc() {
    rl.DrawTextureRec(gfx["skin"], {0, 0, player_rect.width, player_rect.height}, {player_rect.x, player_rect.y}, rl.WHITE)

        if player_direction {
            player_rect.width = math.abs(player_rect.width)
        } else{
            player_rect.width = -math.abs(player_rect.width)
        }
}

adjust_camera_to_player :: proc() {
    main_camera.target.x = player_rect.x - (VIRTUAL_WIDTH / 2)
    main_camera.target.y = player_rect.y - (VIRTUAL_HEIGHT / 2)
}