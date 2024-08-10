const std = @import("std");
const testing = std.testing;

const chess = @import("../chess.zig");

/// Can only be white or black. For both use `Side`
pub const Color = enum(u1) {
    white = 0,
    black = 1,

    pub fn toU1(self: Color) u1 {
        return @intFromEnum(self);
    }

    pub fn fromU1(value: u1) Color {
        return @enumFromInt(value);
    }

    pub fn fromSide(side: Side) chess.Error!Color {
        if (side == .both) {
            return error.InvalidColor;
        }
        return Color.fromU1(@truncate(side.toU2()));
    }

    pub fn format(self: Color, comptime _: []const u8, _: std.fmt.FormatOptions, writer: anytype) !void {
        try writer.writeAll(@tagName(self));
    }
};

/// Can be white, black, or both. Prefer using `Color`
pub const Side = enum(u2) {
    white = 0,
    black = 1,
    both = 2,
    none = 3,

    pub fn toU2(self: Side) u2 {
        return @intFromEnum(self);
    }

    pub fn fromU2(value: u2) Side {
        return @enumFromInt(value);
    }

    pub fn format(self: Side, comptime _: []const u8, _: std.fmt.FormatOptions, writer: anytype) !void {
        try writer.writeAll(@tagName(self));
    }
};

test "color white is zero" {
    try testing.expectEqual(@as(u1, 0), @intFromEnum(Color.white));
    try testing.expectEqual(@as(u1, 0), Color.white.toU1());
}

test "color black is one" {
    try testing.expectEqual(@as(u1, 1), @intFromEnum(Color.black));
    try testing.expectEqual(@as(u1, 1), Color.black.toU1());
}

test "color fromU1" {
    try testing.expectEqual(Color.white, Color.fromU1(0));
    try testing.expectEqual(Color.black, Color.fromU1(1));
}

test "side white is zero" {
    try testing.expectEqual(@as(u2, 0), @intFromEnum(Side.white));
    try testing.expectEqual(@as(u2, 0), Side.white.toU2());
}

test "side black is one" {
    try testing.expectEqual(@as(u2, 1), @intFromEnum(Side.black));
    try testing.expectEqual(@as(u2, 1), Side.black.toU2());
}

test "side both is two" {
    try testing.expectEqual(@as(u2, 2), @intFromEnum(Side.both));
    try testing.expectEqual(@as(u2, 2), Side.both.toU2());
}

test "side fromU2" {
    try testing.expectEqual(Side.white, Side.fromU2(0));
    try testing.expectEqual(Side.black, Side.fromU2(1));
    try testing.expectEqual(Side.both, Side.fromU2(2));
}

test "color from side" {
    try testing.expectEqual(Color.white, try Color.fromSide(.white));
    try testing.expectEqual(Color.black, try Color.fromSide(.black));
    const res = Color.fromSide(.both);
    try testing.expectError(error.InvalidColor, res);
}

test "format color" {
    try testFormat("white", Color.white);
    try testFormat("black", Color.black);
}

test "format side" {
    try testFormat("white", Side.white);
    try testFormat("black", Side.black);
    try testFormat("both", Side.both);
    try testFormat("none", Side.none);
}

fn testFormat(expected: []const u8, data: anytype) !void {
    const actual = try std.fmt.allocPrint(testing.allocator, "{s}", .{data});
    defer testing.allocator.free(actual);
    try testing.expectEqualStrings(expected, actual);
}
