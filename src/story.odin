package main

show_dialog: bool = true

dialogue_render :: proc() {

	if (show_dialog && ui_draw_dialog("Witaj!\nWcielasz sie w Uranka, ktorego rodzina zostala\nuwieziona w niestabilnym reaktorze.\n")) {
		show_dialog = false
	}
}
