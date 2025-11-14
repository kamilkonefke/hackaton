package main

import "core:fmt"

tilemap : [WIDTH*HEIGHT]int

WIDTH :: 256
HEIGHT :: 256

tilemap_init :: proc() {
    for y: int = 0; y < HEIGHT; y+=1 {
        for x: int = 0; x < WIDTH; x+=1 {
            tilemap[y * HEIGHT + x] = 0
        }
    }
    fmt.println(WIDTH, HEIGHT)
}

tilemap_get_tile :: proc(x: int, y: int) -> int {
    if x < 0 || x >= WIDTH || y < 0 || y >= HEIGHT {
        return -1
    }

    return tilemap[y * HEIGHT + x]
}

tilemap_set_tile :: proc(x: int, y: int, tile: int) {
    if x < 0 || x >= WIDTH || y < 0 || y >= HEIGHT {
        return
    }

    tilemap[y * HEIGHT + x] = tile
}