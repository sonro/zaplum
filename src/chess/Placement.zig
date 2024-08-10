//! Arrangement of pieces on a chess board
const Placement = @This();

const std = @import("std");
const testing = std.testing;
const assert = std.debug.assert;

const chess = @import("../chess.zig");
const board_size = chess.board_size;
const Piece = chess.Piece;
const Square = chess.Square;

squares: [board_size]Piece,

pub const empty = Placement{ .squares = [_]Piece{.none} ** board_size };

pub const starting = Placement{ .squares = [board_size]Piece{
    .white_rook, .white_knight, .white_bishop, .white_queen, .white_king, .white_bishop, .white_knight, .white_rook,
    .white_pawn, .white_pawn,   .white_pawn,   .white_pawn,  .white_pawn, .white_pawn,   .white_pawn,   .white_pawn,
    .none,       .none,         .none,         .none,        .none,       .none,         .none,         .none,
    .none,       .none,         .none,         .none,        .none,       .none,         .none,         .none,
    .none,       .none,         .none,         .none,        .none,       .none,         .none,         .none,
    .none,       .none,         .none,         .none,        .none,       .none,         .none,         .none,
    .black_pawn, .black_pawn,   .black_pawn,   .black_pawn,  .black_pawn, .black_pawn,   .black_pawn,   .black_pawn,
    .black_rook, .black_knight, .black_bishop, .black_queen, .black_king, .black_bishop, .black_knight, .black_rook,
} };

pub fn get(self: Placement, square: Square) Piece {
    assert(square != .none);
    return self.squares[square.toIndex()];
}

pub fn set(self: *Placement, square: Square, piece: Piece) void {
    assert(square != .none);
    self.squares[square.toIndex()] = piece;
}

pub const Packed = struct {
    squares: Array,

    pub const empty = Packed{ .squares = Array.initAllTo(Piece.none.toU4()) };
    pub const starting = initStarting();

    pub const Array = std.PackedIntArray(u4, board_size);

    pub fn get(self: Packed, square: Square) Piece {
        assert(square != .none);
        return Piece.fromU4(self.squares.get(square.toIndex()));
    }

    pub fn set(self: *Packed, square: Square, piece: Piece) void {
        assert(square != .none);
        self.squares.set(square.toIndex(), piece.toU4());
    }

    fn initStarting() Packed {
        var self = Packed{ .squares = undefined };
        for (Placement.starting.squares, 0..) |piece, i| {
            self.squares.set(i, piece.toU4());
        }
        return self;
    }
};

comptime {
    _ = TestImpl(Placement);
    _ = TestImpl(Packed);
}

fn TestImpl(comptime Impl: type) type {
    return struct {
        test "empty" {
            try testPieces(&testSqPcRepeat(.a1, .h8, .none, board_size), Impl.empty);
        }

        test "starting white big pieces" {
            const expected = [8]TestSqPc{
                .{ .a1, .white_rook },
                .{ .b1, .white_knight },
                .{ .c1, .white_bishop },
                .{ .d1, .white_queen },
                .{ .e1, .white_king },
                .{ .f1, .white_bishop },
                .{ .g1, .white_knight },
                .{ .h1, .white_rook },
            };
            try testPieces(&expected, Impl.starting);
        }

        test "starting black big pieces" {
            const expected = [8]TestSqPc{
                .{ .a8, .black_rook },
                .{ .b8, .black_knight },
                .{ .c8, .black_bishop },
                .{ .d8, .black_queen },
                .{ .e8, .black_king },
                .{ .f8, .black_bishop },
                .{ .g8, .black_knight },
                .{ .h8, .black_rook },
            };
            try testPieces(&expected, Impl.starting);
        }

        test "starting white pawns" {
            try testPieces(&testSqPcRepeat(.a2, .h2, .white_pawn, 8), Impl.starting);
        }

        test "starting black pawns" {
            try testPieces(&testSqPcRepeat(.a7, .h7, .black_pawn, 8), Impl.starting);
        }

        test "starting no pieces" {
            try testPieces(&testSqPcRepeat(.a3, .h6, .none, 32), Impl.starting);
        }

        test "get set get" {
            var placement = Impl.empty;
            try testing.expectEqual(Piece.none, placement.get(.a1));
            placement.set(.a2, .white_pawn);
            try testing.expectEqual(Piece.white_pawn, placement.get(.a2));
        }

        const TestSqPc = struct { Square, Piece };

        fn testSqPcRepeat(start: Square, last: Square, piece: Piece, comptime len: usize) [len]TestSqPc {
            var list: [len]TestSqPc = undefined;
            const start_index = start.toIndex();
            const end_index = last.toIndex() + 1;
            for (start_index..end_index, 0..) |sq, i| {
                list[i] = .{ @enumFromInt(sq), piece };
            }
            return list;
        }

        fn testPieces(expected: []const TestSqPc, placement: Impl) !void {
            for (expected) |exp| {
                try testing.expectEqual(exp[1], placement.get(exp[0]));
            }
        }
    };
}
