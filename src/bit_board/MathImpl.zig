const std = @import("std");
const testing = std.testing;
const bit_board = @import("../bit_board.zig");
const MaskInt = bit_board.MaskInt;
const ShiftInt = bit_board.ShiftInt;
const Range = bit_board.Range;
const size = bit_board.size;

pub fn setValue(mask: *MaskInt, index: u8, value: bool) void {
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

pub fn set(mask: *MaskInt, index: u8) void {
    mask.* |= maskBit(index);
}

pub fn setRange(mask: *MaskInt, range: Range) void {
    mask.* |= createRangeMask(range, true);
}

pub fn unset(mask: *MaskInt, index: u8) void {
    mask.* &= ~maskBit(index);
}

pub fn unsetRange(mask: *MaskInt, range: Range) void {
    mask.* &= ~createRangeMask(range, true);
}

pub fn toggle(mask: *MaskInt, index: u8) void {
    mask.* ^= maskBit(index);
}

pub fn maskBit(index: u8) MaskInt {
    return @as(MaskInt, 1) << @as(ShiftInt, @intCast(index));
}

fn createRangeMask(range: Range, value: bool) MaskInt {
    const start_bit = @as(ShiftInt, @intCast(range.start));
    var mask = std.math.boolMask(MaskInt, value) << start_bit;
    if (range.end != size) {
        const end_bit = @as(ShiftInt, @intCast(range.end));
        const shift = @as(ShiftInt, @truncate(size - @as(u8, end_bit)));
        mask &= std.math.boolMask(MaskInt, value) >> shift;
    }
    return mask;
}

const full_mask: MaskInt = ~@as(MaskInt, 0);
const empty_mask: MaskInt = 0;

test "set value lowest true empty mask" {
    try test_set_value_empty_mask(0, true, 1);
}

test "set value lowest true full mask" {
    try test_set_value_full_mask(0, true, full_mask);
}

test "set value lowest false empty mask" {
    try test_set_value_empty_mask(0, false, 0);
}

test "set value lowest false full mask" {
    const expected = full_mask << 1;
    try test_set_value_full_mask(0, false, expected);
}

test "set value highest true empty mask" {
    const index = size - 1;
    const expected = @as(MaskInt, 1) << index;
    try test_set_value_empty_mask(index, true, expected);
}

fn test_set_value_empty_mask(index: u8, value: bool, expected: MaskInt) !void {
    var mask = empty_mask;
    setValue(&mask, index, value);
    try testing.expectEqual(expected, mask);
}

fn test_set_value_full_mask(index: u8, value: bool, expected: MaskInt) !void {
    var mask = full_mask;
    setValue(&mask, index, value);
    try testing.expectEqual(expected, mask);
}
