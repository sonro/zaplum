const Self = @This();

const std = @import("std");

const chess = @import("../../chess.zig");
const Side = chess.Side;
const Piece = chess.Piece;
const Kind = Piece.Kind;

const side_lut = Lut(Side, ConditionImpl.side);
const kind_lut = Lut(Kind, ConditionImpl.kind);
const human_value_lut = Lut(i8, ConditionImpl.humanValue);
const big_lut = Lut(bool, ConditionImpl.isBig);
const major_lut = Lut(bool, ConditionImpl.isMajor);
const minor_lut = Lut(bool, ConditionImpl.isMinor);
const slider_lut = Lut(bool, ConditionImpl.isSlider);
const diagonal_slider_lut = Lut(bool, ConditionImpl.isDiagonalSlider);
const orthogonal_slider_lut = Lut(bool, ConditionImpl.isOrthogonalSlider);
const char_lut = Lut(u8, ConditionImpl.char);

const ConditionImpl = @import("ConditionImpl.zig");

pub fn side(self: Piece) Side {
    return side_lut[self.toU4()];
}

pub fn kind(self: Piece) Kind {
    return kind_lut[self.toU4()];
}

pub fn humanValue(self: Piece) i8 {
    return human_value_lut[self.toU4()];
}

pub fn isBig(self: Piece) bool {
    return big_lut[self.toU4()];
}

pub fn isMajor(self: Piece) bool {
    return major_lut[self.toU4()];
}

pub fn isMinor(self: Piece) bool {
    return minor_lut[self.toU4()];
}

pub fn isSlider(self: Piece) bool {
    return slider_lut[self.toU4()];
}

pub fn isDiagonalSlider(self: Piece) bool {
    return diagonal_slider_lut[self.toU4()];
}

pub fn isOrthogonalSlider(self: Piece) bool {
    return orthogonal_slider_lut[self.toU4()];
}

pub fn char(self: Piece) u8 {
    return char_lut[self.toU4()];
}

fn Lut(comptime T: type, comptime function: fn (Piece) T) [Piece.count]T {
    var result: [Piece.count]T = undefined;
    for (0..Piece.count) |i| {
        result[i] = function(@enumFromInt(i));
    }
    return result;
}

comptime {
    const tests = @import("tests.zig");
    _ = tests.testImpl(Self);
}
