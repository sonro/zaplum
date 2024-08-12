// Adapted from ``std.bit_set.IntegerBitSet``

//! A bit representation of a chess board
const BitBoard = @This();

const std = @import("std");
const testing = std.testing;
const assert = std.debug.assert;
const IteratorOptions = std.bit_set.IteratorOptions;

const zaplum = @import("../zaplum.zig");
const chess = @import("../chess.zig");
const Range = chess.Range;
const size = chess.board_size;
const IndexInt = chess.IndexInt;
const Square = chess.Square;

const MathImpl = @import("bit_board/MathImpl.zig");
const LookupImpl = @import("bit_board/LookupImpl.zig");

/// The underlying bit mask
mask: MaskInt,

/// The integer type used to represent a board
pub const MaskInt = u64;

/// The integer type used to shift a mask
pub const ShiftInt = std.math.Log2Int(MaskInt);

/// BitBoard with no squares set.
pub const empty = initEmpty();

/// BitBoard with all squares set.
pub const full = initFull();

/// Default kind of ``BitBoard`` implementation
pub const default_impl = Impl.math;

/// The kind of ``BitBoard`` implementation
pub const Impl = enum {
    /// Bitwise maths
    math,
    /// Lookup table
    lookup,
};

const impl = switch (zaplum.options.bit_board_impl) {
    .math => MathImpl,
    .lookup => LookupImpl,
};

pub fn from(mask: MaskInt) BitBoard {
    return .{ .mask = mask };
}

/// Returns true if this square is set
pub fn isSet(self: BitBoard, square: Square) bool {
    assert(square != .none);
    return (self.mask & impl.maskBit(square.toIndex())) != 0;
}

/// Returns the total number of set squares on this board
pub fn count(self: BitBoard) IndexInt {
    return @popCount(self.mask);
}

pub fn isEmpty(self: BitBoard) bool {
    return self.mask == 0;
}

/// Changes the value of the square to match the passed boolean.
pub fn setValue(self: *BitBoard, square: Square, value: bool) void {
    assert(square != .none);
    impl.setValue(&self.mask, square.toIndex(), value);
}

/// Sets the specified square
pub fn set(self: *BitBoard, square: Square) void {
    assert(square != .none);
    impl.set(&self.mask, square.toIndex());
}

/// Changes the value of all squares in the specified range to
/// match the passed boolean.
pub fn setRangeValue(self: *BitBoard, range: Range, value: bool) void {
    assert(range.end <= size);
    assert(range.start <= range.end);
    if (range.start == range.end) return;
    impl.setRangeValue(&self.mask, range, value);
}

/// Unsets a specific square on this board
pub fn unset(self: *BitBoard, square: Square) void {
    assert(square != .none);
    impl.unset(&self.mask, square.toIndex());
}

/// Sets all squares in the specified range
pub fn setRange(self: *BitBoard, range: Range) void {
    assert(range.end <= size);
    assert(range.start <= range.end);
    if (range.start == range.end) return;
    impl.setRange(&self.mask, range);
}

/// Unsets all squares in the specified range
pub fn unsetRange(self: *BitBoard, range: Range) void {
    assert(range.end <= size);
    assert(range.start <= range.end);
    if (range.start == range.end) return;
    impl.unsetRange(&self.mask, range);
}

/// Flips a specific square on this board
pub fn toggle(self: *BitBoard, square: Square) void {
    assert(square != .none);
    impl.toggle(&self.mask, square.toIndex());
}

/// Flips all squares on this board which are present in the toggles board
pub fn toggleSet(self: *BitBoard, toggles: BitBoard) void {
    self.mask ^= toggles.mask;
}

/// Flips every square on this board
pub fn toggleAll(self: *BitBoard) void {
    self.mask = ~self.mask;
}

/// Performs a union of two boards, and stores the
/// result in the first one.  Squares in the result are
/// set if the corresponding squares were set in either input.
pub fn setUnion(self: *BitBoard, other: BitBoard) void {
    self.mask |= other.mask;
}

/// Performs an intersection of two boards, and stores
/// the result in the first one. Squares in the result are
/// set if the corresponding squares were set in both inputs.
pub fn setIntersection(self: *BitBoard, other: BitBoard) void {
    self.mask &= other.mask;
}

/// Finds the first set square
/// If no squares are set, returns `.none`
pub fn findFirstSet(self: BitBoard) Square {
    const mask = self.mask;
    if (mask == 0) return .none;
    return Square.fromIndex(@ctz(mask));
}

/// Finds the first set square, and unsets it.
/// If no squares are set, returns `.none`.
pub fn popBit(self: *BitBoard) Square {
    const mask = self.mask;
    if (mask == 0) return .none;
    const index = @ctz(mask);
    self.mask = mask & (mask - 1);
    return Square.fromIndex(index);
}

/// Returns true if every corresponding square in both
/// boards are the same.
pub fn eql(self: BitBoard, other: BitBoard) bool {
    return size == 0 or self.mask == other.mask;
}

/// Returns true if the first board is the subset
/// of the second one.
pub fn isSubsetOf(self: BitBoard, other: BitBoard) bool {
    return self.intersectWith(other).eql(self);
}

/// Returns true if the first board is the superset
/// of the second one.
pub fn isSupersetOf(self: BitBoard, other: BitBoard) bool {
    return other.isSubsetOf(self);
}

/// Returns the complement boards. Squares in the result
/// are set if the corresponding squares were not set.
pub fn complement(self: BitBoard) BitBoard {
    var result = self;
    result.toggleAll();
    return result;
}

/// Returns the union of two boards. Squares in the
/// result are set if the corresponding squares were set
/// in either input.
pub fn unionWith(self: BitBoard, other: BitBoard) BitBoard {
    var result = self;
    result.setUnion(other);
    return result;
}

/// Returns the intersection of two boards. Squares in
/// the result are set if the corresponding squares were
/// set in both inputs.
pub fn intersectWith(self: BitBoard, other: BitBoard) BitBoard {
    var result = self;
    result.setIntersection(other);
    return result;
}

/// Returns the xor of two boards. Squares in the
/// result are set if the corresponding squares were
/// not the same in both inputs.
pub fn xorWith(self: BitBoard, other: BitBoard) BitBoard {
    var result = self;
    result.toggleSet(other);
    return result;
}

/// Returns the difference of two boards. Squares in
/// the result are set if set in the first but not
/// set in the second board.
pub fn differenceWith(self: BitBoard, other: BitBoard) BitBoard {
    var result = self;
    result.setIntersection(other.complement());
    return result;
}

pub fn format(self: BitBoard, _: []const u8, _: std.fmt.FormatOptions, writer: anytype) !void {
    // rank and file from a8 to h1
    var rank: IndexInt = 8;
    var file: IndexInt = undefined;
    while (rank > 0) {
        rank -= 1;
        file = 0;
        while (file < 8) : (file += 1) {
            if (self.isSet(Square.fromIndex(rank * 8 + file))) {
                try writer.writeAll(" X");
            } else {
                try writer.writeAll(" -");
            }
        }
        try writer.writeByte('\n');
    }
}

/// Iterates through the squares of the board, according to the options.
/// The default options (.{}) will iterate indices of set squares in
/// ascending order.  Modifications to the underlying board may
/// or may not be observed by the iterator.
pub fn iterator(self: *const BitBoard, comptime options: IteratorOptions) Iterator(options) {
    return .{
        .bits_remain = switch (options.kind) {
            .set => self.mask,
            .unset => ~self.mask,
        },
    };
}

pub fn Iterator(comptime options: IteratorOptions) type {
    return SingleWordIterator(options.direction);
}

fn SingleWordIterator(comptime direction: IteratorOptions.Direction) type {
    return struct {
        const IterSelf = @This();
        // all bits which have not yet been iterated over
        bits_remain: MaskInt,

        pub fn next(self: *IterSelf) ?IndexInt {
            if (self.bits_remain == 0) return null;

            switch (direction) {
                .forward => {
                    const next_index = @ctz(self.bits_remain);
                    self.bits_remain &= self.bits_remain - 1;
                    return next_index;
                },
                .reverse => {
                    const leading_zeroes = @clz(self.bits_remain);
                    const top_bit = (@bitSizeOf(MaskInt) - 1) - leading_zeroes;
                    self.bits_remain &= (@as(MaskInt, 1) << @as(ShiftInt, @intCast(top_bit))) - 1;
                    return top_bit;
                },
            }
        }
    };
}

fn initEmpty() BitBoard {
    return .{ .mask = 0 };
}

fn initFull() BitBoard {
    return .{ .mask = std.math.maxInt(MaskInt) };
}

test "empty" {
    const expected = BitBoard{ .mask = 0 };
    try testing.expectEqual(expected, empty);
    try testing.expectEqual(expected.mask, empty.mask);
}

test "full" {
    const expected = BitBoard{ .mask = std.math.maxInt(MaskInt) };
    try testing.expectEqual(expected, full);
    try testing.expectEqual(expected.mask, full.mask);
}

test "empty is empty" {
    try testing.expect(empty.isEmpty());
}

test "full is not empty" {
    try testing.expect(!full.isEmpty());
}

test "single val is not empty" {
    try testing.expect(!from(0b0010).isEmpty());
}

test "from" {
    const expected = BitBoard{ .mask = 0x0f0f };
    try testing.expectEqual(expected, from(0x0f0f));
}

test "is set" {
    const board = from(0b1001);
    try testing.expect(board.isSet(sqi(0)));
    try testing.expect(!board.isSet(sqi(1)));
    try testing.expect(!board.isSet(sqi(2)));
    try testing.expect(board.isSet(sqi(3)));
}

test "pop count empty" {
    try testing.expectEqual(@as(IndexInt, 0), empty.count());
}

test "pop count full" {
    try testing.expectEqual(@as(IndexInt, size), full.count());
}

test "pop count custom" {
    const board = from(0b11111111_00000001);
    try testing.expectEqual(@as(IndexInt, 9), board.count());
}

test "set value is set true" {
    var board = empty;
    board.setValue(sqi(0), true);
    try testing.expect(board.isSet(sqi(0)));
}

test "set value is set false" {
    var board = full;
    board.setValue(sqi(4), false);
    try testing.expect(!board.isSet(sqi(4)));
}

test "set is set empty" {
    var board = empty;
    board.set(sqi(12));
    try testing.expect(board.isSet(sqi(12)));
}

test "set is set full" {
    var board = full;
    board.set(sqi(14));
    try testing.expect(board.isSet(sqi(14)));
}

test "unset is not set full" {
    var board = full;
    board.unset(sqi(16));
    try testing.expect(!board.isSet(sqi(16)));
}

test "unset is not set empty" {
    var board = empty;
    board.unset(sqi(17));
    try testing.expect(!board.isSet(sqi(17)));
}

test "set range value are set true" {
    var board = empty;
    board.setRangeValue(.{ .start = 0, .end = 3 }, true);
    for (0..3) |i| {
        try testing.expect(board.isSet(sqi(i)));
    }
}

test "set range value are set false" {
    var board = full;
    board.setRangeValue(.{ .start = 0, .end = 3 }, false);
    for (0..3) |i| {
        try testing.expect(!board.isSet(sqi(i)));
    }
}

test "set range empty to full" {
    var board = empty;
    board.setRange(.{ .start = 0, .end = size });
    try testing.expectEqual(full, board);
}

test "set range full" {
    var board = full;
    board.setRange(.{ .start = 0, .end = size });
    try testing.expectEqual(full, board);
}

test "set range custom" {
    var board = from(0b1001);
    board.setRange(.{ .start = 1, .end = 3 });
    try testing.expectEqual(from(0b1111), board);
}

test "unset range empty" {
    var board = empty;
    board.unsetRange(.{ .start = 0, .end = 3 });
    for (0..3) |i| {
        try testing.expect(!board.isSet(sqi(i)));
    }
}

test "unset range full" {
    var board = full;
    board.unsetRange(.{ .start = 0, .end = 3 });
    for (0..3) |i| {
        try testing.expect(!board.isSet(sqi(i)));
    }
}

test "unset range full to empty" {
    var board = full;
    board.unsetRange(.{ .start = 0, .end = size });
    try testing.expectEqual(empty, board);
}

test "unset range custom" {
    var board = from(0b1111);
    board.unsetRange(.{ .start = 1, .end = 3 });
    try testing.expectEqual(from(0b1001), board);
}

test "toggle once" {
    var board = from(0b1010);
    board.toggle(sqi(0));
    try testing.expectEqual(from(0b1011), board);
}

test "toggle twice" {
    var board = from(0b1010);
    board.toggle(sqi(0));
    board.toggle(sqi(0));
    try testing.expectEqual(from(0b1010), board);
}

test "toggle all empty to full" {
    var board = empty;
    board.toggleAll();
    try testing.expectEqual(full, board);
}

test "toggle all full to empty" {
    var board = full;
    board.toggleAll();
    try testing.expectEqual(empty, board);
}

test "toggle all custom" {
    var board = from(0b1010);
    board.toggleAll();
    var expected = full;
    expected.mask ^= 0b1010;
    try testing.expectEqual(expected, board);
}

test "toggle set empty with full" {
    var board = empty;
    board.toggleSet(full);
    try testing.expectEqual(full, board);
}

test "toggle set full with full" {
    var board = full;
    board.toggleSet(full);
    try testing.expectEqual(empty, board);
}

test "toggle set full with empty" {
    var board = full;
    board.toggleSet(empty);
    try testing.expectEqual(full, board);
}

test "toggle set empty with custom" {
    var board = empty;
    board.toggleSet(from(0b1010));
    try testing.expectEqual(from(0b1010), board);
}

test "toggle set custom with custom" {
    var board = from(0b1010);
    board.toggleSet(from(0b0101));
    try testing.expectEqual(from(0b1111), board);
}

test "set union empty with empty" {
    var board = empty;
    board.setUnion(empty);
    try testing.expectEqual(empty, board);
}

test "set union full with full" {
    var board = full;
    board.setUnion(full);
    try testing.expectEqual(full, board);
}

test "set union empty with full" {
    var board = empty;
    board.setUnion(full);
    try testing.expectEqual(full, board);
}

test "set union custom with full" {
    var board = from(0b1010);
    board.setUnion(full);
    try testing.expectEqual(full, board);
}

test "set union custom with custom" {
    var board = from(0b1010);
    board.setUnion(from(0b0101));
    try testing.expectEqual(from(0b1111), board);
}

test "set intersection empty with empty" {
    var board = empty;
    board.setIntersection(empty);
    try testing.expectEqual(empty, board);
}

test "set intersection full with full" {
    var board = full;
    board.setIntersection(full);
    try testing.expectEqual(full, board);
}

test "set intersection empty with full" {
    var board = empty;
    board.setIntersection(full);
    try testing.expectEqual(empty, board);
}

test "set intersection custom with full" {
    var board = from(0b1010);
    board.setIntersection(full);
    try testing.expectEqual(from(0b1010), board);
}

test "set intersection custom with custom" {
    var board = from(0b1110);
    board.setIntersection(from(0b0101));
    try testing.expectEqual(from(0b0100), board);
}

test "find first set empty" {
    var board = empty;
    try testing.expectEqual(.none, board.findFirstSet());
}

test "find first set full" {
    var board = full;
    try testing.expectEqual(.a1, board.findFirstSet());
}

test "find first set custom" {
    var board = from(0b1010);
    try testing.expectEqual(sqi(1), board.findFirstSet());
}

test "pop bit empty" {
    var board = empty;
    try testing.expectEqual(.none, board.popBit());
}

test "pop bit full" {
    var board = full;
    try testing.expectEqual(sqi(0), board.popBit());
    try testing.expectEqual(sqi(1), board.popBit());
}

test "pop bit custom" {
    var board = from(0b1010);
    try testing.expectEqual(sqi(1), board.popBit());
    try testing.expectEqual(sqi(3), board.popBit());
    try testing.expectEqual(.none, board.popBit());
}

test "eql" {
    var board = from(0b1010);
    try testing.expect(board.eql(from(0b1010)));
    try testing.expect(!board.eql(from(0b0101)));
}

test "is subset of empty empty" {
    var board = empty;
    try testing.expect(board.isSubsetOf(empty));
}

test "is subset of empty full" {
    var board = empty;
    try testing.expect(board.isSubsetOf(full));
}

test "is subset of full empty" {
    var board = full;
    try testing.expect(!board.isSubsetOf(empty));
}

test "is subset of custom" {
    var board = from(0b1010);
    try testing.expect(board.isSubsetOf(from(0b11111010)));
    try testing.expect(!board.isSubsetOf(from(0b1000)));
}

test "is superset of empty empty" {
    var board = empty;
    try testing.expect(board.isSupersetOf(empty));
}

test "is superset of empty full" {
    var board = empty;
    try testing.expect(!board.isSupersetOf(full));
}

test "is superset of full empty" {
    var board = full;
    try testing.expect(board.isSupersetOf(empty));
}

test "is superset of custom" {
    var board = from(0b1010);
    try testing.expect(!board.isSupersetOf(from(0b1110)));
    try testing.expect(board.isSupersetOf(from(0b1000)));
}

test "complement empty" {
    const board = empty;
    const actual = board.complement();
    try testing.expectEqual(full, actual);
}

test "complement full" {
    const board = full;
    const actual = board.complement();
    try testing.expectEqual(empty, actual);
}

test "complement custom" {
    const board = from(0b1010);
    const expected = from(~board.mask);
    const actual = board.complement();
    try testing.expectEqual(expected, actual);
}

test "union empty with empty" {
    const board = empty;
    const actual = board.unionWith(empty);
    try testing.expectEqual(empty, actual);
}

test "union empty with full" {
    const board = empty;
    const actual = board.unionWith(full);
    try testing.expectEqual(full, actual);
}

test "union full with full" {
    const board = full;
    const actual = board.unionWith(full);
    try testing.expectEqual(full, actual);
}

test "union custom with custom" {
    const board = from(0b1010);
    const actual = board.unionWith(from(0b0101));
    try testing.expectEqual(from(0b1111), actual);
}

test "intersect empty with empty" {
    const board = empty;
    const actual = board.intersectWith(empty);
    try testing.expectEqual(empty, actual);
}

test "intersect empty with full" {
    const board = empty;
    const actual = board.intersectWith(full);
    try testing.expectEqual(empty, actual);
}

test "intersect full with full" {
    const board = full;
    const actual = board.intersectWith(full);
    try testing.expectEqual(full, actual);
}

test "intersect custom to 0" {
    const board = from(0b1010);
    const actual = board.intersectWith(from(0b0101));
    try testing.expectEqual(from(0b0000), actual);
}

test "intersect custom to 1" {
    const board = from(0b0001);
    const actual = board.intersectWith(from(0b1111));
    try testing.expectEqual(from(0b0001), actual);
}

test "xor empty with empty" {
    const board = empty;
    const actual = board.xorWith(empty);
    try testing.expectEqual(empty, actual);
}

test "xor empty with full" {
    const board = empty;
    const actual = board.xorWith(full);
    try testing.expectEqual(full, actual);
}

test "xor full with full" {
    const board = full;
    const actual = board.xorWith(full);
    try testing.expectEqual(empty, actual);
}

test "xor custom with custom" {
    const board = from(0b1010);
    const actual = board.xorWith(from(0b1101));
    try testing.expectEqual(from(0b0111), actual);
}

test "difference with empty" {
    const board = from(0b1010);
    const actual = board.differenceWith(empty);
    try testing.expectEqual(from(0b1010), actual);
}

test "difference with full" {
    const board = from(0b1010);
    const actual = board.differenceWith(full);
    try testing.expectEqual(from(0b0000), actual);
}

test "difference with custom" {
    const board = from(0b1010);
    const actual = board.differenceWith(from(0b0111));
    try testing.expectEqual(from(0b1000), actual);
}

test "iterate empty" {
    const board = empty;
    var iter = board.iterator(.{});
    var x: usize = 0;
    while (iter.next()) |_| : (x += 1) {}
    try testing.expectEqual(0, x);
}

test "iterate full" {
    const board = full;
    var iter = board.iterator(.{});
    var x: usize = 0;
    while (iter.next()) |_| : (x += 1) {}
    try testing.expectEqual(size, x);
}

test "iterate custom" {
    const board = from(0b1010);
    var iter = board.iterator(.{});
    try testing.expectEqual(1, iter.next());
    try testing.expectEqual(3, iter.next());
    try testing.expectEqual(null, iter.next());
}

test "iterate custom reverse" {
    const board = from(0b1010);
    var iter = board.iterator(.{ .direction = .reverse });
    try testing.expectEqual(3, iter.next());
    try testing.expectEqual(1, iter.next());
    try testing.expectEqual(null, iter.next());
}

test "iterate custom unset" {
    const board = from(0b1010);
    var iter = board.iterator(.{ .kind = .unset });
    try testing.expectEqual(0, iter.next());
    try testing.expectEqual(2, iter.next());
    try testing.expectEqual(4, iter.next());
    try testing.expectEqual(5, iter.next());
}

fn sqi(index: usize) Square {
    return @enumFromInt(index);
}
