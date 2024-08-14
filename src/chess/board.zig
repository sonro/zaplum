//! Board representation convertion and manipulation

const std = @import("std");
const testing = std.testing;

const chess = @import("../chess.zig");
const BitPieceMap = chess.BitPieceMap;
const IndexInt = chess.IndexInt;
const Piece = chess.Piece;
const PieceList = chess.PieceList;
const PieceMap = chess.PieceMap;
const Placement = chess.Placement;
const PosHash = chess.PosHash;
const Square = chess.Square;
const PieceSquares = chess.starting.PieceSquares;

pub fn bitPieceMapFromPieceList(piece_list: PieceList) BitPieceMap {
    var bpm = BitPieceMap.empty;
    for (Piece.hard_values) |piece| {
        for (piece_list.slice(piece)) |square| {
            bpm.setSquare(piece, square);
        }
    }
    return bpm;
}

pub fn bitPieceMapFromPieceMap(piece_map: PieceMap) BitPieceMap {
    var bpm = BitPieceMap.empty;
    for (Piece.hard_values) |piece| {
        for (piece_map.slice(piece)) |square| {
            if (square != .none) bpm.setSquare(piece, square);
        }
    }
    return bpm;
}

pub fn bitPieceMapFromPlacement(placement: Placement) BitPieceMap {
    var bpm = BitPieceMap.empty;
    for (0..Placement.capacity) |i| {
        const square: Square = @enumFromInt(i);
        const piece = placement.get(square);
        if (piece != .none) bpm.setSquare(piece, square);
    }
    return bpm;
}

pub fn pieceListFromBitPieceMap(bpm: BitPieceMap) PieceList {
    var piece_list = PieceList.empty;
    for (Piece.hard_values) |piece| {
        var iter = bpm.get(piece).iterator(.{});
        while (iter.next()) |sqi| {
            piece_list.append(piece, @enumFromInt(sqi));
        }
    }
    return piece_list;
}

pub fn pieceListFromPieceMap(piece_map: PieceMap) PieceList {
    var piece_list = PieceList.empty;
    for (Piece.hard_values) |piece| {
        for (piece_map.slice(piece)) |square| {
            if (square != .none) piece_list.append(piece, square);
        }
    }
    return piece_list;
}

pub fn pieceListFromPlacement(placement: Placement) PieceList {
    var pl = PieceList.empty;
    for (0..Placement.capacity) |i| {
        const square: Square = @enumFromInt(i);
        const piece = placement.get(square);
        if (piece != .none) pl.append(piece, square);
    }
    return pl;
}

pub fn pieceMapFromBitPieceMap(bpm: BitPieceMap) PieceMap {
    var piece_map = PieceMap.empty;
    for (Piece.hard_values) |piece| {
        var iter = bpm.get(piece).iterator(.{});
        var i: IndexInt = 0;
        while (iter.next()) |sqi| : (i += 1) {
            piece_map.set(piece, i, @enumFromInt(sqi));
        }
    }
    return piece_map;
}

pub fn pieceMapFromPieceList(piece_list: PieceList) PieceMap {
    var piece_map = PieceMap.empty;
    for (Piece.hard_values) |piece| {
        for (piece_list.slice(piece), 0..) |square, i| {
            piece_map.set(piece, @intCast(i), square);
        }
    }
    return piece_map;
}

pub fn pieceMapFromPlacement(placement: Placement) PieceMap {
    var piece_map = PieceMap.empty;
    var counts: [Piece.hard_count]IndexInt = .{0} ** Piece.hard_count;
    for (0..Placement.capacity) |i| {
        const square: Square = @enumFromInt(i);
        const piece = placement.get(square);
        if (piece != .none) {
            const pce = piece.toU4();
            piece_map.set(piece, counts[pce], square);
            counts[pce] += 1;
        }
    }
    return piece_map;
}

pub fn placementFromBitPieceMap(bpm: BitPieceMap) Placement {
    var placement = Placement.empty;
    for (Piece.hard_values) |piece| {
        var iter = bpm.get(piece).iterator(.{});
        while (iter.next()) |sqi| {
            placement.set(@enumFromInt(sqi), piece);
        }
    }
    return placement;
}

pub fn placementFromPieceList(piece_list: PieceList) Placement {
    var placement = Placement.empty;
    for (Piece.hard_values) |piece| {
        for (piece_list.slice(piece)) |square| {
            placement.set(square, piece);
        }
    }
    return placement;
}

pub fn placementFromPieceMap(piece_map: PieceMap) Placement {
    var placement = Placement.empty;
    for (Piece.hard_values) |piece| {
        for (piece_map.slice(piece)) |square| {
            if (square != .none) placement.set(square, piece);
        }
    }
    return placement;
}

pub fn posHashFromBitPieceMap(bpm: BitPieceMap) PosHash {
    var hash = PosHash.empty;
    for (Piece.hard_values) |piece| {
        var iter = bpm.get(piece).iterator(.{});
        while (iter.next()) |sqi| {
            hash.setPieceSquare(piece, @enumFromInt(sqi));
        }
    }
    return hash;
}

pub fn posHashFromPieceList(piece_list: PieceList) PosHash {
    var hash = PosHash.empty;
    for (Piece.hard_values) |piece| {
        for (piece_list.slice(piece)) |square| {
            hash.setPieceSquare(piece, square);
        }
    }
    return hash;
}

pub fn posHashFromPieceMap(piece_map: PieceMap) PosHash {
    var hash = PosHash.empty;
    for (Piece.hard_values) |piece| {
        for (piece_map.slice(piece)) |square| {
            if (square != .none) hash.setPieceSquare(piece, square);
        }
    }
    return hash;
}

pub fn posHashFromPlacement(placement: Placement) PosHash {
    var hash = PosHash.empty;
    for (0..Placement.capacity) |i| {
        const piece = placement.get(@enumFromInt(i));
        if (piece != .none) hash.setPieceSquare(piece, @enumFromInt(i));
    }
    return hash;
}

comptime {
    _ = TestConvert(BitPieceMap, PieceList, custom_bit_piece_map, custom_piece_list, bitPieceMapFromPieceList);
    _ = TestConvert(BitPieceMap, PieceMap, custom_bit_piece_map, custom_piece_map, bitPieceMapFromPieceMap);
    _ = TestConvert(BitPieceMap, Placement, custom_bit_piece_map, custom_placement, bitPieceMapFromPlacement);

    _ = TestConvert(PieceList, BitPieceMap, custom_piece_list, custom_bit_piece_map, pieceListFromBitPieceMap);
    _ = TestConvert(PieceList, PieceMap, custom_piece_list, custom_piece_map, pieceListFromPieceMap);
    _ = TestConvert(PieceList, Placement, custom_piece_list, custom_placement, pieceListFromPlacement);

    _ = TestConvert(PieceMap, BitPieceMap, custom_piece_map, custom_bit_piece_map, pieceMapFromBitPieceMap);
    _ = TestConvert(PieceMap, PieceList, custom_piece_map, custom_piece_list, pieceMapFromPieceList);
    _ = TestConvert(PieceMap, Placement, custom_piece_map, custom_placement, pieceMapFromPlacement);

    _ = TestConvert(Placement, BitPieceMap, custom_placement, custom_bit_piece_map, placementFromBitPieceMap);
    _ = TestConvert(Placement, PieceList, custom_placement, custom_piece_list, placementFromPieceList);
    _ = TestConvert(Placement, PieceMap, custom_placement, custom_piece_map, placementFromPieceMap);

    _ = TestConvert(PosHash, BitPieceMap, custom_pos_hash, custom_bit_piece_map, posHashFromBitPieceMap);
    _ = TestConvert(PosHash, PieceList, custom_pos_hash, custom_piece_list, posHashFromPieceList);
    _ = TestConvert(PosHash, PieceMap, custom_pos_hash, custom_piece_map, posHashFromPieceMap);
    _ = TestConvert(PosHash, Placement, custom_pos_hash, custom_placement, posHashFromPlacement);
}

fn TestConvert(
    comptime To: type,
    comptime From: type,
    comptime custom_to: To,
    comptime custom_from: From,
    comptime Convertor: fn (From) To,
) type {

    // `PosHash.starting` has castling rights set, so we test it separately
    const StartTester = if (std.mem.eql(u8, @typeName(To), "chess.PosHash")) struct {
        fn testStart() !void {
            var actual: PosHash = Convertor(From.starting);
            actual.setCastleMap(chess.CastleState.all);
            try testing.expectEqual(To.starting, actual);
        }
    } else struct {
        fn testStart() !void {
            const actual = Convertor(From.starting);
            try testing.expectEqual(To.starting, actual);
        }
    };

    return struct {
        test "starting" {
            try StartTester.testStart();
        }

        test "empty" {
            const actual = Convertor(From.empty);
            try testing.expectEqual(To.empty, actual);
        }

        test "custom" {
            const actual = Convertor(custom_from);
            try testing.expectEqual(custom_to, actual);
        }
    };
}

const _custom_piece_squares = initCustomPieceSquares();
const custom_bit_piece_map = FromCustomPieceSquares(BitPieceMap, callback_bit_piece_map);
const custom_piece_list = FromCustomPieceSquares(PieceList, callback_piece_list);
const custom_piece_map = initCustomPieceMap();
const custom_placement = FromCustomPieceSquares(Placement, callback_placement);
const custom_pos_hash = FromCustomPieceSquares(PosHash, callback_pos_hash);

fn FromCustomPieceSquares(comptime T: type, comptime callback: fn (*T, Piece, Square) void) T {
    var out = T.empty;
    for (_custom_piece_squares, 0..) |squares, pce| {
        const piece: Piece = @enumFromInt(pce);
        for (squares) |square| {
            callback(&out, piece, square);
        }
    }
    return out;
}

// has to include loop state, so easier to repeat than abstract
fn initCustomPieceMap() PieceMap {
    var map = PieceMap.empty;
    for (_custom_piece_squares, 0..) |squares, pce| {
        const piece: Piece = @enumFromInt(pce);
        for (squares, 0..) |square, i| {
            map.set(piece, @intCast(i), square);
        }
    }
    return map;
}

fn initCustomPieceSquares() PieceSquares {
    var ps: PieceSquares = [_][]const Square{&.{}} ** Piece.hard_count;
    ps[Piece.white_pawn.toU4()] = &.{ .a5, .b7 };
    ps[Piece.white_knight.toU4()] = &.{.c3};
    ps[Piece.black_knight.toU4()] = &.{.b8};
    return ps;
}

fn callback_bit_piece_map(map: *BitPieceMap, piece: Piece, square: Square) void {
    map.setSquare(piece, square);
}

fn callback_piece_list(list: *PieceList, piece: Piece, square: Square) void {
    list.append(piece, square);
}

fn callback_pos_hash(hash: *PosHash, piece: Piece, square: Square) void {
    hash.setPieceSquare(piece, square);
}

fn callback_placement(placement: *Placement, piece: Piece, square: Square) void {
    placement.set(square, piece);
}
