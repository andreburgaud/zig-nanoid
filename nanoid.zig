const std = @import("std");

var prng: std.rand.Xoshiro256 = undefined;
var prng_exists = false;
const default_alphabet = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ_abcdefghijklmnopqrstuvexyz-";
const default_id_size = 21;
const default_mask = 63;

fn random() !void {
    // Instantiate a random seed from the os random generator
    var seed: u64 = undefined;
    try std.os.getrandom(std.mem.asBytes(&seed));

    // Instantiate the PRNG using the seed
    prng = std.rand.DefaultPrng.init(seed);
    prng_exists = true;
}

/// default is the default implementation of a Nanoid. It uses the default len and default alphabet.
pub fn default() ![default_id_size]u8 {
    // Instantiate PRNG
    if (!prng_exists) {
        try random();
    }

    // Feel a buffer with random bytes
    var buf: [default_id_size]u8 = undefined;
    prng.random().bytes(&buf);

    var i: u8 = 0;
    var id: [default_id_size]u8 = undefined;
    while (i < default_id_size) {
        id[i] = default_alphabet[buf[i] & default_mask];
        i += 1;
    }
    return id;
}

/// customLen implements a nanoid generation that takes an id size.
pub fn customLen(allocator: *std.mem.Allocator, id_size: u32) ![]u8 {
    if (!prng_exists) {
        try random();
    }

    var buf = try allocator.alloc(u8, id_size);
    prng.random().bytes(buf);

    var i: u32 = 0;
    const id = try allocator.alloc(u8, id_size);

    while (i < id_size) {
        id[i] = default_alphabet[buf[i] & default_mask];
        i += 1;
    }

    return id;
}

/// From https://github.com/ai/nanoid/blob/main/index.js:
/// First, a bitmask is necessary to generate the ID. The bitmask makes bytes
/// values closer to the alphabet size. The bitmask calculates the closest
/// `2^31 - 1` number, which exceeds the alphabet size.
/// For example, the bitmask for the alphabet size 30 is 31 (00011111).
fn calcMask(alphabet_size: u32) !u32 {
    var size: u32 = if (alphabet_size - 1 == 0) 1 else alphabet_size - 1;

    // Count leading zeroes (clz)
    const clz = @clz(u32, size);

    const p = try std.math.powi(u32, 2, (@typeInfo(u32).Int.bits - clz));
    return p - 1;
}

/// From https://github.com/ai/nanoid/blob/main/index.js:
/// Calculate how many random bytes to generate.
/// The number of random bytes gets decided upon the ID size, mask,
/// alphabet size, and magic number 1.6 (using 1.6 peaks at performance
/// according to benchmarks) (source?)
fn countRandBytes(id_size: u32, alphabet_size: u32, mask: u32) u32 {
   return @floatToInt(u32, @ceil(1.6 * (@intToFloat(f32, mask * id_size) / @intToFloat(f32, alphabet_size))));
}

/// customAlphabet generates a nanoid given a custom alphabet and a size for the resulting id
pub fn customAlphabet(allocator: *std.mem.Allocator, size: u32, alphabet: []u8) ![]u8 {
    // Instantiate PRNG
    if (!prng_exists) {
        try random();
    }

    // Calculate mask
    const alphabet_size: u32 = @intCast(u32, alphabet.len);
    const id_size = @intCast(u32, size);
    const mask = try calcMask(alphabet_size);

    // Random bytes buffer
    const buf_size = countRandBytes(id_size, alphabet_size, mask);
    var buf = try allocator.alloc(u8, buf_size);
    prng.random().bytes(buf);

    // Allocate ID buffer
    const id = try allocator.alloc(u8, id_size);

    // Generate ID
    var i: u8 = 0;
    var j: u8 = 0;
    var index: u32 = undefined;

    while (i < buf_size) {
        if (j == id_size) {
            return id;
        }
        index = buf[i] & mask;
        if (index < alphabet_size) {
            id[j] = alphabet[index];
            j += 1;
        }
        i += 1;
    }
    return id;
}

test "nanoid default length and alphabet" {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    var id = try default();
    std.debug.print("{s}\n", .{ id });
    try std.testing.expect(id.len == 21);
}

test "nanoid with length 30" {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = &arena.allocator();
    var id = try customLen(allocator, 30);
    std.debug.print("{s}\n", .{ id });
    try std.testing.expect(id.len == 30);
}

test "nanoid with length 255" {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = &arena.allocator();
    var id = try customLen(allocator, 256);
    std.debug.print("{s}\n", .{ id });
    try std.testing.expect(id.len == 256);
}

test "nanoid with custom alphabet" {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = &arena.allocator();
    var numbers = "0123456789";
    const n = try allocator.alloc(u8, numbers.len);
    std.mem.copy(u8, n, numbers);
    var id = try customAlphabet(allocator, 25, n);
    std.debug.print("{s}\n", .{ id });
    try std.testing.expect(id.len == 25);
}

test "mask for alphabet size 8" {
    const mask = try calcMask(8);
    std.debug.print("{d}\n", .{ mask });
    try std.testing.expect(mask == 7);
}

test "mask for alphabet size 30" {
    const mask = try calcMask(30);
    std.debug.print("{d}\n", .{ mask });
    try std.testing.expect(mask == 31);
}

test "mask for alphabet size 254" {
    const mask = try calcMask(254);
    std.debug.print("{d}\n", .{ mask });
    try std.testing.expect(mask == 255);
}