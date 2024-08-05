pub const bit_board = @import("bit_board.zig");
pub const chess = @import("chess.zig");
pub const BitBoard = bit_board.BitBoard;

const root = @import("root");

pub const options: Options = if (@hasDecl(root, "zaplum_options")) root.zaplum_options else .{};

pub const Options = struct {
    bit_board_impl: BitBoard.Impl = BitBoard.default_impl,
};
