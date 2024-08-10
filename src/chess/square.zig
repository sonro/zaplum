const std = @import("std");
const testing = std.testing;

const chess = @import("../chess.zig");

pub const Square = enum(chess.IndexInt) {
    // zig fmt: off
    a1 = 0, b1, c1, d1, e1, f1, g1, h1,
        a2, b2, c2, d2, e2, f2, g2, h2,
        a3, b3, c3, d3, e3, f3, g3, h3,
        a4, b4, c4, d4, e4, f4, g4, h4,
        a5, b5, c5, d5, e5, f5, g5, h5,
        a6, b6, c6, d6, e6, f6, g6, h6,
        a7, b7, c7, d7, e7, f7, g7, h7,
        a8, b8, c8, d8, e8, f8, g8, h8,
    none = 64,
    // zig fmt: on

    pub fn fromIndex(index: chess.IndexInt) Square {
        return @enumFromInt(index);
    }

    pub fn toIndex(self: Square) chess.IndexInt {
        return @intFromEnum(self);
    }

    pub fn format(self: Square, comptime _: []const u8, _: std.fmt.FormatOptions, writer: anytype) !void {
        try writer.writeAll(@tagName(self));
    }
};

test "square little endian order" {
    try testing.expectEqual(Square.a1, @as(Square, @enumFromInt(0 * 8 + 0)));
    try testing.expectEqual(Square.a8, @as(Square, @enumFromInt(8 * 7 + 0)));
    try testing.expectEqual(Square.h1, @as(Square, @enumFromInt(8 * 0 + 7)));
    try testing.expectEqual(Square.h8, @as(Square, @enumFromInt(8 * 7 + 7)));
}

test "square from index" {
    for (0..chess.board_size) |i| {
        const index: u8 = @intCast(i);
        try testing.expectEqual(@as(Square, @enumFromInt(index)), Square.fromIndex(index));
    }
    try testing.expectEqual(Square.none, Square.fromIndex(chess.board_size));
}

test "square to index" {
    for (0..chess.board_size) |i| {
        const index: u8 = @intCast(i);
        try testing.expectEqual(index, Square.toIndex(@as(Square, @enumFromInt(index))));
    }
}

test "square format" {
    try testFormatSquare("a1", Square.a1);
    try testFormatSquare("a8", Square.a8);
    try testFormatSquare("h1", Square.h1);
    try testFormatSquare("h8", Square.h8);
    try testFormatSquare("none", Square.none);
}

fn testFormatSquare(expected: []const u8, square: Square) !void {
    var buf = [5:0]u8{ 0, 0, 0, 0, 0 };
    const actual = try std.fmt.bufPrintZ(buf[0..], "{}", .{square});
    try testing.expectEqualStrings(expected, actual);
}
