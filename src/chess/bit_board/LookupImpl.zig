const std = @import("std");
const BitBoard = @import("../BitBoard.zig");
const chess = @import("../../chess.zig");
const MaskInt = BitBoard.MaskInt;
const ShiftInt = BitBoard.ShiftInt;
const Range = chess.Range;
const size = chess.board_size;
const IndexInt = chess.IndexInt;

const MathImpl = @import("MathImpl.zig");

const lut: [2][size]MaskInt = initLut();

pub fn setValue(mask: *MaskInt, index: IndexInt, value: bool) void {
    const bit = maskBit(index);
    const new_bit = bit & valueBit(index, value);
    mask.* = (mask.* & ~bit) | new_bit;
}

pub fn setRangeValue(mask: *MaskInt, range: Range, value: bool) void {
    MathImpl.setRangeValue(mask, range, value);
}

pub fn set(mask: *MaskInt, index: IndexInt) void {
    mask.* |= maskBit(index);
}

pub fn setRange(mask: *MaskInt, range: Range) void {
    const range_mask = MathImpl.createRangeMask(range, true);
    mask.* |= range_mask;
}

pub fn unset(mask: *MaskInt, index: IndexInt) void {
    mask.* &= lut[0][index];
}

pub fn unsetRange(mask: *MaskInt, range: Range) void {
    // const range_mask = MathImpl.createRangeMask(range, false);
    // mask.* &= range_mask;
    MathImpl.setRangeValue(mask, range, false);
}

pub fn toggle(mask: *MaskInt, index: IndexInt) void {
    mask.* ^= maskBit(index);
}

pub fn maskBit(index: IndexInt) MaskInt {
    return lut[1][index];
}

fn valueBit(index: IndexInt, value: bool) MaskInt {
    return lut[@intFromBool(value)][index];
}

fn initLut() [2][size]MaskInt {
    var set_lut: [size]MaskInt = undefined;
    var unset_lut: [size]MaskInt = undefined;
    for (0..size) |i| {
        set_lut[i] = @as(MaskInt, 1) << @as(ShiftInt, @intCast(i));
        unset_lut[i] = ~set_lut[i];
    }
    return .{ unset_lut, set_lut };
}

comptime {
    const tests = @import("tests.zig");
    _ = tests.TestImpl(@This());
}
