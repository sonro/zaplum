const Self = @This();

const std = @import("std");
const testing = std.testing;
const assert = std.debug.assert;

const chess = @import("../../chess.zig");
const Piece = chess.Piece;
const Square = chess.Square;
const IndexInt = chess.IndexInt;

map: Map,

pub const empty = initEmpty();
pub const starting = initStarting();

const piece_cap = Piece.hard_count;
const square_cap = Piece.max_single;

const Map = [piece_cap][square_cap]Square;

pub fn set(self: *Self, piece: Piece, index: IndexInt, square: Square) void {
    assertPieceIndex(piece, index);
    self.map[piece.toU4()][index] = square;
}

pub fn get(self: *const Self, piece: Piece, index: IndexInt) Square {
    assertPieceIndex(piece, index);
    return self.map[piece.toU4()][index];
}

pub fn slice(self: *const Self, piece: Piece) []const Square {
    return self.map[piece.toU4()][0..piece.maxAllowed()];
}

pub fn sliceMut(self: *Self, piece: Piece) []Square {
    return self.map[piece.toU4()][0..piece.maxAllowed()];
}

fn setMultiple(self: *Self, piece: Piece, squares: []const Square) void {
    for (squares, 0..) |square, i| {
        self.set(piece, @intCast(i), square);
    }
}

fn assertPieceIndex(piece: Piece, index: IndexInt) void {
    assert(piece != .none);
    assert(index < piece.maxAllowed());
}

fn initEmpty() Self {
    var map: Map = undefined;
    for (0..piece_cap) |pce| {
        map[pce] = [_]Square{.none} ** square_cap;
    }
    return .{ .map = map };
}

fn initStarting() Self {
    var pm = empty;
    pm.setMultiple(.white_pawn, &.{ .a2, .b2, .c2, .d2, .e2, .f2, .g2, .h2 });
    pm.setMultiple(.white_knight, &.{ .b1, .g1 });
    pm.setMultiple(.white_bishop, &.{ .c1, .f1 });
    pm.setMultiple(.white_rook, &.{ .a1, .h1 });
    pm.setMultiple(.white_queen, &.{.d1});
    pm.setMultiple(.white_king, &.{.e1});
    pm.setMultiple(.black_pawn, &.{ .a7, .b7, .c7, .d7, .e7, .f7, .g7, .h7 });
    pm.setMultiple(.black_knight, &.{ .b8, .g8 });
    pm.setMultiple(.black_bishop, &.{ .c8, .f8 });
    pm.setMultiple(.black_rook, &.{ .a8, .h8 });
    pm.setMultiple(.black_queen, &.{.d8});
    pm.setMultiple(.black_king, &.{.e8});

    return pm;
}

comptime {
    const tests = @import("tests.zig");
    _ = tests.TestImpl(Self);
}
