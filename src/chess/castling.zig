const std = @import("std");
const testing = std.testing;

const str_lut: [16][]const u8 = initStrLut();

pub const State = struct {
    white_king: bool = false,
    white_queen: bool = false,
    black_king: bool = false,
    black_queen: bool = false,

    pub const none = None(State);
    pub const all = All(State);

    pub fn fromU4(state: u4) State {
        return StatePacked.fromU4(state).toState();
    }

    pub fn fromPacked(state: StatePacked) State {
        return ChangeType(State, state);
    }

    pub fn toU4(self: State) u4 {
        return self.toPacked().toU4();
    }

    pub fn toPacked(self: State) StatePacked {
        return ChangeType(StatePacked, self);
    }

    pub fn eql(self: State, other: State) bool {
        return self.white_king == other.white_king and
            self.white_queen == other.white_queen and
            self.black_king == other.black_king and
            self.black_queen == other.black_queen;
    }

    pub fn format(self: State, comptime _: []const u8, _: std.fmt.FormatOptions, writer: anytype) !void {
        try writer.writeAll(str_lut[self.toU4()]);
    }
};

pub const StatePacked = packed struct(u4) {
    white_king: bool = false,
    white_queen: bool = false,
    black_king: bool = false,
    black_queen: bool = false,

    pub const none = None(StatePacked);
    pub const all = All(StatePacked);

    pub fn fromU4(state: u4) StatePacked {
        return @bitCast(state);
    }

    pub fn fromState(state: State) StatePacked {
        return ChangeType(StatePacked, state);
    }

    pub fn toU4(self: StatePacked) u4 {
        return @bitCast(self);
    }

    pub fn toState(self: StatePacked) State {
        return ChangeType(State, self);
    }

    pub fn eql(self: StatePacked, other: StatePacked) bool {
        return self.toU4() == other.toU4();
    }

    pub fn format(self: StatePacked, comptime _: []const u8, _: std.fmt.FormatOptions, writer: anytype) !void {
        try writer.writeAll(str_lut[self.toU4()]);
    }
};

fn ChangeType(To: type, origin: anytype) To {
    return To{
        .white_king = origin.white_king,
        .white_queen = origin.white_queen,
        .black_king = origin.black_king,
        .black_queen = origin.black_queen,
    };
}

fn All(comptime T: type) T {
    return T{ .white_king = true, .white_queen = true, .black_king = true, .black_queen = true };
}

fn None(comptime T: type) T {
    return T{ .white_king = false, .white_queen = false, .black_king = false, .black_queen = false };
}

fn initStrLut() [16][]const u8 {
    var lut: [16][]const u8 = undefined;
    lut[0] = "-";
    for (1..16) |i| {
        const state = StatePacked.fromU4(@intCast(i));
        var buf: []const u8 = &.{};
        if (state.white_king) buf = buf ++ "K";

        if (state.white_queen) buf = buf ++ "Q";

        if (state.black_king) buf = buf ++ "k";

        if (state.black_queen) buf = buf ++ "q";

        lut[i] = buf;
    }
    return lut;
}

comptime {
    _ = TestImpl(State);
    _ = TestImpl(StatePacked);
}

test "state to packed white king" {
    const expected = StatePacked{ .white_king = true };
    const state = State{ .white_king = true };
    try testing.expectEqual(expected, state.toPacked());
}

test "state from packed white queen" {
    const expected = State{ .white_queen = true };
    const pack = StatePacked{ .white_queen = true };
    try testing.expectEqual(expected, State.fromPacked(pack));
}

test "packed to state black queen" {
    const expected = State{ .black_queen = true };
    const pack = StatePacked{ .black_queen = true };
    try testing.expectEqual(expected, pack.toState());
}

test "packed from state black king" {
    const expected = StatePacked{ .black_king = true };
    const state = State{ .black_king = true };
    try testing.expectEqual(expected, StatePacked.fromState(state));
}

fn TestImpl(comptime T: type) type {
    return struct {
        test "from u4 all" {
            try testFromU4(T.all, 0b1111);
        }

        test "from u4 none" {
            try testFromU4(T.none, 0b0000);
        }

        test "from u4 kings" {
            try testFromU4(T{ .white_king = true, .black_king = true }, 0b0101);
        }

        test "from u4 queens" {
            try testFromU4(T{ .white_queen = true, .black_queen = true }, 0b1010);
        }

        test "to u4 all" {
            try testToU4(0b1111, T.all);
        }

        test "to u4 none" {
            try testToU4(0b0000, T.none);
        }

        test "to u4 white" {
            try testToU4(0b0011, T{ .white_king = true, .white_queen = true });
        }

        test "to u4 black" {
            try testToU4(0b1100, T{ .black_king = true, .black_queen = true });
        }

        test "format all" {
            try testing.expectFmt("KQkq", "{}", .{T.all});
            try testing.expectFmt("KQkq", "{s}", .{T.all});
        }

        test "format none" {
            try testing.expectFmt("-", "{}", .{T.none});
            try testing.expectFmt("-", "{s}", .{T.none});
        }

        test "format white" {
            const state = T{ .white_king = true, .white_queen = true };
            try testing.expectFmt("KQ", "{}", .{state});
            try testing.expectFmt("KQ", "{s}", .{state});
        }

        test "format black" {
            const state = T{ .black_king = true, .black_queen = true };
            try testing.expectFmt("kq", "{}", .{state});
            try testing.expectFmt("kq", "{s}", .{state});
        }

        fn testFromU4(expected: T, state: u4) !void {
            try testing.expectEqual(expected, T.fromU4(state));
        }

        fn testToU4(expected: u4, state: T) !void {
            try testing.expectEqual(expected, state.toU4());
        }
    };
}
