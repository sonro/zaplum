const std = @import("std");
const zaplum = @import("zaplum.zig");

pub const std_options = .{
    .log_level = .debug,
};

pub const zaplum_options = zaplum.Options{
    .bit_board_impl = .lookup,
    .piece_impl = .lookup,
    .piece_map_impl = .lookup,
};

pub fn main() !void {
    // print bitboard

    var board = zaplum.chess.BitBoard.empty;
    board.setRangeValue(.{ .start = 0, .end = 16 }, true);
    std.debug.print("{s}\n", .{board});

    // print placement

    const placement = zaplum.chess.Placement.starting;
    std.debug.print("{s}\n", .{placement});

    // print piece list

    const piece_list = zaplum.chess.PieceList.starting;
    std.debug.print("{s}\n", .{piece_list});
    piece_list.assertValid();

    // print piece map

    const piece_map = zaplum.chess.PieceMap.starting;
    std.debug.print("{s}\n", .{piece_map});
    std.debug.print("piece map size: {}\n", .{@sizeOf(zaplum.chess.PieceMap)});
    piece_map.assertValid();

    // print bit piece map and extra
    const bpm = zaplum.chess.BitPieceMap.starting.extend();
    std.debug.print("{s}", .{bpm});
    bpm.assertValid();
}
