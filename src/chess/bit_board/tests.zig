const std = @import("std");
const testing = std.testing;
const bit_board = @import("../BitBoard.zig");
const chess = @import("../../chess.zig");
const MaskInt = bit_board.MaskInt;
const ShiftInt = bit_board.ShiftInt;
const Range = chess.Range;
const size = chess.board_size;
const IndexInt = chess.IndexInt;

const full_mask: MaskInt = ~@as(MaskInt, 0);
const empty_mask: MaskInt = 0;

pub fn testImpl(comptime impl: type) type {
    return struct {
        test "set value lowest true empty mask" {
            try testSetValueEmptyMask(0, true, 1);
        }

        test "set value lowest true full mask" {
            try testSetValueFullMask(0, true, full_mask);
        }

        test "set value lowest false empty mask" {
            try testSetValueEmptyMask(0, false, 0);
        }

        test "set value lowest false full mask" {
            const expected = full_mask << 1;
            try testSetValueFullMask(0, false, expected);
        }

        test "set value highest true empty mask" {
            const index = size - 1;
            const expected = 1 << index;
            try testSetValueEmptyMask(index, true, expected);
        }

        test "set value highest true full mask" {
            const index = size - 1;
            try testSetValueFullMask(index, true, full_mask);
        }

        test "set value highest false empty mask" {
            const index = size - 1;
            try testSetValueEmptyMask(index, false, 0);
        }

        test "set value highest false full mask" {
            const index = size - 1;
            const expected = full_mask >> 1;
            try testSetValueFullMask(index, false, expected);
        }

        test "set range value start single range true empty mask" {
            const range = Range{ .start = 0, .end = 1 };
            try testSetRangeValueEmptyMask(range, true, 1);
        }

        test "set range value start single range true full mask" {
            const range = Range{ .start = 0, .end = 1 };
            try testSetRangeValueFullMask(range, true, full_mask);
        }

        test "set range value start single range true custom mask" {
            const range = Range{ .start = 0, .end = 1 };
            var custom_mask: MaskInt = 0b1011_0110;
            const expected: MaskInt = 0b1011_0111;
            try testSetRangeValue(&custom_mask, range, true, expected);
        }

        test "set range value start single range false empty mask" {
            const range = Range{ .start = 0, .end = 1 };
            try testSetRangeValueEmptyMask(range, false, 0);
        }

        test "set range value start single range false full mask" {
            const range = Range{ .start = 0, .end = 1 };
            const expected = full_mask << 1;
            try testSetRangeValueFullMask(range, false, expected);
        }

        test "set range value start single range false custom mask" {
            const range = Range{ .start = 0, .end = 1 };
            var custom_mask: MaskInt = 0b1011_0110;
            const expected: MaskInt = 0b1011_0110;
            try testSetRangeValue(&custom_mask, range, false, expected);
        }

        test "set range value middle single range true empty mask" {
            const range = Range{ .start = 2, .end = 3 };
            try testSetRangeValueEmptyMask(range, true, 4);
        }

        test "set range value middle single range true full mask" {
            const range = Range{ .start = 2, .end = 3 };
            try testSetRangeValueFullMask(range, true, full_mask);
        }

        test "set range value middle signel range true custom mask" {
            const range = Range{ .start = 3, .end = 4 };
            var custom_mask: MaskInt = 0b1011_0110;
            const expected: MaskInt = 0b1011_1110;
            try testSetRangeValue(&custom_mask, range, true, expected);
        }

        test "set range value middle single range false empty mask" {
            const range = Range{ .start = 2, .end = 3 };
            try testSetRangeValueEmptyMask(range, false, 0);
        }

        test "set range value middle single range false full mask" {
            const range = Range{ .start = 2, .end = 3 };
            const expected = full_mask & ~(@as(MaskInt, 1) << 2);
            try testSetRangeValueFullMask(range, false, expected);
        }

        test "set range value middle single range false custom mask" {
            const range = Range{ .start = 4, .end = 5 };
            var custom_mask: MaskInt = 0b1011_0110;
            const expected: MaskInt = 0b1010_0110;
            try testSetRangeValue(&custom_mask, range, false, expected);
        }

        test "set range value end single range true empty mask" {
            const range = Range{ .start = size - 1, .end = size };
            const expected = empty_mask | (@as(MaskInt, 1) << (size - 1));
            try testSetRangeValueEmptyMask(range, true, expected);
        }

        test "set range value end single range true full mask" {
            const range = Range{ .start = size - 1, .end = size };
            try testSetRangeValueFullMask(range, true, full_mask);
        }

        test "set range value end single range true custom mask" {
            const range = Range{ .start = size - 1, .end = size };
            var custom_mask: MaskInt = 0b1011_0110;
            const expected = custom_mask | (@as(MaskInt, 1) << (size - 1));
            try testSetRangeValue(&custom_mask, range, true, expected);
        }

        test "set range value end single range false empty mask" {
            const range = Range{ .start = size - 1, .end = size };
            try testSetRangeValueEmptyMask(range, false, 0);
        }

        test "set range value end single range false full mask" {
            const range = Range{ .start = size - 1, .end = size };
            const expected = full_mask ^ (@as(MaskInt, 1) << (size - 1));
            try testSetRangeValueFullMask(range, false, expected);
        }

        test "set range value full range true empty mask" {
            const range = Range{ .start = 0, .end = size };
            try testSetRangeValueEmptyMask(range, true, full_mask);
        }

        test "set range value full range true full mask" {
            const range = Range{ .start = 0, .end = size };
            try testSetRangeValueFullMask(range, true, full_mask);
        }

        test "set range value full range false empty mask" {
            const range = Range{ .start = 0, .end = size };
            try testSetRangeValueEmptyMask(range, false, empty_mask);
        }

        test "set range value full range false full mask" {
            const range = Range{ .start = 0, .end = size };
            try testSetRangeValueFullMask(range, false, empty_mask);
        }

        test "set range value middle range true empty mask" {
            const range = Range{ .start = 2, .end = 4 };
            try testSetRangeValueEmptyMask(range, true, 0b1100);
        }

        test "set range value middle range false full mask" {
            const range = Range{ .start = 2, .end = 4 };
            const expected = full_mask ^ 0b1100;
            try testSetRangeValueFullMask(range, false, expected);
        }

        test "set start empty mask" {
            try testSetEmptyMask(0, 1);
        }

        test "set start full mask" {
            try testSetFullMask(0, full_mask);
        }

        test "set custom mask" {
            var custom_mask: MaskInt = 0b1011_0110;
            const expected: MaskInt = 0b1011_1110;
            try testSet(&custom_mask, 3, expected);
        }

        test "set end empty mask" {
            const index = size - 1;
            const expected = 1 << index;
            try testSetEmptyMask(index, expected);
        }

        test "set end full mask" {
            const index = size - 1;
            try testSetFullMask(index, full_mask);
        }

        test "set range start single range empty mask" {
            const range = Range{ .start = 0, .end = 1 };
            try testSetRangeEmptyMask(range, 1);
        }

        test "set range start single range full mask" {
            const range = Range{ .start = 0, .end = 1 };
            try testSetRangeFullMask(range, full_mask);
        }

        test "set range custom mask" {
            const range = Range{ .start = 4, .end = 8 };
            var custom_mask: MaskInt = 0b1011_0110;
            const expected: MaskInt = 0b1111_0110;
            try testSetRange(&custom_mask, range, expected);
        }

        test "set range end single range empty mask" {
            const range = Range{ .start = size - 1, .end = size };
            try testSetRangeEmptyMask(range, 1 << (size - 1));
        }

        test "set range end single range full mask" {
            const range = Range{ .start = size - 1, .end = size };
            try testSetRangeFullMask(range, full_mask);
        }

        test "unset start empty mask" {
            try testUnsetEmptyMask(0, 0);
        }

        test "unset start full mask" {
            const expected = full_mask >> 1;
            try testUnsetFullMask(size - 1, expected);
        }

        test "unset custom mask" {
            var custom_mask: MaskInt = 0b1011_0110;
            const expected: MaskInt = 0b1011_0010;
            try testUnset(&custom_mask, 2, expected);
        }

        test "unset range start single range empty mask" {
            const range = Range{ .start = 0, .end = 1 };
            try testUnsetRangeEmptyMask(range, 0);
        }

        test "unset range start single range full mask" {
            const range = Range{ .start = 0, .end = 1 };
            const expected = full_mask << 1;
            try testUnsetRangeFullMask(range, expected);
        }

        test "unset range custom mask" {
            const range = Range{ .start = 4, .end = 8 };
            var custom_mask: MaskInt = 0b1011_0110;
            const expected: MaskInt = 0b0000_0110;
            try testUnsetRange(&custom_mask, range, expected);
        }

        test "unset range end single range empty mask" {
            const range = Range{ .start = size - 1, .end = size };
            try testUnsetRangeEmptyMask(range, 0);
        }

        test "unset range end single range full mask" {
            const range = Range{ .start = size - 1, .end = size };
            const expected = full_mask >> 1;
            try testUnsetRangeFullMask(range, expected);
        }

        test "unset full range full mask" {
            const range = Range{ .start = 0, .end = size };
            const expected = 0;
            try testUnsetRangeFullMask(range, expected);
        }

        test "toggle lowest empty mask" {
            try testToggleEmptyMask(0, 1);
        }

        test "toggle lowest full mask" {
            try testToggleFullMask(0, full_mask << 1);
        }

        test "toggle custom mask" {
            var custom_mask: MaskInt = 0b1011_0110;
            const expected: MaskInt = 0b1011_1110;
            try testToggle(&custom_mask, 3, expected);
        }

        test "toggle custom mask twice" {
            const original: MaskInt = 0b1011_0110;
            const toggled: MaskInt = 0b1011_0010;
            var custom_mask: MaskInt = original;
            try testToggle(&custom_mask, 2, toggled);
            try testToggle(&custom_mask, 2, original);
        }

        test "toggle highest empty mask" {
            try testToggleEmptyMask(size - 1, 1 << (size - 1));
        }

        test "toggle highest full mask" {
            try testToggleFullMask(size - 1, full_mask >> 1);
        }

        fn testToggleEmptyMask(index: IndexInt, expected: MaskInt) !void {
            var mask = empty_mask;
            try testToggle(&mask, index, expected);
        }

        fn testToggleFullMask(index: IndexInt, expected: MaskInt) !void {
            var mask = full_mask;
            try testToggle(&mask, index, expected);
        }

        fn testSetValueEmptyMask(index: IndexInt, value: bool, expected: MaskInt) !void {
            var mask = empty_mask;
            try testSetValue(&mask, index, value, expected);
        }

        fn testSetValueFullMask(index: IndexInt, value: bool, expected: MaskInt) !void {
            var mask = full_mask;
            try testSetValue(&mask, index, value, expected);
        }

        fn testSetRangeValueEmptyMask(range: Range, value: bool, expected: MaskInt) !void {
            var mask = empty_mask;
            try testSetRangeValue(&mask, range, value, expected);
        }

        fn testSetRangeValueFullMask(range: Range, value: bool, expected: MaskInt) !void {
            var mask = full_mask;
            try testSetRangeValue(&mask, range, value, expected);
        }

        fn testSetEmptyMask(index: IndexInt, expected: MaskInt) !void {
            var mask = empty_mask;
            try testSet(&mask, index, expected);
        }

        fn testSetFullMask(index: IndexInt, expected: MaskInt) !void {
            var mask = full_mask;
            try testSet(&mask, index, expected);
        }

        fn testSetRangeEmptyMask(range: Range, expected: MaskInt) !void {
            var mask = empty_mask;
            try testSetRange(&mask, range, expected);
        }

        fn testSetRangeFullMask(range: Range, expected: MaskInt) !void {
            var mask = full_mask;
            try testSetRange(&mask, range, expected);
        }

        fn testUnsetEmptyMask(index: IndexInt, expected: MaskInt) !void {
            var mask = empty_mask;
            try testUnset(&mask, index, expected);
        }

        fn testUnsetFullMask(index: IndexInt, expected: MaskInt) !void {
            var mask = full_mask;
            try testUnset(&mask, index, expected);
        }

        fn testUnsetRangeEmptyMask(range: Range, expected: MaskInt) !void {
            var mask = empty_mask;
            try testUnsetRange(&mask, range, expected);
        }

        fn testUnsetRangeFullMask(range: Range, expected: MaskInt) !void {
            var mask = full_mask;
            try testUnsetRange(&mask, range, expected);
        }

        fn testSetRangeValue(mask: *MaskInt, range: Range, value: bool, expected: MaskInt) !void {
            impl.setRangeValue(mask, range, value);
            try testing.expectEqual(expected, mask.*);
        }

        fn testSetValue(mask: *MaskInt, index: IndexInt, value: bool, expected: MaskInt) !void {
            impl.setValue(mask, index, value);
            try testing.expectEqual(expected, mask.*);
        }

        fn testSet(mask: *MaskInt, index: IndexInt, expected: MaskInt) !void {
            impl.set(mask, index);
            try testing.expectEqual(expected, mask.*);
        }

        fn testSetRange(mask: *MaskInt, range: Range, expected: MaskInt) !void {
            impl.setRange(mask, range);
            try testing.expectEqual(expected, mask.*);
        }

        fn testUnset(mask: *MaskInt, index: IndexInt, expected: MaskInt) !void {
            impl.unset(mask, index);
            try testing.expectEqual(expected, mask.*);
        }

        fn testUnsetRange(mask: *MaskInt, range: Range, expected: MaskInt) !void {
            impl.unsetRange(mask, range);
            try testing.expectEqual(expected, mask.*);
        }

        fn testToggle(mask: *MaskInt, index: IndexInt, expected: MaskInt) !void {
            impl.toggle(mask, index);
            try testing.expectEqual(expected, mask.*);
        }
    };
}
