const std = @import("std");

pub const BitBoard = @import("bit_board/BitBoard.zig");

/// The integer type used to represent a board
pub const MaskInt = u64;

/// The integer type used to shift a mask
pub const ShiftInt = std.math.Log2Int(MaskInt);
