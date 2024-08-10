const std = @import("std");
const testing = std.testing;

const chess = @import("../../chess.zig");
const Side = chess.Side;
const Piece = chess.Piece;

pub fn TestImpl(comptime Impl: type) type {
    return struct {
        test "white pieces side" {
            const pieces = [6]Piece{
                Piece.white_pawn,
                Piece.white_knight,
                Piece.white_bishop,
                Piece.white_rook,
                Piece.white_queen,
                Piece.white_king,
            };

            for (pieces) |piece| {
                try testing.expectEqual(Side.white, Impl.side(piece));
            }
        }

        test "black pieces side" {
            const pieces = [6]Piece{
                Piece.black_pawn,
                Piece.black_knight,
                Piece.black_bishop,
                Piece.black_rook,
                Piece.black_queen,
                Piece.black_king,
            };

            for (pieces) |piece| {
                try testing.expectEqual(Side.black, Impl.side(piece));
            }
        }

        test "pawns kind" {
            try testKind(.pawn, .white_pawn);
            try testKind(.pawn, .black_pawn);
        }

        test "knight kind" {
            try testKind(.knight, .white_knight);
            try testKind(.knight, .black_knight);
        }

        test "bishop kind" {
            try testKind(.bishop, .white_bishop);
            try testKind(.bishop, .black_bishop);
        }

        test "rook kind" {
            try testKind(.rook, .white_rook);
            try testKind(.rook, .black_rook);
        }

        test "queen kind" {
            try testKind(.queen, .white_queen);
            try testKind(.queen, .black_queen);
        }

        test "king kind" {
            try testKind(.king, .white_king);
            try testKind(.king, .black_king);
        }

        test "human value" {
            try testHumanValue(0, .none);
            try testHumanValue(1, .white_pawn);
            try testHumanValue(3, .white_knight);
            try testHumanValue(3, .white_bishop);
            try testHumanValue(5, .white_rook);
            try testHumanValue(9, .white_queen);
            try testHumanValue(50, .white_king);
            try testHumanValue(-1, .black_pawn);
            try testHumanValue(-3, .black_knight);
            try testHumanValue(-3, .black_bishop);
            try testHumanValue(-5, .black_rook);
            try testHumanValue(-9, .black_queen);
            try testHumanValue(-50, .black_king);
        }

        test "is big" {
            try testIsNotBig(.none);
            try testIsNotBig(.white_pawn);
            try testIsNotBig(.black_pawn);

            try testIsBig(.white_knight);
            try testIsBig(.white_bishop);
            try testIsBig(.white_rook);
            try testIsBig(.white_queen);
            try testIsBig(.white_king);
            try testIsBig(.black_knight);
            try testIsBig(.black_bishop);
            try testIsBig(.black_rook);
            try testIsBig(.black_queen);
            try testIsBig(.black_king);
        }

        test "is minor" {
            try testIsNotMinor(.none);
            try testIsNotMinor(.white_pawn);
            try testIsNotMinor(.white_rook);
            try testIsNotMinor(.white_queen);
            try testIsNotMinor(.white_king);
            try testIsNotMinor(.black_pawn);
            try testIsNotMinor(.black_rook);
            try testIsNotMinor(.black_queen);
            try testIsNotMinor(.black_king);

            try testIsMinor(.white_knight);
            try testIsMinor(.white_bishop);
            try testIsMinor(.black_knight);
            try testIsMinor(.black_bishop);
        }

        test "is major" {
            try testIsNotMajor(.none);
            try testIsNotMajor(.white_pawn);
            try testIsNotMajor(.white_knight);
            try testIsNotMajor(.white_bishop);
            try testIsNotMajor(.black_pawn);
            try testIsNotMajor(.black_knight);
            try testIsNotMajor(.black_bishop);

            try testIsMajor(.white_rook);
            try testIsMajor(.white_queen);
            try testIsMajor(.white_king);
            try testIsMajor(.black_rook);
            try testIsMajor(.black_queen);
            try testIsMajor(.black_king);
        }

        test "is slider" {
            try testIsNotSlider(.none);
            try testIsNotSlider(.white_pawn);
            try testIsNotSlider(.white_knight);
            try testIsNotSlider(.white_king);
            try testIsNotSlider(.black_pawn);
            try testIsNotSlider(.black_knight);
            try testIsNotSlider(.black_king);

            try testIsSlider(.white_bishop);
            try testIsSlider(.white_rook);
            try testIsSlider(.white_queen);
            try testIsSlider(.black_bishop);
            try testIsSlider(.black_rook);
            try testIsSlider(.black_queen);
        }

        test "is diagonal slider" {
            try testIsNotDiagonalSlider(.none);
            try testIsNotDiagonalSlider(.white_pawn);
            try testIsNotDiagonalSlider(.white_knight);
            try testIsNotDiagonalSlider(.black_rook);
            try testIsNotDiagonalSlider(.white_king);
            try testIsNotDiagonalSlider(.black_pawn);
            try testIsNotDiagonalSlider(.black_knight);
            try testIsNotDiagonalSlider(.black_rook);
            try testIsNotDiagonalSlider(.black_king);

            try testIsDiagonalSlider(.white_bishop);
            try testIsDiagonalSlider(.white_queen);
            try testIsDiagonalSlider(.black_bishop);
            try testIsDiagonalSlider(.black_queen);
        }

        test "is orthogonal slider" {
            try testIsNotOrthogonalSlider(.none);
            try testIsNotOrthogonalSlider(.white_pawn);
            try testIsNotOrthogonalSlider(.white_knight);
            try testIsNotOrthogonalSlider(.black_bishop);
            try testIsNotOrthogonalSlider(.white_king);
            try testIsNotOrthogonalSlider(.black_pawn);
            try testIsNotOrthogonalSlider(.black_knight);
            try testIsNotOrthogonalSlider(.black_bishop);
            try testIsNotOrthogonalSlider(.black_king);

            try testIsOrthogonalSlider(.white_rook);
            try testIsOrthogonalSlider(.white_queen);
            try testIsOrthogonalSlider(.black_rook);
            try testIsOrthogonalSlider(.black_queen);
        }

        test "get char" {
            try testChar('-', .none);
            try testChar('P', .white_pawn);
            try testChar('N', .white_knight);
            try testChar('B', .white_bishop);
            try testChar('R', .white_rook);
            try testChar('Q', .white_queen);
            try testChar('K', .white_king);
            try testChar('p', .black_pawn);
            try testChar('n', .black_knight);
            try testChar('b', .black_bishop);
            try testChar('r', .black_rook);
            try testChar('q', .black_queen);
            try testChar('k', .black_king);
        }

        fn testKind(expected: Piece.Kind, piece: Piece) !void {
            try testing.expectEqual(expected, Impl.kind(piece));
        }

        fn testHumanValue(expected: i8, piece: Piece) !void {
            try testing.expectEqual(expected, Impl.humanValue(piece));
        }

        fn testIsBig(piece: Piece) !void {
            try testing.expect(Impl.isBig(piece));
        }

        fn testIsNotBig(piece: Piece) !void {
            try testing.expect(!Impl.isBig(piece));
        }

        fn testIsMinor(piece: Piece) !void {
            try testing.expect(Impl.isMinor(piece));
        }

        fn testIsNotMinor(piece: Piece) !void {
            try testing.expect(!Impl.isMinor(piece));
        }

        fn testIsMajor(piece: Piece) !void {
            try testing.expect(Impl.isMajor(piece));
        }

        fn testIsNotMajor(piece: Piece) !void {
            try testing.expect(!Impl.isMajor(piece));
        }

        fn testIsSlider(piece: Piece) !void {
            try testing.expect(Impl.isSlider(piece));
        }

        fn testIsNotSlider(piece: Piece) !void {
            try testing.expect(!Impl.isSlider(piece));
        }

        fn testIsDiagonalSlider(piece: Piece) !void {
            try testing.expect(Impl.isDiagonalSlider(piece));
        }

        fn testIsNotDiagonalSlider(piece: Piece) !void {
            try testing.expect(!Impl.isDiagonalSlider(piece));
        }

        fn testIsOrthogonalSlider(piece: Piece) !void {
            try testing.expect(Impl.isOrthogonalSlider(piece));
        }

        fn testIsNotOrthogonalSlider(piece: Piece) !void {
            try testing.expect(!Impl.isOrthogonalSlider(piece));
        }

        fn testChar(expected: u8, piece: Piece) !void {
            try testing.expectEqual(expected, Impl.char(piece));
        }
    };
}
