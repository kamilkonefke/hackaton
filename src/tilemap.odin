package main

tilemap : [256*256]int

WIDTH :: 256
HEIGHT :: 256


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