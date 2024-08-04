// Adapted from ``std.bit_set.IntegerBitSet``

//! A bit representation of a chess board.

const std = @import("std");
const testing = std.testing;
const assert = std.debug.assert;
const IteratorOptions = std.bit_set.IteratorOptions;

const BitBoard = @This();

/// The integer type used to represent a board
pub const MaskInt = u64;

/// The integer type used to shift a mask
pub const ShiftInt = std.math.Log2Int(MaskInt);

pub const bit_length: u8 = 64;

/// A range of squares within a board.
pub const Range = struct {
    /// The index of the first square of interest.
    start: u8,
    /// The index immediately after the last square of interest.
    end: u8,
};

mask: MaskInt,

/// Creates a board with no squares set.
pub fn initEmpty() BitBoard {
    return .{ .mask = 0 };
}

/// Creates a board with all squares set.
pub fn initFull() BitBoard {
    return .{ .mask = ~@as(MaskInt, 0) };
}

/// Returns true if the square at this index is set.
pub fn isSet(self: BitBoard, index: u8) bool {
    assert(index < bit_length);
    return (self.mask & maskBit(index)) != 0;
}

/// Returns the total number of set squares on this board
pub fn count(self: BitBoard) usize {
    return @popCount(self.mask);
}

/// Changes the value of the specified square to match the passed boolean.
pub fn setValue(self: *BitBoard, index: u8, value: bool) void {
    assert(index < bit_length);
    const bit = maskBit(index);
    const new_bit = bit & std.math.boolMask(MaskInt, value);
    self.mask = (self.mask & ~bit) | new_bit;
}

/// Sets the specified square
pub fn set(self: *BitBoard, index: u8) void {
    assert(index < bit_length);
    self.mask |= maskBit(index);
}

/// Changes the value of all squares in the specified range to
/// match the passed boolean.
pub fn setRangeValue(self: *BitBoard, range: Range, value: bool) void {
    assert(range.end <= bit_length);
    assert(range.start <= range.end);
    if (range.start == range.end) return;

    var range_mask = createRangeMask(range, true);
    self.mask &= ~range_mask;
    range_mask = createRangeMask(range, value);
    self.mask |= range_mask;
}

/// Unsets a specific square on this board
pub fn unset(self: *BitBoard, index: u8) void {
    assert(index < bit_length);
    self.mask &= ~maskBit(index);
}

/// Flips a specific square on this board
pub fn toggle(self: *BitBoard, index: u8) void {
    assert(index < bit_length);
    self.mask ^= maskBit(index);
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

/// Finds the index of the first set square.
/// If no squares are set, returns null.
pub fn findFirstSet(self: BitBoard) ?u8 {
    const mask = self.mask;
    if (mask == 0) return null;
    return @ctz(mask);
}

/// Finds the index of the first set square, and unsets it.
/// If no squares are set, returns null.
pub fn popBit(self: *BitBoard) ?u8 {
    const mask = self.mask;
    if (mask == 0) return null;
    const index = @ctz(mask);
    self.mask = mask & (mask - 1);
    return index;
}

/// Returns true if every corresponding square in both
/// boards are the same.
pub fn eql(self: BitBoard, other: BitBoard) bool {
    return bit_length == 0 or self.mask == other.mask;
}

/// Returns true if the first board is the subset
/// of the second one.
pub fn isSubsetOf(self: BitBoard, other: BitBoard) bool {
    return self.intersectWith(other).eql(self);
}

/// Returns true if the first board is the superset
/// of the second one.
pub fn isSupersetOf(self: BitBoard, other: BitBoard) bool {
    return other.subsetOf(self);
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
    var rank: u8 = 8;
    var file: u8 = undefined;
    while (rank > 0) {
        rank -= 1;
        file = 0;
        while (file < 8) : (file += 1) {
            if (self.isSet(rank * 8 + file)) {
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

        pub fn next(self: *IterSelf) ?usize {
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

fn createRangeMask(range: Range, value: bool) MaskInt {
    const start_bit = @as(ShiftInt, @intCast(range.start));
    var mask = std.math.boolMask(MaskInt, value) << start_bit;
    if (range.end != bit_length) {
        const end_bit = @as(ShiftInt, @intCast(range.end));
        mask &= std.math.boolMask(MaskInt, value) >> @as(ShiftInt, @truncate(@as(usize, @bitSizeOf(MaskInt)) - @as(usize, end_bit)));
    }
    return mask;
}

fn maskBit(index: usize) MaskInt {
    return @as(MaskInt, 1) << @as(ShiftInt, @intCast(index));
}

fn boolMaskBit(index: usize, value: bool) MaskInt {
    return @as(MaskInt, @intFromBool(value)) << @as(ShiftInt, @intCast(index));
}
