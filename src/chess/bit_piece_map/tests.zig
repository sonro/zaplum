const std = @import("std");
const testing = std.testing;

const chess = @import("../../chess.zig");
const BitBoard = chess.BitBoard;
const Color = chess.Color;
const Piece = chess.Piece;
const Side = chess.Side;
const Square = chess.Square;

pub fn TestImpl(comptime Impl: type) type {
    return struct {
        test "empty" {
            for (Piece.hard_values) |piece| {
                try testing.expect(Impl.empty.get(piece).isEmpty());
            }
        }

        test "starting" {
            for (chess.starting.piece_squares, 0..) |squares, pce| {
                try testMapPiece(Impl.starting, @enumFromInt(pce), squares);
            }
        }

        test "set board" {
            var map = Impl.empty;
            const bishop_board = BitBoard.from(0b00100000);
            map.setBoard(Piece.white_bishop, bishop_board);
            try testing.expectEqual(@as(usize, 1), map.count(Piece.white_bishop));
            try testing.expectEqual(bishop_board, map.get(Piece.white_bishop));
            try testing.expectEqual(bishop_board, map.getAll());
        }

        test "set square" {
            var map = Impl.empty;
            try testing.expect(!map.get(.black_king).isSet(.e4));
            map.setSquare(.black_king, .e4);
            try testSetUnions(map, .black_king, .e4);
        }

        test "set square value true" {
            var map = Impl.empty;
            try testing.expect(!map.get(.black_pawn).isSet(.e7));
            map.setSquareValue(.black_pawn, .e7, true);
            try testSetUnions(map, .black_pawn, .e7);
        }

        test "set square value false" {
            var map = Impl.starting;
            try testing.expect(map.get(.black_pawn).isSet(.e7));
            map.setSquareValue(.black_pawn, .e7, false);
            try testUnsetUnions(map, .black_pawn, .e7);
        }

        test "unset square" {
            var map = Impl.starting;
            try testing.expect(map.get(.black_pawn).isSet(.b7));
            map.unsetSquare(.black_pawn, .b7);
            try testUnsetUnions(map, .black_pawn, .b7);
        }

        test "get does not mutate" {
            var map = Impl.empty;
            var board = map.get(.black_king);
            board.set(.e4);
            try testing.expect(!map.get(.black_king).isSet(.e4));
        }

        test "get mut" {
            var map = Impl.empty;
            map.getMut(.black_queen).set(.e4);
            try testing.expect(map.get(.black_queen).isSet(.e4));
        }

        test "starting color white" {
            const board = Impl.starting.getColor(.white);
            try testing.expectEqual(@as(usize, 16), board.count());
            try testing.expectEqual(BitBoard.from(0xffff), board);
        }

        test "starting color black" {
            const board = Impl.starting.getColor(.black);
            try testing.expectEqual(@as(usize, 16), board.count());
            try testing.expectEqual(BitBoard.from(0xffff << 48), board);
        }

        test "starting color and side are equal" {
            var board = Impl.starting.getColor(.white);
            var side = Impl.starting.getSide(.white);
            try testing.expectEqual(board, side);

            board = Impl.starting.getColor(.black);
            side = Impl.starting.getSide(.black);
            try testing.expectEqual(board, side);
        }

        test "starting get side both" {
            const board = Impl.starting.getSide(.both);
            try testing.expectEqual(@as(usize, 32), board.count());
            var expected = Impl.starting.getColor(.white);
            expected.setUnion(Impl.starting.getColor(.black));
            try testing.expectEqual(expected, board);
        }

        test "starting get side none" {
            const board = Impl.starting.getSide(.none);
            try testing.expectEqual(@as(usize, 0), board.count());
            try testing.expect(board.isEmpty());
        }

        test "starting get all equal get side both" {
            const board = Impl.starting.getAll();
            const side = Impl.starting.getSide(.both);
            try testing.expectEqual(board, side);
        }

        test "starting get kind pawns" {
            try testStartingPieceKind(
                Piece.Kind.pawn,
                &.{ .a2, .b2, .c2, .d2, .e2, .f2, .g2, .h2, .a7, .b7, .c7, .d7, .e7, .f7, .g7, .h7 },
            );
        }

        test "starting get kind knights" {
            try testStartingPieceKind(Piece.Kind.knight, &.{ .b1, .g1, .b8, .g8 });
        }

        test "starting get kind bishops" {
            try testStartingPieceKind(Piece.Kind.bishop, &.{ .c1, .f1, .c8, .f8 });
        }

        test "starting get kind rooks" {
            try testStartingPieceKind(Piece.Kind.rook, &.{ .a1, .h1, .a8, .h8 });
        }

        test "starting get kind queens" {
            try testStartingPieceKind(Piece.Kind.queen, &.{ .d1, .d8 });
        }

        test "starting get kind kings" {
            try testStartingPieceKind(Piece.Kind.king, &.{ .e1, .e8 });
        }

        test "updated board extras" {
            var map = Impl.empty;
            map.setBoard(Piece.white_bishop, BitBoard.from(0b00100000));
            map.setBoard(Piece.black_bishop, BitBoard.from(0b00010000));
            map.setBoard(Piece.black_knight, BitBoard.from(0b00001000));
            try testing.expectEqual(0b00111000, map.getAll().mask);
            try testing.expectEqual(3, map.getAll().count());
            try testing.expectEqual(3, map.getSide(.both).count());
            try testing.expectEqual(2, map.getKind(.bishop).count());
            try testing.expectEqual(0b00110000, map.getKind(.bishop).mask);
            try testing.expectEqual(2, map.getSide(.black).count());
            try testing.expectEqual(2, map.getColor(.black).count());
            try testing.expectEqual(0b00011000, map.getColor(.black).mask);
            try testing.expectEqual(1, map.getColor(.white).count());
        }

        fn testStartingPieceKind(kind: Piece.Kind, expected_squares: []const Square) !void {
            var expected = BitBoard.empty;
            for (expected_squares) |square| expected.set(square);
            const actual = Impl.starting.getKind(kind);
            try testing.expectEqual(expected, actual);
        }

        fn testMapPiece(map: Impl, piece: Piece, expected_squares: []const Square) !void {
            var expected = BitBoard.empty;
            for (expected_squares) |square| expected.set(square);
            const actual = map.get(piece);
            testing.expectEqual(expected, actual) catch |err| {
                std.debug.print("Piece: {s}\n", .{@tagName(piece)});
                return err;
            };
        }

        fn testSetUnions(map: Impl, piece: Piece, square: Square) !void {
            const board = map.get(piece);
            try testing.expect(board.isSet(square));
            try testing.expect(map.getAll().isSet(square));
            try testing.expect(map.getKind(piece.kind()).isSet(square));
            const color = try Color.fromSide(piece.side());
            try testing.expect(map.getColor(color).isSet(square));
            try testing.expect(map.getSide(piece.side()).isSet(square));
        }

        fn testUnsetUnions(map: Impl, piece: Piece, square: Square) !void {
            const board = map.get(piece);
            try testing.expect(!board.isSet(square));
            try testing.expect(!map.getAll().isSet(square));
            try testing.expect(!map.getKind(piece.kind()).isSet(square));
            const color = try Color.fromSide(piece.side());
            try testing.expect(!map.getColor(color).isSet(square));
            try testing.expect(!map.getSide(piece.side()).isSet(square));
        }
    };
}
