package main

show_dialog: bool = true

first_dialogue :: proc() {
	if (show_dialog &&
		   ui_draw_dialog("Witaj!\nWcielasz sie w Uranka, ktorego rodzina zostala\nuwieziona w niestabilnym reaktorze.\n")) {
		show_dialog = false
	}
}

// second_dialogue :: proc() {
// 	if (show_dialog && ui_draw_dialog("Oto twój reaktor!\nMusisz go chronić przed przegrażeniem!")) {
// 		show_dialog = false
// 	}
// }
