package main

import rl "vendor:raylib"
import noise "core:math/noise"
import "core:math"

tilemap : [TILEMAP_WIDTH*TILEMAP_HEIGHT]string

TILEMAP_WIDTH :: 256
TILEMAP_HEIGHT :: 256

// USE: tilemap_generate(seed)
// tilemap_render()

tilemap_get_tile :: proc(x: int, y: int) -> string {
    if x < 0 || x >= TILEMAP_WIDTH || y < 0 || y >= TILEMAP_HEIGHT {
        return "none"
    }

    return tilemap[y * TILEMAP_HEIGHT + x]
}

tilemap_set_tile :: proc(x: int, y: int, tile: string) {
    if x < 0 || x >= TILEMAP_WIDTH || y < 0 || y >= TILEMAP_HEIGHT {
        return
    }

    tilemap[y * TILEMAP_WIDTH + x] = tile
}

tilemap_generate :: proc(seed: i64) {
    for y: int = 0; y < TILEMAP_HEIGHT; y+=1 {
        for x: int = 0; x < TILEMAP_WIDTH; x+=1 {
            val: f32 = noise.noise_2d(seed, [2]f64{f64(x), f64(y)})
            tilemap_set_tile(x, y, map_f32_to_sprite(val))
        }
    }
}

tilemap_render :: proc() {
    offset_x := player_rect.x + main_camera.offset.x
    offset_y := player_rect.y + main_camera.offset.y

    startTileX := math.floor(main_camera.offset.x / 16) * 16
    startTileY := math.floor(main_camera.offset.y / 16) * 16

    numTilesX := int(VIRTUAL_WIDTH / 16) + 2
    numTilesY := int(VIRTUAL_HEIGHT / 16) + 2

    for y := int(startTileY); y < numTilesY; y+=1 {
        for x := int(startTileX); x < numTilesX; x+=1 {
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