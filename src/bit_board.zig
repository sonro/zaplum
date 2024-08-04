const std = @import("std");

pub const BitBoard = @import("bit_board/BitBoard.zig");

/// The integer type used to represent a board
pub const MaskInt = u64;

/// The integer type used to index a board
pub const IndexInt = u8;

/// The integer type used to shift a mask
pub const ShiftInt = std.math.Log2Int(MaskInt);

/// The number of squares on a board
pub const size: IndexInt = @bitSizeOf(MaskInt);

/// A range of squares within a board
pub const Range = struct {
    /// The index of the first square of interest
    start: IndexInt,
    /// The index immediately after the last square of interest
    end: IndexInt,
};
