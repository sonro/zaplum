//! List of `Square`s occupied by `Piece`s
//!
//! Includes individual and total counts.
//!
//! Uses fewer than 64 bytes of memory.
//!
//! Supports removal and promotion, although doing so will invalidate
//! existing indicies and therefore iterators.
const PieceList = @This();

const std = @import("std");
const testing = std.testing;
const assert = std.debug.assert;
const builtin = @import("builtin");

const chess = @import("../chess.zig");
const Piece = chess.Piece;
const Square = chess.Square;
const Range = chess.Range;
const IndexInt = chess.IndexInt;
const Color = chess.Color;

/// Backing array
data: [capacity]Square,
/// `data` start index for each piece
indicies: Indicies,
/// Number of each piece
lens: Lens,
/// Total number of pieces
total: IndexInt,

/// Size of the backing array
pub const capacity: IndexInt = Piece.max_board;

pub const empty = PieceList{
    .data = [_]Square{.none} ** capacity,
    .indicies = initPieceIndices(),
    .lens = [_]u4{0} ** Piece.hard_count,
    .total = 0,
};

pub const starting = initStarting();

const indicies_len = Piece.count;
const lens_len = Piece.hard_count;

/// In debug mode, assert no two pieces occupy the same square
/// and the total number of pieces is correct.
pub fn assertValid(self: *const PieceList) void {
    if (builtin.mode != .Debug) return;
    var seen: [chess.board_size]bool = .{false} ** chess.board_size;
    var total: usize = 0;
    for (Piece.hard_values) |piece| {
        const sli = self.slice(piece);
        total += sli.len;
        for (sli) |square| {
            if (seen[@intFromEnum(square)]) {
                std.debug.panic("More than one piece on square {}", .{square});
            }
            seen[@intFromEnum(square)] = true;
        }
    }
    assert(total == self.total);
}

/// Slice of `Square` occupied by a `Piece`
pub fn slice(self: *const PieceList, piece: Piece) []const Square {
    assert(piece != .none);
    const pce = piece.toU4();
    const start = self.indicies[pce];
    const end = start + self.lens[pce];
    return self.data[start..end];
}

/// The number of `Piece` on the board
pub fn count(self: *const PieceList, piece: Piece) IndexInt {
    assert(piece != .none);
    return self.lens[piece.toU4()];
}

/// Get the square occupied by `piece` at `index`
pub fn get(self: *const PieceList, piece: Piece, index: IndexInt) Square {
    const i = self.indicies[piece.toU4()] + index;
    assert(i < capacity);
    return self.data[i];
}

/// Adds a new piece to the list. Useful when loading a board.
/// Use `set` to change an existing piece.
pub fn append(self: *PieceList, piece: Piece, square: Square) void {
    assert(piece != .none);
    const pce = piece.toU4();
    const i = self.indicies[pce] + self.lens[pce];
    assert(i < capacity); // over capacity for all pieces
    assert(i < self.indicies[pce + 1]); // over capacity for this piece
    self.appendAssumeValid(pce, square);
}

/// Change the square occupied by `piece` at `index`.
/// Asserts that the piece is already on the board.
/// If removing a piece, use `remove`.
pub fn set(self: *PieceList, piece: Piece, index: IndexInt, square: Square) void {
    assert(piece != .none);
    const pce = piece.toU4();
    const i = self.indicies[pce] + index;
    assert(i < capacity); // over capacity for all pieces
    assert(index < self.lens[pce]); // this piece has not yet been appended
    self.data[i] = square;
}

/// Remove the piece at `index`.
/// Asserts that the piece is already on the board.
/// Will invalidate existing indicies for this `Piece`.
pub fn remove(self: *PieceList, piece: Piece, index: IndexInt) void {
    assert(piece != .none);
    const pce = piece.toU4();
    const target = self.indicies[pce] + index;
    assert(target < capacity); // over capacity for all pieces
    assert(index < self.lens[pce]); // this piece has not yet been appended
    self.removeAssumeValid(pce, target);
}

/// Promote the `piece` at `index` to `to` on `square`.
/// Asserts that the piece is already on the board.
/// Asserts that `to` is a valid promotion.
/// Will invalidate existing indicies for this `Piece`.
/// May invalidate all indicies for this `piece`'s `Color`.
pub fn promote(self: *PieceList, piece: Piece, index: IndexInt, square: Square, to: Piece.Kind) void {
    assert(piece.kind() == .pawn); // only pawns can promote
    assert(to != .none and to != .pawn and to != .king); // cannot promote to this
    self.remove(piece, index);
    self.promoteAssumeValid(piece, square, to);
}

pub fn format(self: PieceList, comptime _: []const u8, _: std.fmt.FormatOptions, writer: anytype) !void {
    for (Piece.hard_values) |piece| {
        const sli = self.slice(piece);
        try writer.print("{}: {s}\n", .{ piece, sli });
    }
}

fn appendMultiple(self: *PieceList, piece: Piece, squares: []const Square) void {
    for (squares) |square| {
        self.append(piece, square);
    }
}

fn promoteAssumeValid(self: *PieceList, piece: Piece, square: Square, to: Piece.Kind) void {
    const color = Color.fromSide(piece.side()) catch unreachable;
    const new = Piece.fromColorKind(color, to);
    const start = self.indicies[piece.toU4() + 1] - 1;
    const end = self.indicies[new.toU4() + 1] - 1;
    self.shiftRemove(start, end);
    self.appendAssumeValid(new.toU4(), square);
}

fn appendAssumeValid(self: *PieceList, pce: u4, square: Square) void {
    const i = self.indicies[pce] + self.lens[pce];
    self.data[i] = square;
    self.lens[pce] += 1;
    self.total += 1;
}

fn removeAssumeValid(self: *PieceList, pce: u4, target: IndexInt) void {
    const piece_start = self.indicies[pce];
    self.lens[pce] -= 1;
    const last = piece_start + self.lens[pce];
    self.shiftRemove(target, last);
    self.data[last] = .none;
    self.total -= 1;
}

fn promoteIndicies(self: *PieceList, old: Piece, new: Piece) void {
    var caps = PieceCaps.fromIndicies(self.indicies);
    caps.promote(old, new);
    self.indicies = caps.toIndicies();
}

fn shiftRemove(self: *PieceList, from: IndexInt, to: IndexInt) void {
    for (from..to) |i| {
        self.data[i] = self.data[i + 1];
    }
}

const Indicies = [indicies_len]IndexInt;

const Lens = [lens_len]u4;

const PieceCaps = struct {
    caps: [Piece.hard_count]IndexInt,

    pub const init = initPieceCaps();

    pub fn fromIndicies(indices: Indicies) PieceCaps {
        var caps: PieceCaps = .{ .caps = undefined };
        for (0..Piece.hard_count) |i| {
            const cap = indices[i + 1] - indices[i];
            caps.caps[i] = cap;
        }
        return caps;
    }

    pub fn promote(self: *PieceCaps, from: Piece, to: Piece) void {
        self.caps[from.toU4()] -= 1;
        self.caps[to.toU4()] += 1;
    }

    pub fn toIndicies(self: PieceCaps) Indicies {
        var indices: Indicies = undefined;
        var index: IndexInt = 0;
        for (0..Piece.hard_count) |i| {
            indices[i] = index;
            index += self.caps[i];
        }
        assert(index == capacity);
        indices[Piece.hard_count] = capacity;
        return indices;
    }
};

fn initStarting() PieceList {
    var self = empty;
    for (chess.starting.piece_squares, 0..) |squares, pce| {
        self.appendMultiple(Piece.fromU4(pce), squares);
    }
    return self;
}

fn initPieceCaps() PieceCaps {
    var caps: [Piece.hard_count]IndexInt = undefined;
    caps[Piece.white_pawn.toU4()] = 8;
    caps[Piece.black_pawn.toU4()] = 8;
    caps[Piece.white_knight.toU4()] = 2;
    caps[Piece.black_knight.toU4()] = 2;
    caps[Piece.white_bishop.toU4()] = 2;
    caps[Piece.black_bishop.toU4()] = 2;
    caps[Piece.white_rook.toU4()] = 2;
    caps[Piece.black_rook.toU4()] = 2;
    caps[Piece.white_queen.toU4()] = 1;
    caps[Piece.black_queen.toU4()] = 1;
    caps[Piece.white_king.toU4()] = 1;
    caps[Piece.black_king.toU4()] = 1;
    return PieceCaps{ .caps = caps };
}

fn initPieceIndices() Indicies {
    return PieceCaps.init.toIndicies();
}

test "empty" {
    for (0..Piece.hard_count) |i| {
        try testing.expectEqual(.none, empty.get(@enumFromInt(i), 0));
    }
}

test "starting" {
    for (chess.starting.piece_squares, 0..) |squares, pce| {
        try testPiece(starting, @enumFromInt(pce), squares);
    }
}

test "append" {
    var list = PieceList.empty;
    list.append(.white_pawn, .a2);
    try testPiece(list, .white_pawn, &.{.a2});
}

test "set" {
    var list = PieceList.empty;
    list.append(.white_pawn, .a2);
    list.set(.white_pawn, list.count(.white_pawn) - 1, .a4);
    try testPiece(list, .white_pawn, &.{.a4});
}

test "remove" {
    var list = PieceList.empty;
    list.append(.white_pawn, .a2);
    list.remove(.white_pawn, list.count(.white_pawn) - 1);
    try testPiece(list, .white_pawn, &.{});
}

test "remove from starting" {
    var list = starting;
    list.remove(.black_rook, 1);
    try testing.expectEqual(1, list.count(.black_rook));
    try testPiece(list, .black_rook, &.{.a8});
}

test "promote empty to queen" {
    var list = PieceList.empty;
    list.append(.white_pawn, .a7);
    list.promote(.white_pawn, 0, .a8, .queen);
    try testPiece(list, .white_pawn, &.{});
    try testPiece(list, .white_queen, &.{.a8});
}

test "promote empty 2 queens" {
    var list = PieceList.empty;
    list.append(.white_pawn, .a7);
    list.append(.white_pawn, .b7);
    list.promote(.white_pawn, 0, .a8, .queen);
    list.promote(.white_pawn, 0, .b8, .queen);
    try testPiece(list, .white_queen, &.{ .a8, .b8 });
}

test "promote empty to knight" {
    var list = PieceList.empty;
    list.append(.white_pawn, .a7);
    list.promote(.white_pawn, 0, .a8, .knight);
    try testPiece(list, .white_pawn, &.{});
    try testPiece(list, .white_knight, &.{.a8});
}

test "promote empty to bishop" {
    var list = PieceList.empty;
    list.append(.white_pawn, .a7);
    list.promote(.white_pawn, 0, .a8, .bishop);
    try testPiece(list, .white_pawn, &.{});
    try testPiece(list, .white_bishop, &.{.a8});
}

test "promote empty to rook" {
    var list = PieceList.empty;
    list.append(.white_pawn, .a7);
    list.promote(.white_pawn, 0, .a8, .rook);
    try testPiece(list, .white_pawn, &.{});
    try testPiece(list, .white_rook, &.{.a8});
}

test "promote starting to queen" {
    var list = starting;
    list.remove(.black_rook, 0);
    try testing.expectEqual(1, list.count(.black_rook));
    try testPiece(list, .black_rook, &.{.h8});
    list.promote(.white_pawn, 0, .a8, .queen);
    try testPiece(list, .white_pawn, &.{ .b2, .c2, .d2, .e2, .f2, .g2, .h2 });
    try testPiece(list, .white_queen, &.{ .d1, .a8 });
}

test "slice copy by reference" {
    const list = starting;
    for (Piece.hard_values) |piece| {
        const sliced = list.slice(piece);
        const pce = piece.toU4();
        const start = list.indicies[pce];
        const end = start + list.lens[pce];
        try testing.expectEqualSlices(Square, list.data[start..end], sliced);
    }
}

fn testPiece(self: PieceList, piece: Piece, expected: []const Square) !void {
    try testing.expectEqualSlices(Square, expected, self.slice(piece));
    try testing.expectEqual(expected.len, self.count(piece));
    for (expected, 0..) |square, i| {
        try testing.expectEqual(square, self.get(piece, @intCast(i)));
    }
}
