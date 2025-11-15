package main

import rl "vendor:raylib"
show_dialog: bool = true

dialogue_render :: proc() {

	if (show_dialog && ui_draw_dialog("abdbasbdhasbhdbh")) {
		show_dialog = false
	}
}
