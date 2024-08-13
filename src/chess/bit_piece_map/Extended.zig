//! Extended `BitPieceMap` with `Extra` union data
//!
//! Same API as `BitPieceMap`, but keeps the `extra`
//! data in sync with any direct changes. This does not
//! apply to `getMut`, you will need to update the `Extra`
//! data manually with `updateExtra`.
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
const Piece = chess.Piece;
const Side = chess.Side;
const Square = chess.Square;

/// Underlying `BitPieceMap`
map: BitPieceMap,
/// Union data for `map`
extra: Extra,

pub const empty = Extended{
    .map = BitPieceMap.empty,
    .extra = Extra.init(&BitPieceMap.empty),
};

pub const starting = Extended{
    .map = BitPieceMap.starting,
    .extra = Extra.init(&BitPieceMap.starting),
};

/// `Extended` from a `BitPieceMap`
pub fn init(map: BitPieceMap) Extended {
    return Extended{
        .map = map,
        .extra = Extra.init(&map),
    };
}

/// Sets the `BitBoard` for a given `Piece`
/// Updates the `Extra` data
pub fn setBoard(self: *Extended, piece: Piece, board: BitBoard) void {
    assert(piece != .none);
    self.map.setBoard(piece, board);
    self.updateExtra(piece);
}

/// Sets an individual `Square` for a given `Piece`
/// Does not remove any existing `Square`
/// Updates the `Extra` data
pub fn setSquare(self: *Extended, piece: Piece, square: Square) void {
    assert(piece != .none);
    self.map.setSquare(piece, square);
    self.updateExtra(piece);
}

/// Number of set `Square`s for a given `Piece`
pub fn count(self: *const Extended, piece: Piece) IndexInt {
    assert(piece != .none);
    return self.map.count(piece);
}

/// `BitBoard` for a `Piece`
pub fn get(self: *const Extended, piece: Piece) BitBoard {
    assert(piece != .none);
    return self.map.get(piece);
}

/// Mutable reference to the `BitBoard` for a `Piece`
/// Any changes to the returned board will not be reflected
/// in the `Extra` union data. You will need to call
/// `updateExtra` to sync your changes.
pub fn getMut(self: *Extended, piece: Piece) *BitBoard {
    assert(piece != .none);
    return self.map.getMut(piece);
}

/// `BitBoard` union of all `Piece.Kind` on the board
pub fn getKind(self: *const Extended, piece_kind: Piece.Kind) BitBoard {
    assert(piece_kind != .none);
    return self.extra.kind[piece_kind.toU3()];
}

/// `BitBoard` union of all `Color` on the board
pub fn getColor(self: *const Extended, color: Color) BitBoard {
    return self.extra.color[color.toU1()];
}

/// `BitBoard` union of all `Side` on the board
///
/// `Side.none` returns an empty board
/// `Side.both` same as `getAll`
pub fn getSide(self: *const Extended, side: Side) BitBoard {
    return switch (side) {
        .white, .black => self.extra.color[side.toU2()],
        .both => self.extra.all,
        .none => BitBoard.empty,
    };
}

/// `BitBoard` union of all `Piece`s on the board
pub fn getAll(self: *const Extended) BitBoard {
    return self.extra.all;
}

/// `Extra` union data
pub fn extra(self: *const Extended) Extra {
    return self.extra;
}

/// Update the `Extra` union data for a `Piece`
/// Use to sync changes made to a `getMut` reference
pub fn updateExtra(self: *Extended, piece: Piece) void {
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
