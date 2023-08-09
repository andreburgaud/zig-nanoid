const std = @import("std");
const print = std.debug.print;
const nanoid = @import("nanoid.zig");
const app_name = "nanoid";
const app_version = "0.4.0";

fn version() void {
    print("{s} version {s}\n", .{ app_name, app_version });
}

fn usage() void {
    print("Usage:\n", .{});
    print("  {s}                           \tGenerate a nanoid with the default size (21) and default alphabet\n", .{app_name});
    print("  {s} -s | --size <size>        \tGenerate a nanoid with a custom size and default alphabet\n", .{app_name});
    print("  {s} -a | --alphabet <alphabet>\tGenerate a nanoid with a custom alphabet (requires the size)\n", .{app_name});
    print("  {s} -h | --help               \tDisplay this help\n", .{app_name});
    print("  {s} -v | --version            \tPrint the version\n", .{app_name});

    print("Examples:\n", .{});
    print("  {s}\n", .{app_name});
    print("  {s} -s 42\n", .{app_name});
    print("  {s} -s 42 -a 0123456789\n", .{app_name});
}

pub fn main() !void {
    var id: [21]u8 = undefined;

    // =========
    // CLI
    const args = try std.process.argsAlloc(std.heap.page_allocator);
    defer std.process.argsFree(std.heap.page_allocator, args);

    // To print to stdout
    var out = std.io.getStdOut().writer();

    var size: u32 = 0;
    var alphabet: []u8 = "";

    if (args.len > 1) {
        for (args, 0..) |arg, i| {

            // Executable name
            if (i == 0) {
                continue;
            }

            if (std.mem.eql(u8, "--help", arg) or std.mem.eql(u8, "-h", arg)) {
                usage();
                return;
            }

            if (std.mem.eql(u8, "--version", arg) or std.mem.eql(u8, "-v", arg)) {
                version();
                return;
            }

            if (std.mem.eql(u8, "--size", arg) or std.mem.eql(u8, "-s", arg)) {
                if (i + 1 < args.len) {
                    var input = std.fmt.parseInt(i64, args[i + 1], 10) catch |err| {
                        print("error parsing size {s}: {}\n", .{ args[i + 1], err });
                        std.process.exit(1);
                    };
                    size = @as(u32, @intCast(input));
                    if (size == 0) {
                        print("error: size should be greater than 0\n", .{});
                        std.process.exit(1);
                    }
                } else {
                    print("error: size is missing\n", .{});
                    usage();
                    std.process.exit(1);
                }
            }

            if (std.mem.eql(u8, "--alphabet", arg) or std.mem.eql(u8, "-a", arg)) {
                if (i + 1 < args.len) {
                    alphabet = args[i + 1];
                } else {
                    print("error: alphabet is missing\n", .{});
                    usage();
                    std.process.exit(1);
                }
            }
        }

        var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
        defer arena.deinit();
        const allocator = arena.allocator();

        // Generate an id with a custom size and alphabet
        if (size > 0 and alphabet.len > 0) {
            var id_with_size_alphabet = nanoid.customAlphabet(allocator, size, alphabet) catch |err| {
                std.debug.print("error creating a nanoid with len {d} and alphabet {s}: {}\n", .{ size, alphabet, err });
                std.process.exit(1);
            };
            try out.print("{s}\n", .{id_with_size_alphabet});
            return;
        }

        // Generate an id with a custom size and default alphabet
        if (size > 0) {
            var id_with_size = nanoid.customLen(allocator, size) catch |err| {
                std.debug.print("error creating a nanoid with len {d} {}\n", .{ size, err });
                std.process.exit(1);
            };
            try out.print("{s}\n", .{id_with_size});
            return;
        }

        // Custom alphabet was provided without a custom size
        if (alphabet.len > 0) {
            std.debug.print("error: size option is missing\n", .{});
            usage();
            std.process.exit(1);
        }

        print("error: unexpected arguments {s}\n", .{args});
        usage();
        std.process.exit(1);
    }

    // No argument => generate a nanoid with default len 21 and default alphabet
    id = nanoid.default() catch |err| {
        std.debug.print("error creating a nanoid {}\n", .{err});
        std.process.exit(1);
    };
    try out.print("{s}\n", .{id});
}
