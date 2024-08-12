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
    for (chess.starting.piece_squares, 0..) |squares, pce| {
        pm.setMultiple(@enumFromInt(pce), squares);
    }
    return pm;
}

comptime {
    const tests = @import("tests.zig");
    _ = tests.TestImpl(Self);
}
