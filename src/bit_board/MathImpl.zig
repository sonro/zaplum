const std = @import("std");
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

pub fn unset(mask: *MaskInt, index: u8) void {
    mask.* &= ~maskBit(index);
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
