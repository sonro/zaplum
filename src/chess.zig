const color = @import("chess/color.zig");
pub const BitBoard = @import("chess/BitBoard.zig");
pub const Color = color.Color;
pub const Side = color.Side;
pub const Square = @import("chess/square.zig").Square;

/// The integer type used to index a board
pub const IndexInt = u8;

/// The number of squares on a board
pub const board_size: IndexInt = 64;

/// A range of squares within a board
pub const Range = struct {
    /// The index of the first square of interest
    start: IndexInt,
    /// The index immediately after the last square of interest
    end: IndexInt,
};

pub const Error = error{
    /// Color must be white or black
    InvalidColor,
};
