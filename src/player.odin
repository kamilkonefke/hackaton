package main

import "core:math"
import "core:math/rand"
import "core:fmt"
import rl "vendor:raylib"

PLAYER_SPEED :: 175.0
ANIM_SPEED :: 0.1

player_pos: rl.Vector2 = {0, 0}
player_rect: rl.Rectangle = {player_pos.x, player_pos.y, 16, 16}
player_velocity: rl.Vector2 = {0, 0}
player_direction: rl.Vector2 = {0, 0} //true -> right ; false -> left
player_anim_stage: i8 = 0
tmp_string: string = "skin0"
second: f32 = 0

player_check_collisions :: proc() -> bool{
    if player_pos.x <= 0 || player_pos.x >= SPRITE_SIZE * 255 || player_pos.y <= 0 || player_pos.y >= SPRITE_SIZE * 255 {
        player_pos -= player_velocity * rl.GetFrameTime()
        return true
    }
    for building in standing_buildings {
        if rl.Vector2Distance(player_pos, {building.rect.x, building.rect.y}) <= SPRITE_SIZE - 6 {
            player_pos -= player_velocity * rl.GetFrameTime()
            return true
        }
    }
    return false
}

player_init :: proc() {
    pos_array: [dynamic]f32 = {}
    defer delete(pos_array)
    for i:f32 = 0; i < 256; i += 1 {
        append(&pos_array, i)
    }
    player_pos = {rand.choice(pos_array[:]) * SPRITE_SIZE, rand.choice(pos_array[:]) * SPRITE_SIZE}
}

player_update :: proc() {
    initial_pos_x := player_rect.x
    initial_pos_y := player_rect.y
    input_dir: rl.Vector2 = {0, 0}

    if rl.IsKeyDown(.W){
        input_dir.y -= PLAYER_SPEED
    }
    if rl.IsKeyDown(.S){
        input_dir.y += PLAYER_SPEED
    }
    if rl.IsKeyDown(.A){
        input_dir.x -= PLAYER_SPEED
    }
    if rl.IsKeyDown(.D){
        input_dir.x += PLAYER_SPEED
    }

    player_velocity = rl.Vector2Normalize(input_dir) * PLAYER_SPEED
    player_pos += player_velocity * rl.GetFrameTime()
    player_velocity *= 0.99
    if !player_check_collisions() {
        player_rect.x = player_pos.x
        player_rect.y = player_pos.y
    }

    player_direction = {player_rect.x - initial_pos_x, player_rect.y - initial_pos_y}

    adjust_camera_to_player()
}

player_render :: proc() {
    tmp_string = fmt.tprintf("skin%v", player_anim_stage)
    rl.DrawTextureRec(gfx[tmp_string], {0, 0, player_rect.width, player_rect.height}, {player_rect.x, player_rect.y}, rl.WHITE)
    second += rl.GetFrameTime()
    if second >= ANIM_SPEED {
        second -= ANIM_SPEED
        if player_direction.x != 0 || player_direction.y != 0 {
            switch player_anim_stage {
                case 0: player_anim_stage = 1
                case 1: player_anim_stage = 2
                case 2: player_anim_stage = 0
            }
        }
    }

    if player_direction.x >= 0 {
        player_rect.width = math.abs(player_rect.width)
    } else{
        player_rect.width = -math.abs(player_rect.width)
    }
}

player_pos_render :: proc() {
    player_pos_text := rl.TextFormat("x: %v\ny: %v", i32(player_pos.x / SPRITE_SIZE), i32(player_pos.y / SPRITE_SIZE))
    rl.DrawTextEx(font, player_pos_text, {100, 100}, 12, 0, rl.BLACK)
}

adjust_camera_to_player :: proc() {
    pos_x := player_rect.x - (VIRTUAL_WIDTH / 2)
    pos_y := player_rect.y - (VIRTUAL_HEIGHT / 2)

    max_pos_x: f32 = TILEMAP_WIDTH - math.floor_f32(VIRTUAL_WIDTH / SPRITE_SIZE)
    max_pos_y: f32 = TILEMAP_HEIGHT - math.floor_f32(VIRTUAL_HEIGHT / SPRITE_SIZE)

    main_camera.target.x = rl.Clamp(pos_x, 0, max_pos_x * SPRITE_SIZE)
    main_camera.target.y = rl.Clamp(pos_y, 0, max_pos_y * SPRITE_SIZE)
}
