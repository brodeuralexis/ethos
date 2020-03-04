const std = @import("std");
const fmt = std.fmt;

const arch = @import("../arch.zig");

pub const COMPort = enum(u16) {
    COM1 = 0x3F8,
    COM2 = 0x2F8,
    COM3 = 0x3E8,
    COM4 = 0x2E8,
};

pub const Serial = struct {
    const Self = @This();

    port: COMPort,

    pub fn init(port: COMPort) Self {
        var self: Self = .{ .port = port };

        arch.outb(@enumToInt(self.port) + 1, 0x00);
        arch.outb(@enumToInt(self.port) + 3, 0x80);
        arch.outb(@enumToInt(self.port) + 0, 0x03);
        arch.outb(@enumToInt(self.port) + 1, 0x00);
        arch.outb(@enumToInt(self.port) + 3, 0x03);
        arch.outb(@enumToInt(self.port) + 2, 0xC7);
        arch.outb(@enumToInt(self.port) + 4, 0x0B);

        return self;
    }

    pub fn deinit(self: *Self) void {
    }

    fn received(self: *Self) u8 {
        return arch.inb(@enumToInt(self.port) + 5) & 1;
    }

    pub fn read(self: *Self) u8 {
        while (self.received() == 0) {}

        return arch.inb(@enumToInt(self.port));
    }

    fn isTransmitEmpty(self: *Self) u8 {
        return arch.inb(@enumToInt(self.port) + 5) & 0x20;
    }

    pub fn write(self: *Self, byte: u8) void {
        while (self.isTransmitEmpty() == 0) {}

        arch.outb(@enumToInt(self.port), byte);
    }

    pub fn print(self: *Self, comptime _format: []const u8, args: var) void {
        fmt.format(self, error{}, struct {
            fn output(serial: *Self, str: []const u8) error{}!void {
                for (str) |char| {
                    serial.write(char);
                }
            }
        }.output, _format, args) catch unreachable;
    }

    pub fn println(self: *Self, comptime _format: []const u8, args: var) void {
        self.print(_format ++ "\n", args);
    }

    pub fn format(self: *const Self, comptime _fmt: []const u8, _options: std.fmt.FormatOptions, context: var, comptime Errors: type, comptime output: fn (@TypeOf(context), []const u8) Errors!void) Errors!void {
        return fmt.format(context, Errors, output, "Serial({})", .{ @tagName(self.port) });
    }
};
