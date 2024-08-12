const PieceMap = @This();

const std = @import("std");
const builtin = @import("builtin");
const testing = std.testing;
const assert = std.debug.assert;

const zaplum = @import("../zaplum.zig");
const chess = zaplum.chess;
const Piece = chess.Piece;
const Square = chess.Square;
const IndexInt = chess.IndexInt;

const LookupImpl = @import("piece_map/LookupImpl.zig");
const DirectImpl = @import("piece_map/DirectImpl.zig");

/// Underlying array, do not access directly
/// Use the `set` and `get` methods
data: MapImpl,

/// Implementation of the underlying array
pub const Impl = enum {
    /// Uses a lookup table for a lower memory footprint
    lookup,

    /// Directly maps from `[piece][index]` to `[square]`
    /// Uses more memory than lookup
    direct,
};

pub const default_impl = Impl.lookup;

pub const empty = initEmpty();
pub const starting = initStarting();

const MapImpl = switch (zaplum.options.piece_map_impl) {
    .lookup => LookupImpl,
    .direct => DirectImpl,
};

/// In debug mode, assert no two pieces occupy the same square
pub fn assertValid(self: *const PieceMap) void {
    if (builtin.mode != .Debug) return;
    var seen: [chess.board_size]bool = .{false} ** chess.board_size;
    for (Piece.hard_values) |piece| {
        const sli = self.slice(piece);
        for (sli) |square| {
            if (square == .none) continue;
            assert(!seen[@intFromEnum(square)]); // more than one piece on square
            seen[@intFromEnum(square)] = true;
        }
    }
}

pub fn set(self: *PieceMap, piece: Piece, index: IndexInt, square: Square) void {
    self.data.set(piece, index, square);
}

pub fn get(self: *const PieceMap, piece: Piece, index: IndexInt) Square {
    return self.data.get(piece, index);
}

/// Get a slice of `Square` for a given `Piece`
pub fn slice(self: *const PieceMap, piece: Piece) []const Square {
    return self.data.slice(piece);
}

/// Get a mutable slice of `Square` for a given `Piece`
pub fn sliceMut(self: *PieceMap, piece: Piece) []Square {
    return self.data.sliceMut(piece);
}

pub fn format(self: *const PieceMap, comptime _: []const u8, _: std.fmt.FormatOptions, writer: anytype) !void {
    for (Piece.hard_values) |piece| {
        const sli = self.slice(piece);
        try writer.print("{}: {s}\n", .{ piece, sli });
    }
}

fn initEmpty() PieceMap {
    return .{ .data = MapImpl.empty };
}

fn initStarting() PieceMap {
    return .{ .data = MapImpl.starting };
}
