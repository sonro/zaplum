const color = @import("chess/color.zig");
const square = @import("chess/square.zig");

pub const BitBoard = @import("chess/BitBoard.zig");
pub const Color = color.Color;
pub const File = square.File;
pub const Piece = @import("chess/piece.zig").Piece;
pub const Placement = @import("chess/Placement.zig");
pub const Rank = square.Rank;
pub const RankFile = square.RankFile;
pub const Side = color.Side;
pub const Square = square.Square;

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
