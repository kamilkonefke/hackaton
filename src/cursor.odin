package main

import rl "vendor:raylib"

draw_cursor :: proc() {
	cursor: rl.Texture
	if is_on_hover && rl.IsMouseButtonDown(.LEFT) {
		cursor = gfx["cursor_hover_clicked"]
	} else if (is_on_hover) {
		cursor = gfx["cursor_hover_normal"]
	} else if rl.IsMouseButtonDown(.LEFT) {
		cursor = gfx["cursor_clicked"]
	} else {
		cursor = gfx["cursor_normal"]
	}
	mouse := rl.GetMousePosition()
	scale: f32 = 2

	rl.DrawTexturePro(
		cursor,
		rl.Rectangle{0.0, 0.0, f32(cursor.width), f32(cursor.height)},
		rl.Rectangle{mouse.x, mouse.y, f32(cursor.width) * scale, f32(cursor.height) * scale},
		rl.Vector2{8.0, 8.0},
		0.0,
		rl.WHITE,
	)
}
