const std = @import("std");
const testing = std.testing;
const assert = std.debug.assert;
const builtin = @import("builtin");

const chess = @import("../chess.zig");
const Color = chess.Color;
const Piece = chess.Piece;
const Square = chess.Square;

/// Minimum information required to describe a position
///
/// Uses mailbox placement
pub const Position = PositionConfig(.{
    .Placement = chess.Placement,
    .CastleRights = chess.CastleState,
});

pub const PositionPacked = PositionConfig(.{
    .Placement = chess.Placement.Packed,
    .CastleRights = chess.CastleStatePacked,
});

const PositionOptions = struct {
    Placement: type,
    CastleRights: type,
};

fn PositionConfig(comptime options: PositionOptions) type {
    return struct {
        placement: Self.Placement,
        active_color: Color,
        castling_rights: Self.CastleRights,
        en_passant: Square,
        halfmove_clock: u8,
        fullmove_number: u16,

        pub const empty = initEmpty();
        pub const starting = initStarting();

        pub const Self = @This();
        pub const Placement = options.Placement;
        pub const CastleRights = options.CastleRights;

        pub fn format(self: *const Self, comptime _: []const u8, _: std.fmt.FormatOptions, writer: anytype) !void {
            var rank: usize = 8;
            while (rank > 0) {
                rank -= 1;
                try printRank(self, rank, writer);
                try printInfo(self, rank, writer);
                try writer.writeByte('\n');
            }
        }

        fn printRank(self: *const Self, rank: usize, writer: anytype) !void {
            for (0..8) |file| {
                const rf = chess.RankFile.fromU3(@intCast(rank), @intCast(file));
                const sq = Square.fromRankFile(rf);
                const piece = self.placement.get(sq);
                try writer.print(" {}", .{piece});
            }
        }

        fn printInfo(self: *const Self, rank: usize, writer: anytype) !void {
            switch (rank) {
                5 => try writer.print("    side: {s}", .{self.active_color}),
                4 => try writer.print("  castle: {s}", .{self.castling_rights}),
                3 => try writer.print("  en pas: {s}", .{self.en_passant}),
                2 => try writer.print("  50 mov: {d}", .{self.halfmove_clock}),
                1 => try writer.print("    move: {d}", .{self.fullmove_number}),
                else => {},
            }
        }

        fn initEmpty() Self {
            return Self{
                .placement = Self.Placement.empty,
                .active_color = .white,
                .castling_rights = Self.CastleRights.all,
                .en_passant = .none,
                .halfmove_clock = 0,
                .fullmove_number = 1,
            };
        }

        fn initStarting() Self {
            return Self{
                .placement = Self.Placement.starting,
                .active_color = .white,
                .castling_rights = Self.CastleRights.all,
                .en_passant = .none,
                .halfmove_clock = 0,
                .fullmove_number = 1,
            };
        }
    };
}

comptime {
    _ = TestImpl(Position);
    _ = TestImpl(PositionPacked);
}

fn TestImpl(comptime Impl: type) type {
    return struct {
        test "empty" {
            const actual = Impl.empty;
            try testing.expectEqual(Impl.Placement.empty, actual.placement);
            try testing.expectEqual(Color.white, actual.active_color);
            try testing.expectEqual(Impl.CastleRights.all, actual.castling_rights);
            try testing.expectEqual(Square.none, actual.en_passant);
            try testing.expectEqual(@as(u8, 0), actual.halfmove_clock);
            try testing.expectEqual(@as(u16, 1), actual.fullmove_number);
        }

        test "starting" {
            const actual = Impl.starting;
            try testing.expectEqual(Impl.Placement.starting, actual.placement);
            try testing.expectEqual(Color.white, actual.active_color);
            try testing.expectEqual(Impl.CastleRights.all, actual.castling_rights);
            try testing.expectEqual(Square.none, actual.en_passant);
            try testing.expectEqual(@as(u8, 0), actual.halfmove_clock);
            try testing.expectEqual(@as(u16, 1), actual.fullmove_number);
        }

        test "format starting" {
            const expected =
                \\ r n b q k b n r
                \\ p p p p p p p p
                \\ - - - - - - - -    side: white
                \\ - - - - - - - -  castle: KQkq
                \\ - - - - - - - -  en pas: none
                \\ - - - - - - - -  50 mov: 0
                \\ P P P P P P P P    move: 1
                \\ R N B Q K B N R
                \\
            ;
            try testing.expectFmt(expected, "{}", .{Impl.starting});
        }

        test "format custom italian" {
            const expected =
                \\ r - b q k - - r
                \\ p p p p b p p p
                \\ - - n - - n - -    side: black
                \\ - - - - p - - -  castle: Qkq
                \\ - - B - P - - -  en pas: none
                \\ - - - P - N - -  50 mov: 2
                \\ P P P - - P P P    move: 5
                \\ R N B Q - R K -
                \\
            ;
            var placement = Impl.Placement.starting;
            const empty_squares: []const Square = &.{ .e1, .h1, .d2, .e2, .b8, .f8, .g8 };
            for (empty_squares) |sq| placement.set(sq, .none);
            placement.set(.f1, .white_rook);
            placement.set(.g1, .white_king);
            placement.set(.d3, .white_pawn);
            placement.set(.f3, .white_knight);
            placement.set(.c4, .white_bishop);
            placement.set(.e4, .white_pawn);
            placement.set(.e5, .black_pawn);
            placement.set(.c6, .black_knight);
            placement.set(.f6, .black_knight);
            placement.set(.e7, .black_bishop);
            const actual = Impl{
                .placement = placement,
                .active_color = .black,
                .castling_rights = .{ .white_queen = true, .black_king = true, .black_queen = true },
                .en_passant = .none,
                .halfmove_clock = 2,
                .fullmove_number = 5,
            };
            try testing.expectFmt(expected, "{}", .{actual});
        }

        test "format en passant first move" {
            const expected =
                \\ r n b q k b n r
                \\ p p p p p p p p
                \\ - - - - - - - -    side: black
                \\ - - - - - - - -  castle: KQkq
                \\ - - - - P - - -  en pas: e3
                \\ - - - - - - - -  50 mov: 0
                \\ P P P P - P P P    move: 1
                \\ R N B Q K B N R
                \\
            ;
            var placement = Impl.Placement.starting;
            placement.set(.e2, .none);
            placement.set(.e4, .white_pawn);
            const actual = Impl{
                .placement = placement,
                .active_color = .black,
                .castling_rights = Impl.CastleRights.all,
                .en_passant = .e3,
                .halfmove_clock = 0,
                .fullmove_number = 1,
            };
            try testing.expectFmt(expected, "{}", .{actual});
        }
    };
}
