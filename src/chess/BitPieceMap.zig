//! Board representation using a `BitBoard` per `Piece`
const BitPieceMap = @This();

const std = @import("std");
const testing = std.testing;
const assert = std.debug.assert;

const chess = @import("../chess.zig");
const Color = chess.Color;
const BitBoard = chess.BitBoard;
const IndexInt = chess.IndexInt;
const MaskInt = BitBoard.MaskInt;
const Piece = chess.Piece;
const Side = chess.Side;
const Square = chess.Square;

pub const Extended = @import("bit_piece_map/Extended.zig");
pub const Extra = @import("bit_piece_map/Extra.zig");

/// Underlying array, prefer using the `set` and `get` methods
map: BitMap,

pub const empty: BitPieceMap = initEmpty();
pub const starting: BitPieceMap = initStarting();

/// `Bitboard` per `Piece`
pub const BitMap = [capacity]BitBoard;

pub const capacity = Piece.hard_count;
const starting_bit_masks: MaskIntMap = initStartingBitMasks();

/// `MaskInt` per `Piece`
const MaskIntMap = [capacity]MaskInt;

/// Sets the `BitBoard` for a given `Piece`
pub fn setBoard(self: *BitPieceMap, piece: Piece, board: BitBoard) void {
    assert(piece != .none);
    self.map[piece.toU4()] = board;
}

/// Sets an individual `Square` for a given `Piece`
/// Does not remove any existing `Square`
pub fn setSquare(self: *BitPieceMap, piece: Piece, square: Square) void {
    assert(piece != .none);
    self.map[piece.toU4()].set(square);
}

/// Sets an individual `Square` for a given `Piece` to `value`
/// Does not remove any existing `Square`
pub fn setSquareValue(self: *BitPieceMap, piece: Piece, square: Square, value: bool) void {
    assert(piece != .none);
    self.map[piece.toU4()].setValue(square, value);
}

/// Unsets an individual `Square` for a given `Piece`
pub fn unsetSquare(self: *BitPieceMap, piece: Piece, square: Square) void {
    assert(piece != .none);
    self.map[piece.toU4()].unset(square);
}

/// Number of set `Square`s for a given `Piece`
pub fn count(self: *const BitPieceMap, piece: Piece) IndexInt {
    assert(piece != .none);
    return self.map[piece.toU4()].count();
}

/// `BitBoard` for a `Piece`
pub fn get(self: *const BitPieceMap, piece: Piece) BitBoard {
    assert(piece != .none);
    return self.map[piece.toU4()];
}

/// Mutable reference to the `BitBoard` for a `Piece`
pub fn getMut(self: *BitPieceMap, piece: Piece) *BitBoard {
    assert(piece != .none);
    return &self.map[piece.toU4()];
}

/// `BitBoard` union of all `Piece.Kind` on the board
pub fn getKind(self: *const BitPieceMap, piece_kind: Piece.Kind) BitBoard {
    assert(piece_kind != .none);
    const white_piece = Piece.color_values[0][piece_kind.toU3()];
    const black_piece = Piece.color_values[1][piece_kind.toU3()];
    const white_board = self.map[white_piece.toU4()];
    const black_board = self.map[black_piece.toU4()];
    return white_board.unionWith(black_board);
}

/// `BitBoard` union of all `Color` on the board
pub fn getColor(self: *const BitPieceMap, color: Color) BitBoard {
    var bb = BitBoard.empty;
    for (Piece.color_values[color.toU1()]) |piece| {
        bb.setUnion(self.get(piece));
    }
    return bb;
}

/// `BitBoard` union of all `Side` on the board
///
/// `Side.none` returns an empty board
/// `Side.both` same as `getAll`
pub fn getSide(self: *const BitPieceMap, side: Side) BitBoard {
    var bb = BitBoard.empty;
    for (Piece.side_values[side.toU2()]) |piece| {
        bb.setUnion(self.get(piece));
    }
    return bb;
}

/// `BitBoard` union of all `Piece`s on the board
pub fn getAll(self: *const BitPieceMap) BitBoard {
    var bb = BitBoard.empty;
    for (self.map) |board| {
        bb.setUnion(board);
    }
    return bb;
}

/// Union data for this `BitPieceMap`
pub fn extra(self: *const BitPieceMap) Extra {
    return Extra.init(self);
}

///  Add `Extra` union data to this `BitPieceMap`
pub fn extend(self: *BitPieceMap) Extended {
    return Extended.init(self);
}

fn initEmpty() BitPieceMap {
    const bm: BitMap = [1]BitBoard{BitBoard.empty} ** capacity;
    return BitPieceMap{ .map = bm };
}

fn initStarting() BitPieceMap {
    var bm: BitMap = undefined;
    for (0..capacity) |pce| {
        bm[pce] = BitBoard.from(starting_bit_masks[pce]);
    }
    return BitPieceMap{ .map = bm };
}

fn initStartingBitMasks() MaskIntMap {
    var map: MaskIntMap = undefined;
    // zig fmt: off
    map[Piece.white_pawn.toU4()]   = 0b11111111_00000000;
    map[Piece.white_knight.toU4()] = 0b00000000_01000010;
    map[Piece.white_bishop.toU4()] = 0b00000000_00100100;
    map[Piece.white_rook.toU4()]   = 0b00000000_10000001;
    // should look reversed
    map[Piece.white_queen.toU4()]  = 0b00000000_00001000;
    map[Piece.white_king.toU4()]   = 0b00000000_00010000;

    map[Piece.black_pawn.toU4()]   = 0b00000000_11111111 << 48;
    map[Piece.black_knight.toU4()] = 0b01000010_00000000 << 48;
    map[Piece.black_bishop.toU4()] = 0b00100100_00000000 << 48;
    map[Piece.black_rook.toU4()]   = 0b10000001_00000000 << 48;
    // should look reversed
    map[Piece.black_queen.toU4()]  = 0b00001000_00000000 << 48;
    map[Piece.black_king.toU4()]   = 0b00010000_00000000 << 48;
    // zig fmt: on
    return map;
}

comptime {
    const tests = @import("bit_piece_map/tests.zig");
    _ = tests.TestImpl(BitPieceMap);
}
