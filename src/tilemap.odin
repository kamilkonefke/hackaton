package main

import rl "vendor:raylib"
import noise "core:math/noise"
import "core:math"
import "core:fmt"

Tile :: struct {
    sprite: string,
    rotation: f32
}

TileGroup :: struct {
    tiles: []Tile,
    weight: f32
}

tilemap : [TILEMAP_WIDTH*TILEMAP_HEIGHT]Tile

TILEMAP_WIDTH :: 256
TILEMAP_HEIGHT :: 256

TILEMAP_DRAW_OFFSET_X :: 8
TILEMAP_DRAW_OFFSET_Y :: 8

SPRITE_SIZE :: 16

GROUND_TILES :: []TileGroup {
    // Default value if not found
    TileGroup { tiles = {
        Tile{"none", 0.0},
    }, weight = 0.0},

    TileGroup { tiles = {
        Tile{"ground", 0.0},
        Tile{"ground", 90.0},
        Tile{"ground", 180.0},
        Tile{"ground", 270.0},
    }, weight = 5.0},
    TileGroup { tiles = {
        Tile{"water", 0.0}
    }, weight = 1.0}
}

WEIGHT_SUM :: 6

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
    startTileX := math.floor(main_camera.target.x / SPRITE_SIZE)
    startTileY := math.floor(main_camera.target.y / SPRITE_SIZE)

    numTilesX := int(VIRTUAL_WIDTH / SPRITE_SIZE) + 2
    numTilesY := int(VIRTUAL_HEIGHT / SPRITE_SIZE) + 2

    for y := int(startTileY); y < int(startTileY) + numTilesY; y+=1 {
        for x := int(startTileX); x < int(startTileX) + numTilesX; x+=1 {
            tile := tilemap_get_tile(x, y)
            tex, exists := gfx[tile.sprite]

            xCoord: i32 = i32(x * SPRITE_SIZE) + TILEMAP_DRAW_OFFSET_X
            yCoord: i32 = i32(y * SPRITE_SIZE) + TILEMAP_DRAW_OFFSET_Y
            if exists {
                rl.DrawTexturePro(
                    tex,
                    rl.Rectangle{0.0, 0.0, f32(tex.width), f32(tex.height)},
                    rl.Rectangle{f32(xCoord), f32(yCoord), SPRITE_SIZE, SPRITE_SIZE},
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
    
    random_weight := val * WEIGHT_SUM

    prev_weight: f32 = 0.0
    for t_group in GROUND_TILES {
        if random_weight - prev_weight < t_group.weight {
            inner_val := (random_weight - prev_weight) / t_group.weight // between 0 and 1
            tiles := t_group.tiles
            tiles_len := f32(len(tiles))
            sprite_id := int(math.floor(inner_val * tiles_len))
            return tiles[sprite_id]
        }

        prev_weight += t_group.weight
    }

    return GROUND_TILES[0].tiles[0]
}