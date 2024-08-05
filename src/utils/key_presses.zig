const std = @import("std");

extern fn _getch() c_int;

const arrow_key_hex = 0xE0;
const up_arrow = 0x48;
const down_arrow = 0x50;

const enter_key =  0x0D;
const quit_key = 0x71;

pub fn key_press_poll() []const u8 {
    const key_input = _getch();
    if (key_input == arrow_key_hex) {
        const arrow_key = _getch();
        switch (arrow_key) {
            up_arrow => return "up",
            down_arrow => return "down",
            else => return "",
        }
    }
    else if(key_input == enter_key) { return "enter"; }
    else if(key_input == quit_key) { return "quit"; }
    else { return ""; }
}
