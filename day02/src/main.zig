/// AOC Day 2
const std = @import("std");

// Define the logging level. For more detailed logging change to .debug
pub const std_options = struct {
    pub const log_level = .debug;
};

/// House the results needed from a game
pub const Result = struct {
    game_id: u32,
    possible: bool,
    power: u32,
};

/// Check if a game is possible given the constraints in the question.
///
/// Red must have 12 cubes max
/// Green must have 13 cubes max
/// Blue must have 14 cubes max
pub fn isPossible(red: u8, green: u8, blue: u8) bool {
    if (red > 12) {
        return false;
    }
    if (green > 13) {
        return false;
    }
    if (blue > 14) {
        return false;
    }
    return true;
}

/// Get the minimum set set
pub fn minimumSet(red: u8, green: u8, blue: u8) u32 {
    return @as(u32, red) * @as(u32, blue) * @as(u32, green);
}

/// Main logic, extract all of the info from the game and return the result.
pub fn parseData(line: *const []u8) !Result {
    var first: usize = 0;
    var last: usize = 0;

    const allocator = std.heap.page_allocator;
    var game_ends = std.ArrayList(usize).init(allocator);
    defer game_ends.deinit();

    var is_possible = true;
    var max_red: u8 = 0;
    var max_green: u8 = 0;
    var max_blue: u8 = 0;
    var minimum_sets = std.ArrayList(u32).init(allocator);
    defer minimum_sets.deinit();

    // Get the game number and splitter values for the reveals
    for (line.*, 0..) |c, ind| {
        if (c == ' ') {
            if (first == 0) {
                first = ind;
                continue;
            }
            if (last == 0) {
                last = ind;
                continue;
            }
        }
        if (c == ';') {
            try game_ends.append(ind);
        }
    }
    try game_ends.append(line.*.len);
    const game_no = try std.fmt.parseInt(u32, line.*[first + 1 .. last - 1], 10);

    // Extract the RGB values from each reveal
    var pre = last + 1;
    for (game_ends.items) |game| {
        var red: u8 = 0;
        var green: u8 = 0;
        var blue: u8 = 0;
        var start: usize = 0;
        const xyz = line.*[pre..game];
        for (xyz, 0..) |c, ind| {
            if (c == 'd') {
                red = try std.fmt.parseInt(u8, xyz[start .. ind - 3], 10);
                if (red > max_red) max_red = red;
                start = ind + 3;
            }
            if (c == 'g') {
                green = try std.fmt.parseInt(u8, xyz[start .. ind - 1], 10);
                if (green > max_green) max_green = green;
                start = ind + 7;
            }
            if (c == 'b') {
                blue = try std.fmt.parseInt(u8, xyz[start .. ind - 1], 10);
                if (blue > max_blue) max_blue = blue;
                start = ind + 6;
            }
        }
        // Check if the reveal is possible
        if (!isPossible(red, green, blue)) {
            is_possible = false;
        }
        pre = game + 2;
    }
    return Result{ .game_id = game_no, .possible = is_possible, .power = minimumSet(max_red, max_green, max_blue) };
}

/// Run the challenge
pub fn run(filename: []const u8) anyerror![2]u32 {
    const file = try std.fs.cwd().openFile(filename, .{});
    defer file.close();
    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();
    const allocator = std.heap.page_allocator;
    var results = std.ArrayList(Result).init(allocator);
    defer results.deinit();

    var buf: [1024]u8 = undefined;
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        const res = try parseData(&line);
        try results.append(res);
    }

    var part_one: u32 = 0;
    var part_two: u32 = 0;

    for (results.items) |res| {
        if (res.possible) {
            part_one += res.game_id;
        }
        part_two += res.power;
    }

    return [_]u32{ part_one, part_two };
}

/// Entrypoint
pub fn main() !void {
    const res = run("data/data.txt") catch [_]u32{ 0, 0 };
    std.log.info("Part 1: {any}, Part 2: {any}", .{ res[0], res[1] });
}

test "test example" {
    const res = run("data/example.txt") catch [_]u32{ 0, 0 };
    try std.testing.expectEqual(res, [_]u32{ 8, 2286 });
}
