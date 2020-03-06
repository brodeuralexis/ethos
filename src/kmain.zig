const SpinLock = @import("./lock.zig").SpinLock;

const drivers = @import("./drivers.zig");
const Serial = drivers.Serial;
const vga = drivers.vga;

pub fn kmain() void {
    vga.println("[kernel] initializing", .{});
    defer vga.println("[kernel] deinitializing", .{});

    var com1 = Serial.init(.COM1);
    defer com1.deinit();
    vga.println("[kernel] {} initialized", .{ com1 });
    defer vga.println("[kernel] {} deinitialized", .{ com1 });

    com1.println("THIS IS SPARTA!", .{});

    vga.println("[kernel] ready", .{});
}
