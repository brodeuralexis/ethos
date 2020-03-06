pub const MultibootHeader = packed struct {
    magic: usize,
    flags: usize,
    checksum: usize,
};
