const std = @import("std");
const testing = std.testing;
const bit_board = @import("../bit_board.zig");
const MaskInt = bit_board.MaskInt;
const ShiftInt = bit_board.ShiftInt;
const Range = bit_board.Range;
const size = bit_board.size;
const IndexInt = bit_board.IndexInt;

const MathImpl = @This();

pub fn setValue(mask: *MaskInt, index: IndexInt, value: bool) void {
    const bit = maskBit(index);
    const new_bit = bit & std.math.boolMask(MaskInt, value);
    mask.* = (mask.* & ~bit) | new_bit;
}

pub fn setRangeValue(mask: *MaskInt, range: Range, value: bool) void {
    var range_mask = createRangeMask(range, true);
    mask.* &= ~range_mask;
    range_mask = createRangeMask(range, value);
    mask.* |= range_mask;
}

pub fn set(mask: *MaskInt, index: IndexInt) void {
    mask.* |= maskBit(index);
}

pub fn setRange(mask: *MaskInt, range: Range) void {
    mask.* |= createRangeMask(range, true);
}

pub fn unset(mask: *MaskInt, index: IndexInt) void {
    mask.* &= ~maskBit(index);
}

pub fn unsetRange(mask: *MaskInt, range: Range) void {
    mask.* &= ~createRangeMask(range, true);
}

pub fn toggle(mask: *MaskInt, index: IndexInt) void {
    mask.* ^= maskBit(index);
}

pub fn maskBit(index: IndexInt) MaskInt {
    return @as(MaskInt, 1) << @as(ShiftInt, @intCast(index));
}

fn createRangeMask(range: Range, value: bool) MaskInt {
    const start_bit = @as(ShiftInt, @intCast(range.start));
    var mask = std.math.boolMask(MaskInt, value) << start_bit;
    if (range.end != size) {
        const end_bit = @as(ShiftInt, @intCast(range.end));
        const shift = @as(ShiftInt, @truncate(size - @as(IndexInt, end_bit)));
        mask &= std.math.boolMask(MaskInt, value) >> shift;
    }
    return mask;
}

comptime {
    const tests = @import("tests.zig");
    _ = tests.testImpl(@This());
}
