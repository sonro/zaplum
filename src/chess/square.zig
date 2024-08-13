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

    pub fn fromRankFile(rf: RankFile) Square {
        return @enumFromInt(rf.toIndex());
    }

    pub fn toIndex(self: Square) chess.IndexInt {
        return @intFromEnum(self);
    }

    pub fn toRankFile(self: Square) RankFile {
        return RankFile.fromU3(self.rank().toU3(), self.file().toU3());
    }

    pub fn rank(self: Square) Rank {
        return Rank.fromU3(@intCast(self.toIndex() / 8));
    }

    pub fn file(self: Square) File {
        return File.fromU3(@intCast(self.toIndex() % 8));
    }

    pub fn format(self: Square, comptime _: []const u8, _: std.fmt.FormatOptions, writer: anytype) !void {
        try writer.writeAll(@tagName(self));
    }
};

pub const Rank = enum(u3) {
    one = 0,
    two = 1,
    three = 2,
    four = 3,
    five = 4,
    six = 5,
    seven = 6,
    eight = 7,

    const chars = "12345678";

    pub fn fromU3(index: u3) Rank {
        return @enumFromInt(index);
    }

    pub fn toU3(self: Rank) u3 {
        return @intFromEnum(self);
    }

    pub fn format(self: Rank, comptime _: []const u8, _: std.fmt.FormatOptions, writer: anytype) !void {
        try writer.writeByte(self.char());
    }

    pub fn char(self: Rank) u8 {
        return chars[self.toU3()];
    }
};

pub const File = enum(u3) {
    a = 0,
    b = 1,
    c = 2,
    d = 3,
    e = 4,
    f = 5,
    g = 6,
    h = 7,

    pub fn fromU3(index: u3) File {
        return @enumFromInt(index);
    }

    pub fn toU3(self: File) u3 {
        return @intFromEnum(self);
    }

    pub fn format(self: File, comptime _: []const u8, _: std.fmt.FormatOptions, writer: anytype) !void {
        try writer.writeByte(self.char());
    }

    pub fn char(self: File) u8 {
        return @tagName(self)[0];
    }
};

pub const RankFile = struct {
    rank: Rank,
    file: File,

    pub fn fromIndex(index: chess.IndexInt) RankFile {
        return RankFile{
            .rank = Rank.fromU3(@intCast(index / 8)),
            .file = File.fromU3(@intCast(index % 8)),
        };
    }

    pub fn fromU3(rank: u3, file: u3) RankFile {
        return RankFile{
            .rank = Rank.fromU3(rank),
            .file = File.fromU3(file),
        };
    }

    pub fn toIndex(self: RankFile) chess.IndexInt {
        return @as(u8, self.rank.toU3()) * 8 + self.file.toU3();
    }

    pub fn format(self: RankFile, comptime _: []const u8, _: std.fmt.FormatOptions, writer: anytype) !void {
        try writer.print("{c}{c}", .{ self.file.char(), self.rank.char() });
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

test "square from rank file" {
    for (0..chess.board_size) |i| {
        const index: chess.IndexInt = @intCast(i);
        const rank = Rank.fromU3(@intCast(index / 8));
        const file = File.fromU3(@intCast(index % 8));
        const expected = Square.fromIndex(index);
        const actual = Square.fromRankFile(RankFile{ .rank = rank, .file = file });
        try testing.expectEqual(expected, actual);
    }
}

test "square to index" {
    for (0..chess.board_size) |i| {
        const index: u8 = @intCast(i);
        try testing.expectEqual(index, Square.toIndex(@as(Square, @enumFromInt(index))));
    }
}

test "square to rank file" {
    for (0..chess.board_size) |i| {
        const index: chess.IndexInt = @intCast(i);
        const rank = Rank.fromU3(@intCast(index / 8));
        const file = File.fromU3(@intCast(index % 8));
        const expected = RankFile{ .rank = rank, .file = file };
        const actual = Square.toRankFile(Square.fromIndex(index));
        try testing.expectEqual(expected, actual);
    }
}

test "square format" {
    try testFormat("a1", Square.a1);
    try testFormat("a8", Square.a8);
    try testFormat("h1", Square.h1);
    try testFormat("h8", Square.h8);
    try testFormat("none", Square.none);
}

test "rank zero-indexed backing value" {
    try testing.expectEqual(@as(u3, 0), @intFromEnum(Rank.one));
    try testing.expectEqual(@as(u3, 7), @intFromEnum(Rank.eight));
}

test "file zero-indexed backing value" {
    try testing.expectEqual(@as(u3, 0), @intFromEnum(File.a));
    try testing.expectEqual(@as(u3, 7), @intFromEnum(File.h));
}

test "file fromU3" {
    for (0..8) |i| {
        const index: u3 = @intCast(i);
        try testing.expectEqual(@as(File, @enumFromInt(index)), File.fromU3(index));
    }
}

test "file toU3" {
    for (0..8) |i| {
        const index: u3 = @intCast(i);
        try testing.expectEqual(index, File.fromU3(index).toU3());
    }
}

test "rank fromU3" {
    for (0..8) |i| {
        const index: u3 = @intCast(i);
        try testing.expectEqual(@as(Rank, @enumFromInt(index)), Rank.fromU3(index));
    }
}

test "rank toU3" {
    for (0..8) |i| {
        const index: u3 = @intCast(i);
        try testing.expectEqual(index, Rank.fromU3(index).toU3());
    }
}

test "file from square" {
    try testing.expectEqual(File.a, Square.a1.file());
    try testing.expectEqual(File.a, Square.a2.file());
    try testing.expectEqual(File.b, Square.b2.file());
    try testing.expectEqual(File.c, Square.c3.file());
    try testing.expectEqual(File.d, Square.d4.file());
    try testing.expectEqual(File.e, Square.e5.file());
    try testing.expectEqual(File.f, Square.f6.file());
    try testing.expectEqual(File.g, Square.g7.file());
    try testing.expectEqual(File.h, Square.h1.file());
    try testing.expectEqual(File.h, Square.h8.file());
}

test "rank from square" {
    try testing.expectEqual(Rank.one, Square.a1.rank());
    try testing.expectEqual(Rank.two, Square.a2.rank());
    try testing.expectEqual(Rank.two, Square.b2.rank());
    try testing.expectEqual(Rank.three, Square.c3.rank());
    try testing.expectEqual(Rank.four, Square.d4.rank());
    try testing.expectEqual(Rank.five, Square.e5.rank());
    try testing.expectEqual(Rank.six, Square.f6.rank());
    try testing.expectEqual(Rank.seven, Square.g7.rank());
    try testing.expectEqual(Rank.one, Square.h1.rank());
    try testing.expectEqual(Rank.eight, Square.h8.rank());
}

test "format file" {
    try testFormat("a", File.a);
    try testFormat("b", File.b);
    try testFormat("c", File.c);
    try testFormat("d", File.d);
    try testFormat("e", File.e);
    try testFormat("f", File.f);
    try testFormat("g", File.g);
    try testFormat("h", File.h);
}

test "file char" {
    try testing.expectEqual('a', File.a.char());
    try testing.expectEqual('b', File.b.char());
    try testing.expectEqual('c', File.c.char());
    try testing.expectEqual('d', File.d.char());
    try testing.expectEqual('e', File.e.char());
    try testing.expectEqual('f', File.f.char());
    try testing.expectEqual('g', File.g.char());
    try testing.expectEqual('h', File.h.char());
}

test "format rank" {
    try testFormat("1", Rank.one);
    try testFormat("2", Rank.two);
    try testFormat("3", Rank.three);
    try testFormat("4", Rank.four);
    try testFormat("5", Rank.five);
    try testFormat("6", Rank.six);
    try testFormat("7", Rank.seven);
    try testFormat("8", Rank.eight);
}

test "rank char" {
    try testing.expectEqual('1', Rank.one.char());
    try testing.expectEqual('2', Rank.two.char());
    try testing.expectEqual('3', Rank.three.char());
    try testing.expectEqual('4', Rank.four.char());
    try testing.expectEqual('5', Rank.five.char());
    try testing.expectEqual('6', Rank.six.char());
    try testing.expectEqual('7', Rank.seven.char());
    try testing.expectEqual('8', Rank.eight.char());
}

test "rank file from index" {
    for (0..chess.board_size) |i| {
        const index: chess.IndexInt = @intCast(i);
        const rank = Rank.fromU3(@intCast(index / 8));
        const file = File.fromU3(@intCast(index % 8));
        const expected = RankFile{ .rank = rank, .file = file };
        const actual = RankFile.fromIndex(index);
        try testing.expectEqual(expected, actual);
    }
}

test "rank file from u3" {
    for (0..chess.board_size) |i| {
        const index: chess.IndexInt = @intCast(i);
        const rank = Rank.fromU3(@intCast(index / 8));
        const file = File.fromU3(@intCast(index % 8));
        const expected = RankFile{ .rank = rank, .file = file };
        const actual = RankFile.fromU3(rank.toU3(), file.toU3());
        try testing.expectEqual(expected, actual);
    }
}

test "rank file to index" {
    for (0..chess.board_size) |i| {
        const index: chess.IndexInt = @intCast(i);
        const rank = Rank.fromU3(@intCast(index / 8));
        const file = File.fromU3(@intCast(index % 8));
        const rank_file = RankFile{ .rank = rank, .file = file };
        try testing.expectEqual(index, rank_file.toIndex());
    }
}

test "rank file format" {
    try testFormat("a1", RankFile.fromIndex(0));
    try testFormat("b1", RankFile.fromIndex(1));
    try testFormat("a2", RankFile.fromIndex(8));
    try testFormat("h8", RankFile.fromIndex(63));
}

fn testFormat(expected: []const u8, data: anytype) !void {
    var buf = [8]u8{ 0, 0, 0, 0, 0, 0, 0, 0 };
    const actual = try std.fmt.bufPrintZ(buf[0..], "{}", .{data});
    try testing.expectEqualStrings(expected, actual);
}
