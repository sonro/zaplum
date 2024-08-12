const std = @import("std");
const testing = std.testing;

const chess = @import("../../chess.zig");
const Piece = chess.Piece;
const Square = chess.Square;

pub fn TestImpl(comptime Impl: type) type {
    return struct {
        test "empty" {
            for (0..Piece.hard_count) |pce| {
                const piece = Piece.fromU4(@intCast(pce));
                for (0..piece.maxAllowed()) |i| {
                    try testing.expectEqual(.none, Impl.empty.get(piece, @intCast(i)));
                }
            }
        }

        test "starting" {
            for (exp_start, 0..) |squares, pce| {
                const piece = Piece.fromU4(@intCast(pce));
                for (squares, 0..) |square, i| {
                    try testing.expectEqual(square, Impl.starting.get(piece, @intCast(i)));
                }
            }
        }

        test "set empty" {
            var pm = Impl.empty;
            try testing.expectEqual(.none, pm.get(.white_pawn, 4));
            pm.set(.white_pawn, 4, .a2);
            try testing.expectEqual(.a2, pm.get(.white_pawn, 4));
        }

        test "set twice" {
            var pm = Impl.empty;
            pm.set(.black_knight, 4, .a2);
            pm.set(.black_knight, 4, .a7);
            try testing.expectEqual(.a7, pm.get(.black_knight, 4));
            try testing.expectEqual(.none, pm.get(.white_knight, 4));
        }

        test "unset starting" {
            var pm = Impl.starting;
            pm.set(.black_king, 0, .none);
            try testing.expectEqual(.none, pm.get(.black_king, 0));
        }

        test "slice empty" {
            const slice = Impl.empty.slice(.black_queen);
            for (slice) |sq| try testing.expectEqual(.none, sq);
        }

        test "slice starting" {
            const pawns = Impl.starting.slice(.white_pawn);
            for (exp_start[Piece.white_pawn.toU4()], 0..) |square, i| {
                try testing.expectEqual(square, pawns[i]);
            }
            const kings = Impl.starting.slice(.white_king);
            for (exp_start[Piece.white_king.toU4()], 0..) |square, i| {
                try testing.expectEqual(square, kings[i]);
            }
        }

        test "mutate slice" {
            var pm = Impl.empty;
            const pawns = pm.sliceMut(.white_pawn);
            for (pawns) |*sq| sq.* = .a2;
            for (0..pawns.len) |i| {
                try testing.expectEqual(.a2, pm.get(.white_pawn, @intCast(i)));
            }
        }
    };
}

const exp_start: ExpArray = initExpStart();

const ExpArray = [Piece.hard_count][]const Square;

fn initExpStart() ExpArray {
    var exp: ExpArray = undefined;

    exp[Piece.white_pawn.toU4()] = &[8]Square{ .a2, .b2, .c2, .d2, .e2, .f2, .g2, .h2 };
    exp[Piece.white_knight.toU4()] = &[2]Square{ .b1, .g1 } ++ NoneSquare(8);
    exp[Piece.white_bishop.toU4()] = &[2]Square{ .c1, .f1 } ++ NoneSquare(8);
    exp[Piece.white_rook.toU4()] = &[2]Square{ .a1, .h1 } ++ NoneSquare(8);
    exp[Piece.white_queen.toU4()] = &[1]Square{.d1} ++ NoneSquare(8);
    exp[Piece.white_king.toU4()] = &[1]Square{.e1};

    exp[Piece.black_pawn.toU4()] = &[8]Square{ .a7, .b7, .c7, .d7, .e7, .f7, .g7, .h7 };
    exp[Piece.black_knight.toU4()] = &[2]Square{ .b8, .g8 } ++ NoneSquare(8);
    exp[Piece.black_bishop.toU4()] = &[2]Square{ .c8, .f8 } ++ NoneSquare(8);
    exp[Piece.black_rook.toU4()] = &[2]Square{ .a8, .h8 } ++ NoneSquare(8);
    exp[Piece.black_queen.toU4()] = &[1]Square{.d8} ++ NoneSquare(8);
    exp[Piece.black_king.toU4()] = &[1]Square{.e8};

    return exp;
}

fn NoneSquare(comptime N: usize) [N]Square {
    var arr: [N]Square = undefined;
    for (0..N) |i| {
        arr[i] = Square.none;
    }
    return arr;
}
