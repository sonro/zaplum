const std = @import("std");
const testing = std.testing;

const zaplum = @import("../zaplum.zig");
const Side = zaplum.chess.Side;

const ConditionImpl = @import("piece/ConditionImpl.zig");
const LookupImpl = @import("piece/LookupImpl.zig");

pub const Piece = enum(u4) {
    white_pawn = 0,
    white_knight,
    white_bishop,
    white_rook,
    white_queen,
    white_king,

    black_pawn,
    black_knight,
    black_bishop,
    black_rook,
    black_queen,
    black_king,

    none,

    /// Includes `none`
    pub const count = @typeInfo(Piece).Enum.fields.len;
    /// Excludes `none`
    pub const hard_count = count - 1;
    /// Maximum number of playing pieces on a board
    pub const max = 32;

    /// Implementation for information about pieces
    pub const Impl = enum {
        condition,
        lookup,
    };

    pub const default_impl = Impl.lookup;

    const impl = switch (zaplum.options.piece_impl) {
        .condition => ConditionImpl,
        .lookup => LookupImpl,
    };

    pub fn fromU4(value: u4) Piece {
        return @enumFromInt(value);
    }

    pub fn toU4(self: Piece) u4 {
        return @intFromEnum(self);
    }

    pub fn side(self: Piece) Side {
        return impl.side(self);
    }

    pub fn kind(self: Piece) Kind {
        return impl.kind(self);
    }

    pub fn humanValue(self: Piece) i8 {
        return impl.humanValue(self);
    }

    pub fn isBig(self: Piece) bool {
        return impl.isBig(self);
    }

    pub fn isMajor(self: Piece) bool {
        return impl.isMajor(self);
    }

    pub fn isMinor(self: Piece) bool {
        return impl.isMinor(self);
    }

    pub fn isSlider(self: Piece) bool {
        return impl.isSlider(self);
    }

    pub fn isDiagonalSlider(self: Piece) bool {
        return impl.isDiagonalSlider(self);
    }

    pub fn isOrthogonalSlider(self: Piece) bool {
        return impl.isOrthogonalSlider(self);
    }

    pub fn format(self: Piece, comptime _: []const u8, _: std.fmt.FormatOptions, writer: anytype) !void {
        try writer.writeByte(self.char());
    }

    /// The character used in algebraic notation
    pub fn char(self: Piece) u8 {
        return impl.char(self);
    }

    pub const Kind = enum(u3) {
        pawn,
        knight,
        bishop,
        rook,
        queen,
        king,
        none,

        /// Includes `none`
        pub const count = @typeInfo(Kind).Enum.fields.len;
        /// Excludes `none`
        pub const hard_count = Kind.count - 1;

        pub fn fromU3(value: u3) Kind {
            return @enumFromInt(value);
        }

        pub fn toU3(self: Kind) u3 {
            return @intFromEnum(self);
        }

        pub fn format(self: Kind, comptime _: []const u8, _: std.fmt.FormatOptions, writer: anytype) !void {
            try writer.writeAll(@tagName(self));
        }
    };
};

test "piece count includes none" {
    try testing.expectEqual(13, Piece.count);
}

test "piece hard count excludes none" {
    try testing.expectEqual(12, Piece.hard_count);
}

test "max pieces should be 32" {
    try testing.expectEqual(32, Piece.max);
}

test "Piece from u4" {
    try testing.expectEqual(Piece.white_pawn, Piece.fromU4(0));
    try testing.expectEqual(Piece.white_knight, Piece.fromU4(1));
    try testing.expectEqual(Piece.white_bishop, Piece.fromU4(2));
    try testing.expectEqual(Piece.white_rook, Piece.fromU4(3));
    try testing.expectEqual(Piece.white_queen, Piece.fromU4(4));
    try testing.expectEqual(Piece.white_king, Piece.fromU4(5));
    try testing.expectEqual(Piece.black_pawn, Piece.fromU4(6));
    try testing.expectEqual(Piece.black_knight, Piece.fromU4(7));
    try testing.expectEqual(Piece.black_bishop, Piece.fromU4(8));
    try testing.expectEqual(Piece.black_rook, Piece.fromU4(9));
    try testing.expectEqual(Piece.black_queen, Piece.fromU4(10));
    try testing.expectEqual(Piece.black_king, Piece.fromU4(11));
    try testing.expectEqual(Piece.none, Piece.fromU4(12));
}

test "piece to u4" {
    for (0..Piece.count) |i| {
        const index: u4 = @intCast(i);
        try testing.expectEqual(index, Piece.fromU4(index).toU4());
    }
}

test "piece format is algebraic" {
    try testFormat("-", Piece.none);
    try testFormat("P", Piece.white_pawn);
    try testFormat("N", Piece.white_knight);
    try testFormat("B", Piece.white_bishop);
    try testFormat("R", Piece.white_rook);
    try testFormat("Q", Piece.white_queen);
    try testFormat("K", Piece.white_king);
    try testFormat("p", Piece.black_pawn);
    try testFormat("n", Piece.black_knight);
    try testFormat("b", Piece.black_bishop);
    try testFormat("r", Piece.black_rook);
    try testFormat("q", Piece.black_queen);
    try testFormat("k", Piece.black_king);
}

test "piece side" {
    try testing.expectEqual(Side.white, Piece.white_pawn.side());
    try testing.expectEqual(Side.black, Piece.black_pawn.side());
}

test "piece kind" {
    try testing.expectEqual(Piece.Kind.pawn, Piece.white_pawn.kind());
    try testing.expectEqual(Piece.Kind.pawn, Piece.black_pawn.kind());
}

test "piece human value" {
    try testing.expectEqual(1, Piece.white_pawn.humanValue());
    try testing.expectEqual(-1, Piece.black_pawn.humanValue());

    try testing.expectEqual(3, Piece.white_knight.humanValue());
    try testing.expectEqual(-3, Piece.black_knight.humanValue());
}

test "piece is big" {
    try testing.expect(!Piece.white_pawn.isBig());
    try testing.expect(!Piece.black_pawn.isBig());

    try testing.expect(Piece.white_knight.isBig());
    try testing.expect(Piece.black_knight.isBig());

    try testing.expect(Piece.white_king.isBig());
    try testing.expect(Piece.black_king.isBig());
}

test "piece is minor" {
    try testing.expect(!Piece.white_pawn.isMinor());
    try testing.expect(!Piece.black_pawn.isMinor());

    try testing.expect(Piece.white_knight.isMinor());
    try testing.expect(Piece.black_knight.isMinor());

    try testing.expect(!Piece.white_rook.isMinor());
    try testing.expect(!Piece.black_rook.isMinor());
}

test "piece is major" {
    try testing.expect(!Piece.white_pawn.isMajor());
    try testing.expect(!Piece.black_pawn.isMajor());

    try testing.expect(!Piece.white_knight.isMajor());
    try testing.expect(!Piece.black_knight.isMajor());

    try testing.expect(Piece.white_rook.isMajor());
    try testing.expect(Piece.black_rook.isMajor());
}

test "piece is slider" {
    try testing.expect(Piece.white_bishop.isSlider());
    try testing.expect(Piece.black_rook.isSlider());
    try testing.expect(Piece.white_queen.isSlider());
    try testing.expect(!Piece.black_king.isSlider());
}

test "piece is diagonal slider" {
    try testing.expect(!Piece.white_pawn.isDiagonalSlider());
    try testing.expect(Piece.white_bishop.isDiagonalSlider());
    try testing.expect(!Piece.black_rook.isDiagonalSlider());
    try testing.expect(Piece.white_queen.isDiagonalSlider());
    try testing.expect(!Piece.black_king.isDiagonalSlider());
}

test "piece is orthogonal slider" {
    try testing.expect(!Piece.white_pawn.isOrthogonalSlider());
    try testing.expect(!Piece.white_bishop.isOrthogonalSlider());
    try testing.expect(Piece.black_rook.isOrthogonalSlider());
    try testing.expect(Piece.white_queen.isOrthogonalSlider());
    try testing.expect(!Piece.black_king.isOrthogonalSlider());
}

test "piece char" {
    try testing.expectEqual('-', Piece.none.char());
    try testing.expectEqual('P', Piece.white_pawn.char());
    try testing.expectEqual('N', Piece.white_knight.char());
    try testing.expectEqual('B', Piece.white_bishop.char());
    try testing.expectEqual('R', Piece.white_rook.char());
    try testing.expectEqual('Q', Piece.white_queen.char());
    try testing.expectEqual('K', Piece.white_king.char());
    try testing.expectEqual('p', Piece.black_pawn.char());
    try testing.expectEqual('n', Piece.black_knight.char());
    try testing.expectEqual('b', Piece.black_bishop.char());
    try testing.expectEqual('r', Piece.black_rook.char());
    try testing.expectEqual('q', Piece.black_queen.char());
    try testing.expectEqual('k', Piece.black_king.char());
}

test "kind from u3" {
    try testing.expectEqual(Piece.Kind.pawn, Piece.Kind.fromU3(0));
    try testing.expectEqual(Piece.Kind.knight, Piece.Kind.fromU3(1));
    try testing.expectEqual(Piece.Kind.bishop, Piece.Kind.fromU3(2));
    try testing.expectEqual(Piece.Kind.rook, Piece.Kind.fromU3(3));
    try testing.expectEqual(Piece.Kind.queen, Piece.Kind.fromU3(4));
    try testing.expectEqual(Piece.Kind.king, Piece.Kind.fromU3(5));
}

test "kind to u3" {
    for (0..Piece.Kind.count) |i| {
        const index: u3 = @intCast(i);
        try testing.expectEqual(index, Piece.Kind.fromU3(index).toU3());
    }
}

test "kind format" {
    try testFormat("pawn", Piece.Kind.pawn);
    try testFormat("knight", Piece.Kind.knight);
    try testFormat("bishop", Piece.Kind.bishop);
    try testFormat("rook", Piece.Kind.rook);
    try testFormat("queen", Piece.Kind.queen);
    try testFormat("king", Piece.Kind.king);
}

fn testFormat(expected: []const u8, data: anytype) !void {
    var buf = [_]u8{0} ** 16;
    const actual = try std.fmt.bufPrintZ(buf[0..], "{}", .{data});
    try testing.expectEqualStrings(expected, actual);
}
