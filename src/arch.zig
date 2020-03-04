const builtin = @import("builtin");

pub usingnamespace switch (builtin.arch) {
    .i386 => @import("./arch/i386.zig"),
    else => @compileError("Unsupported architecture " ++ @tagName(builtin.arch)),
};
