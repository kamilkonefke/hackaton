package main

import "core:fmt"
import rl "vendor:raylib"
import noise "core:math/noise"

tilemap : [WIDTH*HEIGHT]string

WIDTH :: 256
HEIGHT :: 256

// USE: tilemap_generate(seed)
// tilemap_render()

tilemap_get_tile :: proc(x: int, y: int) -> string {
    if x < 0 || x >= WIDTH || y < 0 || y >= HEIGHT {
        return "none"
    }

    return tilemap[y * HEIGHT + x]
}

tilemap_set_tile :: proc(x: int, y: int, tile: string) {
    if x < 0 || x >= WIDTH || y < 0 || y >= HEIGHT {
        return
    }

    tilemap[y * HEIGHT + x] = tile
}

tilemap_generate :: proc(seed: i64) {
    for y: int = 0; y < HEIGHT; y+=1 {
        for x: int = 0; x < WIDTH; x+=1 {
            val: f32 = noise.noise_2d(seed, [2]f64{f64(x), f64(y)})
            tilemap_set_tile(x, y, map_f32_to_sprite(val))
        }
    }
}

test: u8 = 0

tilemap_render :: proc() {
    for y: int = 0; y < HEIGHT; y+=1 {
        for x: int = 0; x < WIDTH; x+=1 {
            tile := tilemap_get_tile(x, y)
            tex, ok := gfx[tile]

            xCoord: i32 = i32(x * 16)
            yCoord: i32 = i32(y * 16)
            if ok do rl.DrawTexture(tex, xCoord, yCoord, rl.WHITE)

        }
    }
}

@private
map_f32_to_sprite :: proc(value: f32) -> string {
    if value < -0.5 {
        return "water"
    } else if value < 0.0 {
        return "ground"
    } else if value < 0.5 {
        return "skin"
    } else {
        return "mountain"
    }
}