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

    for (chess.starting.piece_squares, 0..) |squares, pce| {
        switch (Piece.fromU4(pce).kind()) {
            .pawn,
            .king,
            => appendToExpArrayNoNone(&exp, pce),
            else => appendToExpArray(&exp, pce, squares, 8),
        }
    }

    return exp;
}

fn appendToExpArray(exp: *ExpArray, pce: u4, squares: []const Square, none: usize) void {
    exp[pce] = squares ++ NoneSquare(none);
}

fn appendToExpArrayNoNone(exp: *ExpArray, pce: u4) void {
    appendToExpArray(exp, pce, chess.starting.piece_squares[pce], 0);
}

fn NoneSquare(comptime N: usize) [N]Square {
    var arr: [N]Square = undefined;
    for (0..N) |i| {
        arr[i] = Square.none;
    }
    return arr;
}
