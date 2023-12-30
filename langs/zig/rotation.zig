const std = @import("std");
const pnum = std.zig.parseNumberLiteral;
const eql = std.mem.eql;

const Args = struct { x: u64, y: u64, n: u64 };
const ArgError = error{InvalidArg};

fn parse_args() !Args {
    var buf: [100]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&buf);
    var alloc = fba.allocator();
    var args = try std.process.ArgIterator.initWithAllocator(alloc);
    defer args.deinit();

    _ = args.next().?;
    var curarg = args.next();
    var x: u64 = undefined;
    var y: u64 = undefined;
    var n: u64 = undefined;
    while (curarg != null) : (curarg = args.next()) {
        const arg = curarg.?;
        if (eql(u8, arg, "-x")) {
            x = pnum(args.next().?).int;
        } else if (eql(u8, arg, "-y")) {
            y = pnum(args.next().?).int;
        } else if (eql(u8, arg, "-n")) {
            n = pnum(args.next().?).int;
        } else {
            return ArgError.InvalidArg;
        }
    }

    return Args{ .x = x, .y = y, .n = n };
}

pub fn main() !u8 {
    const args = try parse_args();
    std.log.info("{} {} {}", .{ args.x, args.y, args.n });
    if (args.y < args.n) {
        std.log.err("y[{}] Must be >= n[{}]", .{ args.y, args.n });
        return 1;
    }
    return 0;
}
