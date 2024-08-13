//! Union data for `BitPieceMap`
const Extra = @This();

const std = @import("std");
const testing = std.testing;
const assert = std.debug.assert;

const chess = @import("../../chess.zig");
const BitPieceMap = chess.BitPieceMap;
const BitBoard = chess.BitBoard;
const Color = chess.Color;
const Piece = chess.Piece;

/// `BitBoard` union per `Color`
color: [2]BitBoard,
/// `BitBoard` union per `Piece.Kind`
kind: [Piece.Kind.hard_count]BitBoard,
/// `BitBoard` union of all `Piece`s
all: BitBoard,

/// `Extra` from a `BitPieceMap`
pub fn init(self: *const BitPieceMap) Extra {
    var ex: Extra = undefined;
    ex.color[Color.white.toU1()] = self.getColor(.white);
    ex.color[Color.black.toU1()] = self.getColor(.black);
    ex.kind[Piece.Kind.pawn.toU3()] = self.getKind(Piece.Kind.pawn);
    ex.kind[Piece.Kind.knight.toU3()] = self.getKind(Piece.Kind.knight);
    ex.kind[Piece.Kind.bishop.toU3()] = self.getKind(Piece.Kind.bishop);
    ex.kind[Piece.Kind.rook.toU3()] = self.getKind(Piece.Kind.rook);
    ex.kind[Piece.Kind.queen.toU3()] = self.getKind(Piece.Kind.queen);
    ex.kind[Piece.Kind.king.toU3()] = self.getKind(Piece.Kind.king);
    ex.all = ex.color[0].unionWith(ex.color[1]);
    return ex;
}

/// Update this `Extra` from a `BitPieceMap`
///
/// Call this to keep `Extra` in sync with `BitPieceMap` changes
pub fn update(self: *Extra, map: *const BitPieceMap, piece: Piece) void {
    const board = map.get(piece);
    self.all.setUnion(board);
    self.color[piece.side().toU2()].setUnion(board);
    self.kind[piece.kind().toU3()].setUnion(board);
}

test "init" {
    var map = BitPieceMap.empty;
    map.setSquare(.white_pawn, .a2);
    map.setSquare(.white_knight, .b1);
    map.setSquare(.black_knight, .b8);
    map.setSquare(.black_queen, .d8);

    const extra = Extra.init(&map);
    try testing.expectEqual(extra.all, map.getAll());
    try testing.expectEqual(extra.color[Color.white.toU1()], map.getColor(.white));
    try testing.expectEqual(extra.color[Color.black.toU1()], map.getColor(.black));
    try testing.expectEqual(extra.kind[Piece.Kind.pawn.toU3()], map.getKind(.pawn));
    try testing.expectEqual(extra.kind[Piece.Kind.knight.toU3()], map.getKind(.knight));
    try testing.expectEqual(extra.kind[Piece.Kind.queen.toU3()], map.getKind(.queen));
}

test "update" {
    var map = BitPieceMap.empty;
    var extra = Extra.init(&map);
    map.setSquare(.white_pawn, .a2);

    extra.update(&map, .white_pawn);
    try testing.expectEqual(extra.all, map.getAll());
    try testing.expectEqual(extra.color[Color.white.toU1()], map.getColor(.white));
    try testing.expectEqual(extra.kind[Piece.Kind.pawn.toU3()], map.getKind(.pawn));
}
