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

pub fn in(comptime T: type, port: u16) T {
    switch (T) {
        u8 => {
            return inb(port);
        },
        else => {
            @compileError("i386 received an invalid input type: " ++ @typeName(T));
        },
    }
}

pub fn out(comptime T: type, port: u16, value: T) void {
    switch (T) {
        u8 => {
            outb(port, value);
        },
        else => {
            @compileError("i386 received an invalid output type: " ++ @typeName(T));
        },
    }
}

inline fn inb(port: u16) u8 {
    return asm volatile ("inb %[port], %[result]" : [result] "={al}" (-> u8)
                                                  : [port]   "N{dx}" (port));
}

inline fn outb(port: u16, value: u8) void {
    asm volatile ("outb %[value], %[port]" : : [value] "{al}" (value),
                                               [port]  "N{dx}" (port));
}
