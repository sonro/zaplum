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
pub fn init(map: *const BitPieceMap) Extra {
    var self: Extra = undefined;
    self.color[Color.white.toU1()] = map.getColor(.white);
    self.color[Color.black.toU1()] = map.getColor(.black);
    self.kind[Piece.Kind.pawn.toU3()] = map.getKind(Piece.Kind.pawn);
    self.kind[Piece.Kind.knight.toU3()] = map.getKind(Piece.Kind.knight);
    self.kind[Piece.Kind.bishop.toU3()] = map.getKind(Piece.Kind.bishop);
    self.kind[Piece.Kind.rook.toU3()] = map.getKind(Piece.Kind.rook);
    self.kind[Piece.Kind.queen.toU3()] = map.getKind(Piece.Kind.queen);
    self.kind[Piece.Kind.king.toU3()] = map.getKind(Piece.Kind.king);
    self.all = self.color[0].unionWith(self.color[1]);
    return self;
}

/// Update this `Extra` from a `BitPieceMap`
///
/// Call this to keep `Extra` in sync with `BitPieceMap` changes
pub fn update(self: *Extra, map: *const BitPieceMap, piece: Piece) void {
    assert(piece != .none);
    const side = piece.side();
    const kind = piece.kind();
    self.color[side.toU2()] = map.getSide(side);
    self.kind[kind.toU3()] = map.getKind(kind);
    self.all = self.color[0].unionWith(self.color[1]);
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
