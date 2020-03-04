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
