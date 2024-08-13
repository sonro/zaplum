//! Union data for `BitPieceMap`
const Extra = @This();

const std = @import("std");
const testing = std.testing;
const assert = std.debug.assert;

const chess = @import("../../chess.zig");
const BitPieceMap = chess.BitPieceMap;
const BitBoard = chess.BitBoard;
const Color = chess.Color;
const Piece = chess.Piece;
const Square = chess.Square;

/// `BitBoard` union per `Color`
color: [2]BitBoard,
/// `BitBoard` union per `Piece.Kind`
kind: [Piece.Kind.hard_count]BitBoard,
/// `BitBoard` union of all `Piece`s
all: BitBoard,

/// `Extra` from a `BitPieceMap`
pub fn init(map: *const BitPieceMap) Extra {
    var self: Extra = undefined;
    self.color[Color.white.toU1()] = map.getColor(.white);
    self.color[Color.black.toU1()] = map.getColor(.black);
    self.kind[Piece.Kind.pawn.toU3()] = map.getKind(Piece.Kind.pawn);
    self.kind[Piece.Kind.knight.toU3()] = map.getKind(Piece.Kind.knight);
    self.kind[Piece.Kind.bishop.toU3()] = map.getKind(Piece.Kind.bishop);
    self.kind[Piece.Kind.rook.toU3()] = map.getKind(Piece.Kind.rook);
    self.kind[Piece.Kind.queen.toU3()] = map.getKind(Piece.Kind.queen);
    self.kind[Piece.Kind.king.toU3()] = map.getKind(Piece.Kind.king);
    self.all = self.color[0].unionWith(self.color[1]);
    return self;
}

/// Update this `Extra` from a `BitPieceMap`
///
/// Call this to keep `Extra` in sync with `BitPieceMap` changes
pub fn update(self: *Extra, map: *const BitPieceMap, piece: Piece) void {
    assert(piece != .none);
    const side = piece.side();
    const kind = piece.kind();
    self.color[side.toU2()] = map.getSide(side);
    self.kind[kind.toU3()] = map.getKind(kind);
    self.all = self.color[0].unionWith(self.color[1]);
}

pub fn format(self: *const Extra, comptime _: []const u8, _: std.fmt.FormatOptions, writer: anytype) !void {
    const colors: []const BitBoardInfo = &.{
        .{ .bb = self.color[Color.white.toU1()], .name = "WHITE" },
        .{ .bb = self.color[Color.black.toU1()], .name = "BLACK" },
        .{ .bb = self.all, .name = "BOTH" },
    };
    try printBitBoardCollection(colors, writer);

    var kinds: []const BitBoardInfo = &.{
        .{ .bb = self.kind[Piece.Kind.pawn.toU3()], .name = "PAWNS" },
        .{ .bb = self.kind[Piece.Kind.knight.toU3()], .name = "KNIGHTS" },
        .{ .bb = self.kind[Piece.Kind.bishop.toU3()], .name = "BISHOPS" },
    };
    try printBitBoardCollection(kinds, writer);
    kinds = &.{
        .{ .bb = self.kind[Piece.Kind.rook.toU3()], .name = "ROOKS" },
        .{ .bb = self.kind[Piece.Kind.queen.toU3()], .name = "QUEENS" },
        .{ .bb = self.kind[Piece.Kind.king.toU3()], .name = "KINGS" },
    };
    try printBitBoardCollection(kinds, writer);
}

const BitBoardInfo = struct {
    bb: BitBoard,
    name: []const u8,
};

fn printBitBoardCollection(boards: []const BitBoardInfo, writer: anytype) !void {
    // titles
    try writer.writeByte('\n');
    for (boards) |info| try writer.print(" {s: ^16}", .{info.name});
    try writer.writeByte('\n');

    // boards
    var rank: usize = 8;
    while (rank > 0) {
        rank -= 1;
        for (boards) |info| try printBitBoardRank(info.bb, rank, writer);
        try writer.writeByte('\n');
    }
}

fn printBitBoardRank(bb: BitBoard, rank: usize, writer: anytype) !void {
    const imod = rank * 8;
    for (0..8) |file| {
        const square: Square = @enumFromInt(imod + file);
        if (bb.isSet(square)) {
            try writer.writeAll(" X");
        } else {
            try writer.writeAll(" -");
        }
    }
    try writer.writeByte(' ');
}

test "init" {
    var map = BitPieceMap.empty;
    map.setSquare(.white_pawn, .a2);
    map.setSquare(.white_knight, .b1);
    map.setSquare(.black_knight, .b8);
    map.setSquare(.black_queen, .d8);

    const extra = Extra.init(&map);
    try testing.expectEqual(extra.all, map.getAll());
    try testing.expectEqual(extra.color[Color.white.toU1()], map.getColor(.white));
    try testing.expectEqual(extra.color[Color.black.toU1()], map.getColor(.black));
    try testing.expectEqual(extra.kind[Piece.Kind.pawn.toU3()], map.getKind(.pawn));
    try testing.expectEqual(extra.kind[Piece.Kind.knight.toU3()], map.getKind(.knight));
    try testing.expectEqual(extra.kind[Piece.Kind.queen.toU3()], map.getKind(.queen));
}

test "update" {
    var map = BitPieceMap.empty;
    var extra = Extra.init(&map);
    map.setSquare(.white_pawn, .a2);

    extra.update(&map, .white_pawn);
    try testing.expectEqual(extra.all, map.getAll());
    try testing.expectEqual(extra.color[Color.white.toU1()], map.getColor(.white));
    try testing.expectEqual(extra.kind[Piece.Kind.pawn.toU3()], map.getKind(.pawn));
}

test "format" {
    // extra space after line
    const expected =
        \\
        \\      WHITE            BLACK             BOTH      
        \\ - - - - - - - -  X X X X X X X X  X X X X X X X X 
        \\ - - - - - - - -  X X X X X X X X  X X X X X X X X 
        \\ - - - - - - - -  - - - - - - - -  - - - - - - - - 
        \\ - - - - - - - -  - - - - - - - -  - - - - - - - - 
        \\ - - - - - - - -  - - - - - - - -  - - - - - - - - 
        \\ - - - - - - - -  - - - - - - - -  - - - - - - - - 
        \\ X X X X X X X X  - - - - - - - -  X X X X X X X X 
        \\ X X X X X X X X  - - - - - - - -  X X X X X X X X 
        \\
        \\      PAWNS           KNIGHTS          BISHOPS     
        \\ - - - - - - - -  - X - - - - X -  - - X - - X - - 
        \\ X X X X X X X X  - - - - - - - -  - - - - - - - - 
        \\ - - - - - - - -  - - - - - - - -  - - - - - - - - 
        \\ - - - - - - - -  - - - - - - - -  - - - - - - - - 
        \\ - - - - - - - -  - - - - - - - -  - - - - - - - - 
        \\ - - - - - - - -  - - - - - - - -  - - - - - - - - 
        \\ X X X X X X X X  - - - - - - - -  - - - - - - - - 
        \\ - - - - - - - -  - X - - - - X -  - - X - - X - - 
        \\
        \\      ROOKS            QUEENS           KINGS      
        \\ X - - - - - - X  - - - X - - - -  - - - - X - - - 
        \\ - - - - - - - -  - - - - - - - -  - - - - - - - - 
        \\ - - - - - - - -  - - - - - - - -  - - - - - - - - 
        \\ - - - - - - - -  - - - - - - - -  - - - - - - - - 
        \\ - - - - - - - -  - - - - - - - -  - - - - - - - - 
        \\ - - - - - - - -  - - - - - - - -  - - - - - - - - 
        \\ - - - - - - - -  - - - - - - - -  - - - - - - - - 
        \\ X - - - - - - X  - - - X - - - -  - - - - X - - - 
        \\
    ;
    try testing.expectFmt(expected, "{s}", .{Extra.init(&BitPieceMap.starting)});
}
