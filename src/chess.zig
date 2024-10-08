const castling = @import("chess/castling.zig");
const color = @import("chess/color.zig");
const square = @import("chess/square.zig");
const position = @import("chess/position.zig");

pub const BitBoard = @import("chess/BitBoard.zig");
pub const BitPieceMap = @import("chess/BitPieceMap.zig");
pub const CastleState = castling.State;
pub const CastleStatePacked = castling.StatePacked;
pub const Color = color.Color;
pub const File = square.File;
pub const Move = @import("chess/Move.zig");
pub const Piece = @import("chess/piece.zig").Piece;
pub const PieceList = @import("chess/PieceList.zig");
pub const PieceMap = @import("chess/PieceMap.zig");
pub const Placement = @import("chess/Placement.zig");
pub const PosHash = @import("chess/PosHash.zig");
pub const Position = position.Position;
pub const PositionPacked = position.PositionPacked;
pub const Rank = square.Rank;
pub const RankFile = square.RankFile;
pub const Side = color.Side;
pub const Square = square.Square;

pub const board = @import("chess/board.zig");
pub const starting = @import("chess/starting.zig");

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
