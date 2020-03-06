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

pub inline fn hlt() noreturn {
    while (true) {
        asm volatile ("hlt");
    }
}

pub inline fn cli() void {
    asm volatile ("cli");
}

pub inline fn sti() void {
    asm volatile ("sti");
}

pub inline fn hang() noreturn {
    cli();
    hlt();
}

pub fn inb(port: u16) u8 {
    return asm volatile ("inb %[port], %[result]" : [result] "={al}" (-> u8)
                                                  : [port]   "N{dx}" (port));
}

pub fn outb(port: u16, value: u8) void {
    asm volatile ("outb %[value], %[port]" : : [value] "{al}" (value),
                                               [port]  "N{dx}" (port));
}
