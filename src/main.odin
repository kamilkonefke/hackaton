package main

import "core:math"
import rl "vendor:raylib"

WINDOW_WIDTH :: 1280
WINDOW_HEIGHT :: 720

VIRTUAL_WIDTH :: 640
VIRTUAL_HEIGHT :: 360

current_game_state: GameState = .SplashScreen

mouse_screen_position: rl.Vector2 = {0.0, 0.0}
scale: f32 = 0.0

main_camera: rl.Camera2D = rl.Camera2D{
    target = {0.0, 0.0},
    offset = {0.0, 0.0},
    rotation = 0.0,
    zoom = 1.0,
}

is_on_hover: bool = false

main :: proc() {
    rl.SetConfigFlags(rl.ConfigFlags{.VSYNC_HINT, .WINDOW_RESIZABLE})
    rl.InitWindow(1280, 720, "Hackaton")
    defer rl.CloseWindow()

	rl.HideCursor()

    render_target := rl.LoadRenderTexture(VIRTUAL_WIDTH, VIRTUAL_HEIGHT)
    rl.SetTextureFilter(render_target.texture, .POINT)
    defer rl.UnloadRenderTexture(render_target)

    assets_load()
    defer assets_free()
    game_init()
    splash_screen_init()

    for !rl.WindowShouldClose() {
        scale = math.min(f32(rl.GetScreenWidth() / VIRTUAL_WIDTH), f32(rl.GetScreenHeight() / VIRTUAL_HEIGHT))
        mouse := rl.GetMousePosition()
        mouse_screen_position.x = (mouse.x - (f32(rl.GetScreenWidth()) - (VIRTUAL_WIDTH * scale)) * 0.5) / scale
        mouse_screen_position.y = (mouse.y - (f32(rl.GetScreenHeight()) - (VIRTUAL_HEIGHT * scale)) * 0.5) / scale
        if current_game_state == .SplashScreen {
            splash_screen_update()
        } else {
            game_update()
            ui_update()
        }
        
        rl.BeginTextureMode(render_target)
        rl.BeginMode2D(main_camera)
        rl.ClearBackground(COLOR_PURPLE)
        if current_game_state == .Game {
            game_render()
        }
        rl.EndMode2D()
        if current_game_state == .SplashScreen {
            splash_screen_render()
        } else {
            ui_render()
        }
        rl.EndTextureMode()

        rl.BeginDrawing()
        rl.ClearBackground(rl.BLACK)
        rl.DrawTexturePro(
            render_target.texture, 
            {0.0, 0.0, f32(render_target.texture.width), f32(-render_target.texture.height)}, 
            {(f32(rl.GetScreenWidth()) - (f32(VIRTUAL_WIDTH) * scale)) * 0.5, (f32(rl.GetScreenHeight()) - (f32(VIRTUAL_HEIGHT) * scale)) * 0.5, VIRTUAL_WIDTH * scale, VIRTUAL_HEIGHT * scale},
            {0.0, 0.0},
            0.0,
            rl.WHITE
        )
        draw_cursor()
        rl.EndDrawing()
    }
}

GameState :: enum {
    SplashScreen,
    PauseMenu,
    Game
}
