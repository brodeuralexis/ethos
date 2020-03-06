pub usingnamespace @import("./i386/instructions.zig");

usingnamespace @import("./boot/multiboot.zig");

const MAGIC = @as(usize, 0x1BADB002);
const ALIGN = @as(usize, 1 << 0);
const MEMINFO = @as(usize, 1 << 1);
const FLAGS = ALIGN | MEMINFO;

pub export const multiboot_header align(4) linksection(".multiboot") = MultibootHeader{
    .magic = MAGIC,
    .flags = FLAGS,
    .checksum = ~(MAGIC +% FLAGS) +% 1,
};

pub fn init() void {
    @import("./i386/gdt.zig").init();
}
