const vga = @import("./vga.zig");
const SpinLock = @import("./lock.zig").SpinLock;

pub fn kmain() void {
    vga.println("[kernel] initializing", .{});
    defer vga.println("[kernel] deinitializing", .{});

    vga.println("[kernel] ready", .{});
}
