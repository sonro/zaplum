const std = @import("std");
const testing = std.testing;
const bit_board = @import("../bit_board.zig");
const MaskInt = bit_board.MaskInt;
const ShiftInt = bit_board.ShiftInt;
const Range = bit_board.Range;
const size = bit_board.size;

const full_mask: MaskInt = ~@as(MaskInt, 0);
const empty_mask: MaskInt = 0;

pub fn testImpl(comptime impl: type) type {
    return struct {
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

        test "set value highest true full mask" {
            const index = size - 1;
            try test_set_value_full_mask(index, true, full_mask);
        }

        test "set value highest false empty mask" {
            const index = size - 1;
            try test_set_value_empty_mask(index, false, 0);
        }

        test "set value highest false full mask" {
            const index = size - 1;
            const expected = full_mask >> 1;
            try test_set_value_full_mask(index, false, expected);
        }

        fn test_set_value_empty_mask(index: u8, value: bool, expected: MaskInt) !void {
            var mask = empty_mask;
            try test_set_value(&mask, index, value, expected);
        }

        fn test_set_value_full_mask(index: u8, value: bool, expected: MaskInt) !void {
            var mask = full_mask;
            try test_set_value(&mask, index, value, expected);
        }

        fn test_set_value(mask: *MaskInt, index: u8, value: bool, expected: MaskInt) !void {
            impl.setValue(mask, index, value);
            try testing.expectEqual(expected, mask.*);
        }
    };
}
