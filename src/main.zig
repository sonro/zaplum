const std = @import("std");
const zaplum = @import("zaplum.zig");

pub const std_options = .{
    .log_level = .debug,
};

pub const zaplum_options = zaplum.Options{
    .bit_board_impl = .lookup,
};

pub fn main() !void {
    // print bitboard

    var board = zaplum.BitBoard.initEmpty();
    board.setRangeValue(.{ .start = 0, .end = 16 }, true);
    std.debug.print("{s}", .{board});
}
