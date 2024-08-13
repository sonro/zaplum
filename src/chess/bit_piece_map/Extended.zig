const Extended = @This();

const std = @import("std");
const testing = std.testing;
const assert = std.debug.assert;

const chess = @import("../../chess.zig");
const BitPieceMap = chess.BitPieceMap;
const BitBoard = chess.BitBoard;
const Color = chess.Color;
const Extra = BitPieceMap.Extra;
const IndexInt = chess.IndexInt;
const MaskInt = BitBoard.MaskInt;
const Piece = chess.Piece;
const Side = chess.Side;
const Square = chess.Square;

map: BitPieceMap,
extra: Extra,

pub const empty = Extended{
    .map = BitPieceMap.empty,
    .extra = Extra.init(&BitPieceMap.empty),
};

pub const starting = Extended{
    .map = BitPieceMap.starting,
    .extra = Extra.init(&BitPieceMap.starting),
};

pub fn init(map: BitPieceMap) Extended {
    return Extended{
        .map = map,
        .extra = Extra.init(&map),
    };
}

pub fn setBoard(self: *Extended, piece: Piece, board: BitBoard) void {
    assert(piece != .none);
    self.map.setBoard(piece, board);
    self.updateExtra(piece);
}

pub fn setSquare(self: *Extended, piece: Piece, square: Square) void {
    assert(piece != .none);
    self.map.setSquare(piece, square);
    self.updateExtra(piece);
}

pub fn count(self: *const Extended, piece: Piece) IndexInt {
    assert(piece != .none);
    return self.map.count(piece);
}

pub fn get(self: *const Extended, piece: Piece) BitBoard {
    assert(piece != .none);
    return self.map.get(piece);
}

pub fn getMut(self: *Extended, piece: Piece) *BitBoard {
    assert(piece != .none);
    return self.map.getMut(piece);
}

pub fn getKind(self: *const Extended, piece_kind: Piece.Kind) BitBoard {
    assert(piece_kind != .none);
    return self.extra.kind[piece_kind.toU3()];
}

pub fn getColor(self: *const Extended, color: Color) BitBoard {
    return self.extra.color[color.toU1()];
}

pub fn getSide(self: *const Extended, side: Side) BitBoard {
    return switch (side) {
        .white, .black => self.extra.color[side.toU2()],
        .both => self.extra.all,
        .none => BitBoard.empty,
    };
}

pub fn getAll(self: *const Extended) BitBoard {
    return self.extra.all;
}

pub fn extra(self: *const Extended) Extra {
    return self.extra;
}

fn updateExtra(self: *Extended, piece: Piece) void {
    self.extra.update(&self.map, piece);
}

comptime {
    const tests = @import("tests.zig");
    _ = tests.TestImpl(Extended);
}

test "empty extras" {
    try testExtras(Extended.empty);
}

test "starting extras" {
    try testExtras(Extended.starting);
}

fn testExtras(ext: Extended) !void {
    const expected = ext.map.extra();
    const actual = ext.extra;
    for (0..2) |i| {
        try testing.expectEqual(expected.color[i], actual.color[i]);
    }
    for (0..Piece.Kind.hard_count) |i| {
        try testing.expectEqual(expected.kind[i], actual.kind[i]);
    }
    try testing.expectEqual(expected.all, actual.all);
}
