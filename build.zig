const std = @import("std");
const Builder = std.build.Builder;
const ArrayList = std.ArrayList;

const builtin = @import("builtin");

pub fn build(b: *Builder) void {
    const mode = b.standardReleaseOptions();
    const kernel = b.addExecutable("ethos", "src/boot.zig");
    kernel.setBuildMode(mode);
    kernel.setOutputDir(".");
    kernel.install();

    kernel.setTarget(.i386, .freestanding, .gnu);
    kernel.setLinkerScriptPath("./linker.ld");

    const qemu       = b.step("qemu",       "Run the OS with Qemu");
    const qemu_debug = b.step("qemu-debug", "Run the OS with Qemu and wait for debugger to attach");

    const common_params = [_][]const u8 {
        "qemu-system-i386",
        "-kernel", kernel.getOutputPath(),
    };
    const debug_params = [_][]const u8 {"-s", "-S"};

    var qemu_params       = ArrayList([]const u8).init(b.allocator);
    var qemu_debug_params = ArrayList([]const u8).init(b.allocator);
    for (common_params) |p| { qemu_params.append(p) catch unreachable; qemu_debug_params.append(p) catch unreachable; }
    for (debug_params)  |p| {                                          qemu_debug_params.append(p) catch unreachable; }

    const run_qemu       = b.addSystemCommand(qemu_params.toSlice());
    const run_qemu_debug = b.addSystemCommand(qemu_debug_params.toSlice());

    run_qemu.step.dependOn(b.default_step);
    run_qemu_debug.step.dependOn(b.default_step);
    qemu.dependOn(&run_qemu.step);
    qemu_debug.dependOn(&run_qemu_debug.step);
}
