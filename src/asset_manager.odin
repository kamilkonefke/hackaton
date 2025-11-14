package main

import rl "vendor:raylib"
import "core:os"
import "core:strings"

gfx: map[string]rl.Texture
sfx: map[string]rl.Sound
font: rl.Font

GFX_FILE_FORMAT :: ".png"
SFX_FILE_FORMAT :: ".ogg"

assets_load :: proc() {
    rl.SetTextureFilter(font.texture, .POINT);
    font = rl.LoadFontEx("res/yoster.ttf", 24, nil, 0)

    handle, err_dir := os.open("./res") 
    files, err_files := os.read_dir(handle, -1)

    for file in files {
        if strings.has_suffix(file.name, GFX_FILE_FORMAT) {
            map_insert(&gfx, strings.trim_suffix(file.name, GFX_FILE_FORMAT), rl.LoadTexture(rl.TextFormat("%s", file.fullpath)))
        }
        else if strings.has_suffix(file.name, SFX_FILE_FORMAT) {
            map_insert(&sfx, strings.trim_suffix(file.name, SFX_FILE_FORMAT), rl.LoadSound(rl.TextFormat("%s", file.fullpath)))
        }
    }
}

assets_free :: proc() {
    rl.UnloadFont(font)

    for _, g in gfx {
        rl.UnloadTexture(g)
    }

    for _, s in sfx {
        rl.UnloadSound(s)
    }
}
