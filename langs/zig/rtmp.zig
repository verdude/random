const std = @import("std");
const fbai = std.heap.FixedBufferAllocator.init;
const basename = std.fs.path.basename;
const dirname = std.fs.path.dirname;
const ai = std.process.ArgIterator;
const rename = std.os.rename;

const BuildError = error{NotEnoughMemory};

fn buildstr(pre: []const u8, suf: []const u8, mem: []u8) BuildError![]u8 {
    if (pre.len + suf.len > mem.len) {
        return BuildError.NotEnoughMemory;
    }
    var start_bound: usize = 0;
    var end_bound: usize = start_bound + pre.len;
    @memcpy(mem[start_bound..end_bound], pre);
    start_bound = end_bound;
    end_bound = start_bound + suf.len;
    @memcpy(mem[start_bound..end_bound], suf);
    return mem[0..end_bound];
}

pub fn main() !u8 {
    const len: u16 = 4096;
    var buf: [len]u8 = undefined;
    var fba = fbai(&buf);
    const alloc = fba.allocator();

    const memory = try alloc.alloc(u8, len / 2);
    defer alloc.free(memory);

    const path = try std.process.getCwd(memory);
    const base = basename(path);
    const dn = dirname(path).?;

    const tmpdir_prefix = "tmpdir-";
    if (!std.mem.startsWith(u8, base, tmpdir_prefix)) {
        std.log.info("Not tmpdir: {s}", .{base});
        return 1;
    }

    var args = try ai.initWithAllocator(alloc);
    defer args.deinit();

    _ = args.next();
    const name: []const u8 = args.next() orelse {
        std.log.err("Missing arg.", .{});
        return 1;
    };

    var new_name: []u8 = try alloc.alloc(u8, tmpdir_prefix.len + name.len);
    defer alloc.free(new_name);
    const name_slice: []u8 = try buildstr(tmpdir_prefix, name, new_name);

    std.log.info("{s} -> {s}", .{ base, name_slice });
    try std.os.chdir(dn);
    try rename(base, name_slice);
    return 0;
}
