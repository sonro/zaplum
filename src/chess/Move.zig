const Move = @This();

const std = @import("std");
const testing = std.testing;
const assert = std.debug.assert;

const chess = @import("../chess.zig");
const CastleState = chess.CastleState;
const Color = chess.Color;
const Piece = chess.Piece;
const Square = chess.Square;

piece: Piece,
from: Square,
to: Square,
kind: Kind = .standard,
check: Check = .none,

pub const Check = enum(u2) {
    none,
    check,
    checkmate,
    stalemate,
};

pub const Kind = union(enum) {
    standard,
    en_pas_capture,
    en_pas_trigger: Square,
    capture: Piece,
    promotion: Piece,
    promotion_capture: PromotionCapture,
    castle: Castle,
};

pub const PromotionCapture = packed struct {
    promotion: Piece,
    capture: Piece,
};

pub const Castle = enum(u4) {
    white_king = initCastleValue(.{ .white_king = true }),
    white_queen = initCastleValue(.{ .white_queen = true }),
    black_king = initCastleValue(.{ .black_king = true }),
    black_queen = initCastleValue(.{ .black_queen = true }),
};

fn initCastleValue(state: CastleState) u4 {
    return state.toU4();
}
