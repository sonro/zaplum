const Self = @This();

const std = @import("std");
const testing = std.testing;
const assert = std.debug.assert;

const chess = @import("../../chess.zig");
const Piece = chess.Piece;
const Square = chess.Square;
const IndexInt = chess.IndexInt;
const Range = chess.Range;

map: Map,

pub const empty = Self{ .map = [_]Square{.none} ** capacity };
pub const starting = initStarting();

const capacity = 2 *
    (Piece.max_knights +
    Piece.max_bishops +
    Piece.max_pawns +
    Piece.max_rooks +
    Piece.max_queens +
    Piece.max_kings);

/// Maps from `[piece][index]` to `[square]`
const index_lut: IndexMap = initIndexLut();
/// A piece cannot be on the board
const index_sentinel = std.math.maxInt(IndexInt);

const Map = [capacity]Square;
const IndexMap = [Piece.hard_count][Piece.max_single]IndexInt;

pub fn set(self: *Self, piece: Piece, index: IndexInt, square: Square) void {
    const i = getIndex(piece, index);
    self.map[i] = square;
}

pub fn get(self: *const Self, piece: Piece, index: IndexInt) Square {
    const i = getIndex(piece, index);
    return self.map[i];
}

pub fn slice(self: *const Self, piece: Piece) []const Square {
    const range = pieceRange(piece);
    return self.map[range.start..range.end];
}

pub fn sliceMut(self: *Self, piece: Piece) []Square {
    const range = pieceRange(piece);
    return self.map[range.start..range.end];
}

fn setMultiple(self: *Self, piece: Piece, squares: []const Square) void {
    for (squares, 0..) |square, i| {
        self.set(piece, @intCast(i), square);
    }
}

fn getIndex(piece: Piece, index: IndexInt) IndexInt {
    assert(piece != .none);
    const i = getIndexAssumeValid(piece, index);
    assert(i != index_sentinel); // piece cannot be on board
    return i;
}

fn getIndexAssumeValid(piece: Piece, index: IndexInt) IndexInt {
    return index_lut[piece.toU4()][index];
}

fn pieceRange(piece: Piece) Range {
    const start = getIndex(piece, 0);
    const end = start + piece.maxAllowed();
    return Range{ .start = start, .end = end };
}

fn initIndexLut() IndexMap {
    assert(Piece.max_single == 10);
    var lut: IndexMap = undefined;
    var index: IndexInt = 0;

    appendToIndexLut(&lut, &index, Piece.white_pawn, 0, 8);
    appendIndexMaxToRange(&lut, Piece.white_pawn, 8, 10);

    appendToIndexLut(&lut, &index, Piece.white_knight, 0, 10);
    appendToIndexLut(&lut, &index, Piece.white_bishop, 0, 10);
    appendToIndexLut(&lut, &index, Piece.white_rook, 0, 10);

    appendToIndexLut(&lut, &index, Piece.white_queen, 0, 9);
    appendIndexMaxToRange(&lut, Piece.white_queen, 9, 10);

    appendToIndexLut(&lut, &index, Piece.white_king, 0, 1);
    appendIndexMaxToRange(&lut, Piece.white_king, 1, 10);

    appendToIndexLut(&lut, &index, Piece.black_pawn, 0, 8);
    appendIndexMaxToRange(&lut, Piece.black_pawn, 8, 10);

    appendToIndexLut(&lut, &index, Piece.black_knight, 0, 10);
    appendToIndexLut(&lut, &index, Piece.black_bishop, 0, 10);
    appendToIndexLut(&lut, &index, Piece.black_rook, 0, 10);

    appendToIndexLut(&lut, &index, Piece.black_queen, 0, 9);
    appendIndexMaxToRange(&lut, Piece.black_queen, 9, 10);

    appendToIndexLut(&lut, &index, Piece.black_king, 0, 1);
    appendIndexMaxToRange(&lut, Piece.black_king, 1, 10);

    assert(index == capacity);

    return lut;
}

fn appendToIndexLut(lut: *IndexMap, index: *IndexInt, piece: Piece, start: IndexInt, end: IndexInt) void {
    const pce = piece.toU4();
    for (start..end) |i| {
        lut[pce][i] = index.*;
        index.* += 1;
    }
}

fn appendIndexMaxToRange(lut: *IndexMap, piece: Piece, start: IndexInt, end: IndexInt) void {
    const pce = piece.toU4();
    for (start..end) |i| {
        lut[pce][i] = index_sentinel;
    }
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

test "index lut" {
    const expected = IndexMap{
        // pawns
        [Piece.max_single]IndexInt{ 0, 1, 2, 3, 4, 5, 6, 7, index_sentinel, index_sentinel },
        // knights
        [Piece.max_single]IndexInt{ 8, 9, 10, 11, 12, 13, 14, 15, 16, 17 },
        // bishops
        [Piece.max_single]IndexInt{ 18, 19, 20, 21, 22, 23, 24, 25, 26, 27 },
        // rooks
        [Piece.max_single]IndexInt{ 28, 29, 30, 31, 32, 33, 34, 35, 36, 37 },
        // quuens
        [Piece.max_single]IndexInt{ 38, 39, 40, 41, 42, 43, 44, 45, 46, index_sentinel },
        // kings
        [_]IndexInt{47} ++ [_]IndexInt{index_sentinel} ** 9,

        // pawns
        [Piece.max_single]IndexInt{ 48, 49, 50, 51, 52, 53, 54, 55, index_sentinel, index_sentinel },
        // knights
        [Piece.max_single]IndexInt{ 56, 57, 58, 59, 60, 61, 62, 63, 64, 65 },
        // bishops
        [Piece.max_single]IndexInt{ 66, 67, 68, 69, 70, 71, 72, 73, 74, 75 },
        // rooks
        [Piece.max_single]IndexInt{ 76, 77, 78, 79, 80, 81, 82, 83, 84, 85 },
        // quuens
        [Piece.max_single]IndexInt{ 86, 87, 88, 89, 90, 91, 92, 93, 94, index_sentinel },
        // kings
        [_]IndexInt{95} ++ [_]IndexInt{index_sentinel} ** 9,
    };

    try testing.expectEqual(expected, index_lut);
}

comptime {
    const tests = @import("tests.zig");
    _ = tests.TestImpl(Self);
}
