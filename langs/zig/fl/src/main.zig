const std = @import("std");
const fbai = std.heap.FixedBufferAllocator.init;
const Allocator = std.heap.Allocator;
const ai = std.process.ArgIterator;
const bufPrint = std.fmt.bufPrint;
const getStdOut = std.io.getStdOut;

const FontType = struct {
    type: []const u8,
    name: []const u8,
};

fn create_str(size: u8, fonts: []const FontType, mem: []u8) ![]const u8 {
    const prefix = "\\033]";
    const postfix = "\\007";
    var currn: u10 = 710;
    var endn = currn + 4;
    var offset: u64 = 0;
    const comma = ",";

    while (currn < endn) : (currn += 1) {
        var s = try bufPrint(mem[offset..], "{s}{d};", .{ prefix, currn });
        offset += s.len;
        for (fonts, 1..) |font, i| {
            s = try bufPrint(
                mem[offset..],
                "{s}:{s}:size={d}",
                .{ font.type, font.name, size },
            );
            offset += s.len;
            if (i < fonts.len) {
                _ = try bufPrint(mem[offset..], "{s}", .{comma});
                offset += 1;
            }
        }
        s = try bufPrint(mem[offset..], "{s}", .{postfix});
        offset += s.len;
    }
    return mem[0..offset];
}

pub fn main() !u8 {
    const len: u16 = 8192;
    var buf: [len]u8 = undefined;
    var fba = fbai(&buf);
    const alloc = fba.allocator();

    const mem = try alloc.alloc(u8, len);
    defer alloc.free(mem);
    const ft = [_]FontType{
        FontType{ .type = "xft", .name = "Hermit" },
        FontType{ .type = "xft", .name = "DejaVuSans" },
        FontType{ .type = "ttf", .name = "Noto Sans" },
        FontType{ .type = "ttf", .name = "Linux Libertine" },
    };

    const str = try create_str(10, &ft, mem);

    const stdout = getStdOut();
    stdout.writeAll(str) catch return 1;
    _ = stdout.write("\n") catch return 0;

    return 0;
}
