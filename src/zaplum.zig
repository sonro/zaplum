pub const chess = @import("chess.zig");

const root = @import("root");

pub const options: Options = if (@hasDecl(root, "zaplum_options")) root.zaplum_options else .{};

pub const Options = struct {
    bit_board_impl: chess.BitBoard.Impl = chess.BitBoard.default_impl,
    piece_impl: chess.Piece.Impl = chess.Piece.default_impl,
};
