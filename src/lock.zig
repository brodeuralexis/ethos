const std = @import("std");
const traits = std.meta.traits;

pub usingnamespace @import("./lock/spinlock.zig");

pub const isSemaphore = traits.multiTrait(&[_]traits.TraitFn{
    traits.hasFn("signal"),
    traits.hasFn("wait"),
});
