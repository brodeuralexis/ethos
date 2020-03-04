const builtin = @import("builtin");
const StackTrace = builtin.StackTrace;

pub usingnamespace @import("./boot/multiboot.zig");

const arch = @import("./arch.zig");
const vga = @import("./vga.zig");

const kmain = @import("./kmain.zig").kmain;

var stack: [32 * 1024]u8 align(16) linksection(".bss") = undefined;

pub fn panic(message: []const u8, stack_trace: ?*StackTrace) noreturn {
    vga.println("{}", .{ message });
    arch.hang();
}

export fn _start() callconv(.C) noreturn {
    vga.clear();
    vga.println("[kernel] starting", .{});

    @call(.{ .stack = stack[0..] }, kmain, .{});

    vga.println("[kernel] stopping", .{});
    arch.hang();
}
