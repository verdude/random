const std = @import("std");
const fbai = std.heap.FixedBufferAllocator.init;
const basename = std.fs.path.basename;
const dirname = std.fs.path.dirname;
const ai = std.process.ArgIterator;
const rename = std.os.rename;

const BuildError = error{NotEnoughMemory};

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

    var new_name: []u8 = try std.fmt.allocPrint(alloc, "{s}{s}", .{ tmpdir_prefix, name });
    defer alloc.free(new_name);

    std.log.info("{s} -> {s}", .{ base, new_name });
    try std.os.chdir(dn);
    try rename(base, new_name);
    return 0;
}
