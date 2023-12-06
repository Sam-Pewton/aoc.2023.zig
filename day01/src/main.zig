const std = @import("std");

pub const std_options = struct {
    pub const log_level = .info;
};

pub const NumberStrings = enum(u8) {
    none = 0,
    one = 1,
    two = 2,
    three = 3,
    four = 4,
    five = 5,
    six = 6,
    seven = 7,
    eight = 8,
    nine = 9,
    fn getEnumValue(string: []const u8) NumberStrings {
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
    fn equal(left: []const u8, right: []const u8) bool {
        if (left.len != right.len) return false;
        for (left, right) |l, r| {
            if (l != r) {
                return false;
            }
        }
        std.log.info("Found: {s}", .{left});
        return true;
    }
};

pub fn checkCharacter(character: u8) bool {
    return std.ascii.isDigit(character);
}

pub fn getStringRepresentation(line: []const u8, index: usize) u8 {
    for (3..6) |n| {
        if (line.len >= n) {
            if (index < line.len - n) {
                std.log.info("{any}", .{@intFromEnum(NumberStrings.getEnumValue(line[index .. index + n]))});
                return @intFromEnum(NumberStrings.getEnumValue(line[index .. index + n]));
            }
        }
    }
    return 0;
}

pub fn sumArrayList(list: std.ArrayList(u8)) u32 {
    var total: u32 = 0;
    for (list.items) |i| {
        total += i;
    }
    return total;
}

pub fn run(filename: []const u8) anyerror!void {
    const allocator = std.heap.page_allocator;
    var list_one = std.ArrayList(u8).init(allocator);
    defer list_one.deinit();
    var list_two = std.ArrayList(u8).init(allocator);
    defer list_two.deinit();

    const file = try std.fs.cwd().openFile(filename, .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var buf: [1024]u8 = undefined;
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var first: u8 = 0;
        var last: u8 = 0;
        var first_two: u8 = 0;
        var last_two: u8 = 0;
        for (line, 0..) |character, index| {
            // Part 1
            if (checkCharacter(character)) {
                first = if (first == 0) character else first;
                first_two = if (first_two == 0) character else first_two;
                last = character;
                last_two = character;
            }
            // Part 2
            const rep = getStringRepresentation(line, index);
            if (rep != 0) {
                first_two = if (first_two == 0) std.fmt.digitToChar(rep, std.fmt.Case.lower) else first_two;
                last_two = std.fmt.digitToChar(rep, std.fmt.Case.lower);
            }
        }
        const final: u8 = try std.fmt.parseInt(u8, &[2]u8{ first, last }, 10);
        try list_one.append(final);
        std.log.info("TEST: {any}{any}", .{ first_two, last_two });
        const final_two: u8 = try std.fmt.parseInt(u8, &[2]u8{ first_two, last_two }, 10);
        try list_two.append(final_two);
    }
    std.log.debug("Final array: {any}", .{list_one.items});
    std.log.info("Part 1: {any}", .{sumArrayList(list_one)});
    std.log.info("Part 2: {any}", .{sumArrayList(list_two)});
}

pub fn main() !void {
    try run("./data/data.txt");
}

test "test example part 1" {
    //try run("./data/example_1.txt");
}

test "test example part 2" {
    //try run("./data/example_2.txt");
}
