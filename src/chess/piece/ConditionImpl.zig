const std = @import("std");

const chess = @import("../../chess.zig");
const Side = chess.Side;
const Color = chess.Color;
const Piece = chess.Piece;
const Kind = Piece.Kind;

pub fn fromColorKind(color: Color, piece_kind: Kind) Piece {
    if (piece_kind == .none) {
        return .none;
    }
    var index = if (color == .white) 0 else @intFromEnum(Piece.black_pawn);
    index += @intFromEnum(piece_kind);
    return @enumFromInt(index);
}

pub fn side(self: Piece) Side {
    return switch (self) {
        .white_pawn,
        .white_knight,
        .white_bishop,
        .white_rook,
        .white_queen,
        .white_king,
        => .white,

        .black_pawn,
        .black_knight,
        .black_bishop,
        .black_rook,
        .black_queen,
        .black_king,
        => .black,

        .none => .none,
    };
}

pub fn kind(self: Piece) Kind {
    return switch (self) {
        .white_pawn, .black_pawn => .pawn,
        .white_knight, .black_knight => .knight,
        .white_bishop, .black_bishop => .bishop,
        .white_rook, .black_rook => .rook,
        .white_queen, .black_queen => .queen,
        .white_king, .black_king => .king,
        .none => .none,
    };
}

pub fn humanValue(self: Piece) i8 {
    return switch (self) {
        .white_pawn => 1,
        .white_knight => 3,
        .white_bishop => 3,
        .white_rook => 5,
        .white_queen => 9,
        .white_king => 50,

        .black_pawn => -1,
        .black_knight => -3,
        .black_bishop => -3,
        .black_rook => -5,
        .black_queen => -9,
        .black_king => -50,
        .none => 0,
    };
}

pub fn isMajor(self: Piece) bool {
    return switch (self) {
        .white_rook,
        .white_queen,
        .white_king,
        .black_rook,
        .black_queen,
        .black_king,
        => true,
        else => false,
    };
}

pub fn isMinor(self: Piece) bool {
    return switch (self) {
        .white_knight,
        .white_bishop,
        .black_knight,
        .black_bishop,
        => true,
        else => false,
    };
}

pub fn isBig(self: Piece) bool {
    if (self == .none or self.kind() == .pawn) return false;
    return true;
}

pub fn isSlider(self: Piece) bool {
    return switch (self) {
        .white_bishop,
        .white_rook,
        .white_queen,
        .black_bishop,
        .black_rook,
        .black_queen,
        => true,
        else => false,
    };
}

pub fn isDiagonalSlider(self: Piece) bool {
    return switch (self) {
        .white_bishop,
        .black_bishop,
        .white_queen,
        .black_queen,
        => true,
        else => false,
    };
}

pub fn isOrthogonalSlider(self: Piece) bool {
    return switch (self) {
        .white_rook,
        .black_rook,
        .white_queen,
        .black_queen,
        => true,
        else => false,
    };
}

pub fn char(self: Piece) u8 {
    return switch (self) {
        .white_pawn => 'P',
        .white_knight => 'N',
        .white_bishop => 'B',
        .white_rook => 'R',
        .white_queen => 'Q',
        .white_king => 'K',

        .black_pawn => 'p',
        .black_knight => 'n',
        .black_bishop => 'b',
        .black_rook => 'r',
        .black_queen => 'q',
        .black_king => 'k',

        .none => '-',
    };
}

pub fn maxAllowed(self: Piece) u8 {
    return switch (self.kind()) {
        .pawn => Piece.max_pawns,
        .knight => Piece.max_knights,
        .bishop => Piece.max_bishops,
        .rook => Piece.max_rooks,
        .queen => Piece.max_queens,
        .king => Piece.max_kings,
        .none => 0,
    };
}

comptime {
    const tests = @import("tests.zig");
    _ = tests.TestImpl(@This());
}
