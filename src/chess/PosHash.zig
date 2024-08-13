const PosHash = @This();

const std = @import("std");
const testing = std.testing;
const assert = std.debug.assert;

const chess = @import("../chess.zig");
const Piece = chess.Piece;
const Square = chess.Square;

key: HashInt,

pub const seed = initSeed();

pub const HashInt = u64;

const HashKeys = struct {
    default: HashInt,
    side: HashInt,
    castle_map: [16]HashInt,
    en_passant: [chess.board_size]HashInt,
    piece_map: [Piece.hard_count][chess.board_size]HashInt,
};

pub fn init() PosHash {
    return PosHash{ .key = hash_keys.default };
}

pub fn setPieceSquare(self: *PosHash, piece: Piece, square: Square) void {
    self.* = self.withPieceSquare(piece, square);
}

pub fn setSide(self: *PosHash) void {
    self.* = self.withSide();
}

pub fn setCastleMap(self: *PosHash, castle_state: anytype) void {
    self.* = self.withCastleMap(castle_state);
}

pub fn setEnPassantSquare(self: *PosHash, ep_square: Square) void {
    self.* = self.withEnPassantSquare(ep_square);
}

pub fn withPieceSquare(self: PosHash, piece: Piece, square: Square) PosHash {
    assert(piece != .none);
    assert(square != .none);
    const key = self.key ^ hash_keys.piece_map[piece.toU4()][square.toIndex()];
    return .{ .key = key };
}

pub fn withSide(self: PosHash) PosHash {
    const key = self.key ^ hash_keys.side;
    return .{ .key = key };
}

pub fn withCastleMap(self: PosHash, castle_state: anytype) PosHash {
    const T = @TypeOf(castle_state);
    if (T != chess.CastleState and T != chess.CastleStatePacked and T != u4) {
        @compileError("Expected `chess.CastleState` or `chess.CastleStatePacked` or `u4`");
    }
    const val = if (T == u4) castle_state else castle_state.toU4();
    const key = self.key ^ hash_keys.castle_map[val];
    return .{ .key = key };
}

pub fn withEnPassantSquare(self: PosHash, ep_square: Square) PosHash {
    assert(ep_square != .none);
    const key = self.key ^ hash_keys.en_passant[ep_square.toIndex()];
    return .{ .key = key };
}

pub fn eql(self: PosHash, other: PosHash) bool {
    return self.key == other.key;
}

const hash_keys = initHashKeys();

fn initSeed() u64 {
    var s: u64 = undefined;
    const chars = "zaplum";
    for (chars, 0..) |c, i| {
        s |= @as(u64, c) << (i * 8);
    }
    return s;
}

fn initHashKeys() HashKeys {
    var prng = std.Random.Xoshiro256.init(seed);
    const rand = prng.random();

    var keys: HashKeys = undefined;

    keys.default = rand.int(HashInt);
    keys.side = rand.int(HashInt);

    for (&keys.castle_map) |*key| {
        key.* = rand.int(HashInt);
    }

    @setEvalBranchQuota(22000);
    for (&keys.en_passant) |*key| {
        key.* = rand.int(HashInt);
    }

    for (&keys.piece_map) |*piece_map| {
        for (piece_map) |*key| {
            key.* = rand.int(HashInt);
        }
    }

    return keys;
}

test "init" {
    const hash = PosHash.init();
    try testing.expectEqual(hash_keys.default, hash.key);
}

test "set side" {
    const original = PosHash.init();
    var actual = PosHash.init();
    actual.setSide();
    const expected = PosHash{ .key = hash_keys.side ^ hash_keys.default };
    try testing.expectEqual(expected, actual);
    actual.setSide();
    try testing.expectEqual(original, actual);
}

test "set castle map" {
    const original = PosHash.init();
    var actual = PosHash.init();
    const castle_state = chess.CastleStatePacked.fromU4(0b1111);
    actual.setCastleMap(castle_state);
    actual.setCastleMap(castle_state);
    try testing.expectEqual(original, actual);
}

test "set en passant" {
    const original = PosHash.init();
    var actual = PosHash.init();
    actual.setEnPassantSquare(.c1);
    const expected = PosHash{ .key = hash_keys.en_passant[2] ^ hash_keys.default };
    try testing.expectEqual(expected, actual);
    actual.setEnPassantSquare(.c1);
    try testing.expectEqual(original, actual);
}

test "set piece square" {
    const original = PosHash.init();
    var actual = PosHash.init();
    actual.setPieceSquare(.white_pawn, .a1);
    try testing.expect(!original.eql(actual));
    actual.setPieceSquare(.white_pawn, .a1);
    try testing.expectEqual(original, actual);
}

test "with piece square" {
    const original = PosHash.init();
    var actual = original.withPieceSquare(.white_pawn, .a1);
    try testing.expect(!original.eql(actual));
    actual = actual.withPieceSquare(.white_pawn, .a1);
    try testing.expectEqual(original, actual);
}

test "with side" {
    const original = PosHash.init();
    var actual = original.withSide();
    try testing.expect(!original.eql(actual));
    actual = actual.withSide();
    try testing.expectEqual(original, actual);
}

test "with castle map" {
    const original = PosHash.init();
    const castle_state = chess.CastleState.none;
    var actual = original.withCastleMap(castle_state);
    try testing.expect(!original.eql(actual));
    actual = actual.withCastleMap(castle_state);
    try testing.expectEqual(original, actual);
}

test "with en passant" {
    const original = PosHash.init();
    var actual = original.withEnPassantSquare(.c1);
    try testing.expect(!original.eql(actual));
    actual = actual.withEnPassantSquare(.c1);
    try testing.expectEqual(original, actual);
}
