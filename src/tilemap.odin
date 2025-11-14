package main

import rl "vendor:raylib"
import noise "core:math/noise"
import "core:math"

Tile :: struct {
    sprite: string,
    rotation: f32
}

tilemap : [TILEMAP_WIDTH*TILEMAP_HEIGHT]Tile

TILEMAP_WIDTH :: 256
TILEMAP_HEIGHT :: 256

GROUND_TILES :: []Tile {
    Tile{"ground", 0.0},
    Tile{"ground", 90.0},
    Tile{"ground", 180.0},
    Tile{"ground", 270.0},
}

// USE: tilemap_generate(seed)
// tilemap_render()

tilemap_get_tile :: proc(x: int, y: int) -> Tile {
    if x < 0 || x >= TILEMAP_WIDTH || y < 0 || y >= TILEMAP_HEIGHT {
        return Tile{sprite = "none", rotation = 0.0}
    }

    return tilemap[y * TILEMAP_HEIGHT + x]
}

tilemap_set_tile :: proc(x: int, y: int, tile: Tile) {
    if x < 0 || x >= TILEMAP_WIDTH || y < 0 || y >= TILEMAP_HEIGHT {
        return
    }

    tilemap[y * TILEMAP_WIDTH + x] = tile
}

tilemap_generate :: proc(seed: i64) {
    for y: int = 0; y < TILEMAP_HEIGHT; y+=1 {
        for x: int = 0; x < TILEMAP_WIDTH; x+=1 {
            val: f32 = noise.noise_2d(seed, [2]f64{f64(x), f64(y)})
            tilemap_set_tile(x, y, map_f32_to_tile(val))
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
            tex, exists := gfx[tile.sprite]

            xCoord: i32 = i32(x * 16)
            yCoord: i32 = i32(y * 16)
            if exists {
                rl.DrawTexturePro(
                    tex,
                    rl.Rectangle{0.0, 0.0, f32(tex.width), f32(tex.height)},
                    rl.Rectangle{f32(xCoord), f32(yCoord), 16.0, 16.0},
                    rl.Vector2{8.0, 8.0},
                    tile.rotation,
                    rl.WHITE
                );
            }
        }
    }
}

@private
map_f32_to_tile :: proc(value: f32) -> Tile {
    val := (value + 1) / 2 // between 0 and 1
    len := f32(len(GROUND_TILES))

    sprite_id := int(math.floor(val * len))

    tiles := GROUND_TILES
    return tiles[sprite_id]
}