/// AOC Day 1
const std = @import("std");

// Define the logging level. For more detailed logging change to .debug
pub const std_options = struct {
    pub const log_level = .info;
};

/// NumberStrings enum used to match a string to a number in ascii.
///
/// Only numbers 1 -> 9 are represented, as this is all required by the challenge.
pub const NumberStrings = enum(u8) {
    none = 0,
    one = '1',
    two = '2',
    three = '3',
    four = '4',
    five = '5',
    six = '6',
    seven = '7',
    eight = '8',
    nine = '9',
    /// Get the enum value of a string.
    ///
    /// For example, "one" would return NumberStrings.one
    fn getEnumValue(string: *const []u8) NumberStrings {
        std.log.debug("Searching for: {s}", .{string.*});
        if (NumberStrings.equal("one", string)) return NumberStrings.one;
        if (NumberStrings.equal("two", string)) return NumberStrings.two;
        if (NumberStrings.equal("three", string)) return NumberStrings.three;
        if (NumberStrings.equal("four", string)) return NumberStrings.four;
        if (NumberStrings.equal("five", string)) return NumberStrings.five;
        if (NumberStrings.equal("six", string)) return NumberStrings.six;
        if (NumberStrings.equal("seven", string)) return NumberStrings.seven;
        if (NumberStrings.equal("eight", string)) return NumberStrings.eight;
        if (NumberStrings.equal("nine", string)) return NumberStrings.nine;
        return NumberStrings.none;
    }
    /// Check if left and right strings match
    fn equal(left: []const u8, right: *const []u8) bool {
        if (left.len != right.*.len) return false;
        for (left, right.*) |l, r| {
            if (l != r) {
                return false;
            }
        }
        std.log.debug("Found: {s}", .{left});
        return true;
    }
};

/// Retrieve the character representation of a stringified number.
///
/// For example, "nine" would retrieve '9' in u8.
pub fn getStringRepresentation(line: *const []u8, index: *const usize) u8 {
    for (3..6) |n| {
        if (line.*.len >= n) {
            if (index.* <= line.*.len - n) {
                const res = @intFromEnum(NumberStrings.getEnumValue(&line.*[index.* .. index.* + n]));
                if (res != 0) {
                    return res;
                }
            }
        }
    }
    return 0;
}

/// Sum an arraylist of u8s to a single u32 value.
pub fn sumArrayList(list: *std.ArrayList(u8)) u32 {
    var total: u32 = 0;
    for (list.items) |i| {
        total += i;
    }
    return total;
}

/// Run the challenge
pub fn run(filename: []const u8, with_words: bool) anyerror!u32 {
    const allocator = std.heap.page_allocator;
    var numbers = std.ArrayList(u8).init(allocator);
    defer numbers.deinit();

    const file = try std.fs.cwd().openFile(filename, .{});
    defer file.close();
    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var buf: [1024]u8 = undefined;
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        std.log.debug("{s}", .{line});
        var first: u8 = 0;
        var last: u8 = 0;
        for (line, 0..) |character, index| {
            // Part 1
            if (std.ascii.isDigit(character)) {
                first = if (first == 0) character else first;
                last = character;
            }

            // Part 2
            if (with_words) {
                const rep = getStringRepresentation(&line, &index);
                if (rep != 0) {
                    first = if (first == 0) rep else first;
                    last = rep;
                }
            }
        }
        const final: u8 = try std.fmt.parseInt(u8, &[2]u8{ first, last }, 10);
        try numbers.append(final);
    }
    return sumArrayList(&numbers);
}

/// Entrypoint
pub fn main() !void {
    const res = try run("./data/data.txt", false);
    std.log.info("Part 1: {any}", .{res});
    const res2 = try run("./data/data.txt", true);
    std.log.info("Part 2: {any}", .{res2});
}

test "test example part 1" {
    const res = try run("./data/example_1.txt", false);
    try std.testing.expect(res == 142);
}

test "test example part 2" {
    const res = try run("./data/example_2.txt", true);
    try std.testing.expect(res == 281);
}
