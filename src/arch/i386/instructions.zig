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
