const mem = @import("std").mem;
const fmt = @import("std").fmt;

const arch = @import("./arch.zig");

const VGA_WIDTH: usize = 80;
const VGA_HEIGHT: usize = 25;
const VGA_SIZE: usize = VGA_WIDTH * VGA_HEIGHT;
const VGA_ADDRESS: usize = 0xB8000;

pub const Color = enum(u4) {
    Black        = 0,
    Blue         = 1,
    Green        = 2,
    Cyan         = 3,
    Red          = 4,
    Magenta      = 5,
    Brown        = 6,
    LightGrey    = 7,
    DarkGrey     = 8,
    LightBlue    = 9,
    LightGreen   = 10,
    LightCyan    = 11,
    LightRed     = 12,
    LightMagenta = 13,
    LightBrown   = 14,
    White        = 15,
};

pub const Entry = packed struct {
    char: u8,
    foreground: Color,
    background: Color,
};

const SECOND_LINE_START: usize = VGA_WIDTH;
const LAST_LINE_START: usize = VGA_SIZE - VGA_WIDTH;

const DEFAULT_FOREGROUND: Color = .LightGrey;
const DEFAULT_BACKGROUND: Color = .Black;

var memory = @intToPtr([*]Entry, 0xB8000)[0..VGA_SIZE];

pub var cursor: usize = 0;
pub var foreground: Color = DEFAULT_FOREGROUND;
pub var background: Color = DEFAULT_BACKGROUND;

pub fn reset() void {
    clear();
    foreground = DEFAULT_FOREGROUND;
    background = DEFAULT_BACKGROUND;
}

pub fn clear() void {
    mem.set(Entry, memory, entry(' '));
    cursor = 0;
}

pub fn println(comptime format: []const u8, args: var) void {
    print(format ++ "\n", args);
}

pub fn print(comptime format: []const u8, args: var) void {
    fmt.format(@as(usize, 0), error{}, struct {
        fn output(_: usize, str: []const u8) error{}!void {
            for (str) |char| {
                write(char);
            }
        }
    }.output, format, args) catch unreachable;
}

fn write(char: u8) void {
    switch (char) {
        0x20...0x7E => writeChar(char),
        else => writeChar(char),
    }
}

fn writeChar(char: u8) void {
    if (char == '\n') {
        cursor += VGA_WIDTH;
        cursor -= cursor % VGA_WIDTH;
        return;
    }

    if (cursor >= VGA_SIZE) {
        scroll();
    }

    memory[cursor] = entry(char);
    cursor += 1;
}

fn scroll() void {
    mem.copy(Entry, memory[0..LAST_LINE_START], memory[SECOND_LINE_START..VGA_SIZE]);
    mem.set(Entry, memory[LAST_LINE_START..VGA_SIZE], entry(' '));
    cursor = LAST_LINE_START;
}

fn entry(char: u8) Entry {
    return .{
        .char = char,
        .foreground = foreground,
        .background = background,
    };
}
