package main

import rl "vendor:raylib"

play_alpha: u8 = 180.0
play_pos: rl.Vector2
play_measure: rl.Vector2

pause_menu_update :: proc() {
    if rl.CheckCollisionPointRec(mouse_screen_position, {
        x = play_pos.x,
        y = play_pos.y,
        width = play_measure.x,
        height = play_measure.y
    }) {
        play_alpha = 225
        if rl.IsMouseButtonPressed(.LEFT) {
            current_game_state = .Game
        }
    } else {
        play_alpha = 180
    }
}

MENU_GAP: f32 = GAP * 4

pause_menu_render :: proc() {
    rl.DrawRectangle(0, 0, VIRTUAL_WIDTH, VIRTUAL_HEIGHT, COLOR_PURPLE)
    
    base_pos: rl.Vector2 = {
        VIRTUAL_WIDTH / 2,
        MARGIN,
    }

    game_name := rl.TextFormat("URANEK")
    game_name_measure := rl.MeasureTextEx(font, game_name, 56, 0)
    rl.DrawTextEx(font, game_name, {
        base_pos.x - game_name_measure.x / 2,
        base_pos.y
    }, 56, 0, {
        255,255,255,180
    })

    base_pos.y += MENU_GAP + game_name_measure.y 
    
    game_name2 := rl.TextFormat("I JEGO ELEKTROWNIA")
    game_name_measure2 := rl.MeasureTextEx(font, game_name2, 56, 0)
    rl.DrawTextEx(font, game_name2, {
        base_pos.x - game_name_measure2.x / 2,
        base_pos.y
    }, 56, 0, {
        255,255,255,180
    })
    
    base_pos.y += MENU_GAP / 2 + game_name_measure2.y 
   
    rl.DrawLineEx({
        MARGIN,
        base_pos.y
    }, {
        VIRTUAL_WIDTH - MARGIN,
        base_pos.y,
    }, 10.0, {
        255,255,255,180
    })

    base_pos.y += MENU_GAP / 2 + 10

    play_text := rl.TextFormat("PLAY")
    play_measure = rl.MeasureTextEx(font, play_text, 48, 0)
    play_pos = {
        base_pos.x - play_measure.x / 2,
        base_pos.y,
    }
    rl.DrawTextEx(font, play_text, play_pos, 48, 0, {
        255,255,255,play_alpha
    })
}

