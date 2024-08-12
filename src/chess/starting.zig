//! Useful starting position representations

const std = @import("std");
const testing = std.testing;

const chess = @import("../chess.zig");
const Piece = chess.Piece;
const Square = chess.Square;

/// Slice of `Square` per `Piece` representing the starting position
pub const piece_squares: PieceSquares = initPieceSquares();

pub const PieceSquares = [Piece.hard_count][]const Square;

fn initPieceSquares() PieceSquares {
    var ps: PieceSquares = undefined;

    setPieceSquares(&ps, .white_pawn, &.{ .a2, .b2, .c2, .d2, .e2, .f2, .g2, .h2 });
    setPieceSquares(&ps, .white_knight, &.{ .b1, .g1 });
    setPieceSquares(&ps, .white_bishop, &.{ .c1, .f1 });
    setPieceSquares(&ps, .white_rook, &.{ .a1, .h1 });
    setPieceSquares(&ps, .white_queen, &.{.d1});
    setPieceSquares(&ps, .white_king, &.{.e1});

    setPieceSquares(&ps, .black_pawn, &.{ .a7, .b7, .c7, .d7, .e7, .f7, .g7, .h7 });
    setPieceSquares(&ps, .black_knight, &.{ .b8, .g8 });
    setPieceSquares(&ps, .black_bishop, &.{ .c8, .f8 });
    setPieceSquares(&ps, .black_rook, &.{ .a8, .h8 });
    setPieceSquares(&ps, .black_queen, &.{.d8});
    setPieceSquares(&ps, .black_king, &.{.e8});

    return ps;
}

fn setPieceSquares(ps: *PieceSquares, piece: Piece, squares: []const Square) void {
    ps[piece.toU4()] = squares;
}

test "piece squares white pawns" {
    try testing.expectEqualSlices(
        Square,
        &.{ .a2, .b2, .c2, .d2, .e2, .f2, .g2, .h2 },
        piece_squares[Piece.white_pawn.toU4()],
    );
}

test "piece squares white knights" {
    try testing.expectEqualSlices(
        Square,
        &.{ .b1, .g1 },
        piece_squares[Piece.white_knight.toU4()],
    );
}

test "piece squares white bishops" {
    try testing.expectEqualSlices(
        Square,
        &.{ .c1, .f1 },
        piece_squares[Piece.white_bishop.toU4()],
    );
}

test "piece squares white rooks" {
    try testing.expectEqualSlices(
        Square,
        &.{ .a1, .h1 },
        piece_squares[Piece.white_rook.toU4()],
    );
}

test "piece squares white queens" {
    try testing.expectEqualSlices(
        Square,
        &.{.d1},
        piece_squares[Piece.white_queen.toU4()],
    );
}

test "piece squares white kings" {
    try testing.expectEqualSlices(
        Square,
        &.{.e1},
        piece_squares[Piece.white_king.toU4()],
    );
}

test "piece squares black pawns" {
    try testing.expectEqualSlices(
        Square,
        &.{ .a7, .b7, .c7, .d7, .e7, .f7, .g7, .h7 },
        piece_squares[Piece.black_pawn.toU4()],
    );
}

test "piece squares black knights" {
    try testing.expectEqualSlices(
        Square,
        &.{ .b8, .g8 },
        piece_squares[Piece.black_knight.toU4()],
    );
}

test "piece squares black bishops" {
    try testing.expectEqualSlices(
        Square,
        &.{ .c8, .f8 },
        piece_squares[Piece.black_bishop.toU4()],
    );
}

test "piece squares black rooks" {
    try testing.expectEqualSlices(
        Square,
        &.{ .a8, .h8 },
        piece_squares[Piece.black_rook.toU4()],
    );
}

test "piece squares black queens" {
    try testing.expectEqualSlices(
        Square,
        &.{.d8},
        piece_squares[Piece.black_queen.toU4()],
    );
}

test "piece squares black kings" {
    try testing.expectEqualSlices(
        Square,
        &.{.e8},
        piece_squares[Piece.black_king.toU4()],
    );
}
