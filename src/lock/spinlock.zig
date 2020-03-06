const std = @import("std");
const fmt = std.fmt;

pub const SpinLock = struct {
    const Self = @This();

    value: isize,

    pub fn init(value: isize) Self {
        return .{ .value = value, };
    }

    pub fn signal(self: *Self) void {
        _ = @atomicRmw(isize, &self.value, .Add, 1, .SeqCst);
    }

    pub fn wait(self: *Self) void {
        while (true) {
            var value = @atomicLoad(isize, &self.value, .SeqCst);

            if (value > 0 and @cmpxchgWeak(isize, &self.value, value, value - 1, .SeqCst, .SeqCst) == null) {
                break;
            }
        }
    }

    pub const TryWaitError = error {
        WouldBlock,
    };

    pub fn tryWait(self: *Self) TryWaitError!void {
        var value = @atomicLoad(isize, &self.value, .SeqCst);

        if (value > 0 and @cmpxchgStrong(isize, &self.value, value, value - 1, .SeqCst, .SeqCst) == null) {
            return;
        }

        return TryWaitError.WouldBlock;
    }

    pub fn format(self: Self, comptime _fmt: []const u8, _options: fmt.FormatOptions, context: var, comptime Errors: type, comptime output: fn (@TypeOf(context), []const u8) Errors!void) Errors!void {
        return fmt.format(context, Errors, output, "SpinLock({})", .{ self.value });
    }
};
