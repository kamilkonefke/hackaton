package main

import "core:fmt"
import noise "core:math/noise"

tilemap : [WIDTH*HEIGHT]f32

WIDTH :: 256
HEIGHT :: 256

tilemap_get_tile :: proc(x: int, y: int) -> f32 {
    if x < 0 || x >= WIDTH || y < 0 || y >= HEIGHT {
        return -1
    }

    return tilemap[y * HEIGHT + x]
}

tilemap_set_tile :: proc(x: int, y: int, tile: f32) {
    if x < 0 || x >= WIDTH || y < 0 || y >= HEIGHT {
        return
    }

    tilemap[y * HEIGHT + x] = tile
}

tilemap_generate :: proc(seed: i64) {
    for y: int = 0; y < HEIGHT; y+=1 {
        for x: int = 0; x < WIDTH; x+=1 {
            val := noise.noise_2d(seed, [2]f64{f64(x), f64(y)})
            tilemap_set_tile(x, y, val)
        }
    }
}

tilemap_print :: proc() {
    for y: int = 0; y < HEIGHT; y+=1 {
        for x: int = 0; x < WIDTH; x+=1 {
            tile := tilemap_get_tile(x, y)
            fmt.printf("{:.2f} ", tile)
        }
        fmt.println("")
    }
}