pub inline fn halt() noreturn {
    while (true) {
        asm volatile ("hlt");
    }
}

pub inline fn disable_interrupts() void {
    asm volatile ("cli");
}

pub inline fn enable_interrupts() void {
    asm volatile ("sti");
}

pub inline fn hang() noreturn {
    disable_interrupts();
    halt();
}

pub inline fn outb(port: u16, value: u8) void {
    asm volatile ("outb %[value], %[port]" : : [value] "{al}" (value),
                                               [port]  "N{dx}" (port));
}
