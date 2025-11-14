package main

import "core:fmt"
import rl "vendor:raylib"

balance: f32 = 10000.0

money_update :: proc(cost: f32) {
    balance -= cost
    fmt.println(balance)
}

money_render :: proc() {
    balance_text: cstring = rl.TextFormat("%v", balance)
    rl.DrawTextEx(font, balance_text, {300, 300}, 12, 0, rl.WHITE)
}