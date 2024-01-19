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
    const command = "command:";

    var s = try bufPrint(mem[offset..], "{s}", .{command});
    offset += s.len;

    while (currn < endn) : (currn += 1) {
        s = try bufPrint(mem[offset..], "{s}{d};", .{ prefix, currn });
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
        FontType{ .type = "xft", .name = "Linux Libertine" },
        FontType{ .type = "xft", .name = "Noto Sans CJK SC" },
        FontType{ .type = "xft", .name = "Noto Color Emoji" },
    };

    const stdout = getStdOut();
    const sizes = [_]u8{ 8, 10, 12, 14, 16 };
    var key: []const u8 = undefined;
    var str: []const u8 = undefined;
    var offset: u64 = 0;
    inline for (sizes, 1..) |size, i| {
        key = try bufPrint(mem[offset..], "{s}{d}: ", .{ "URxvt.keysym.M-C-", i });
        offset += key.len;
        str = try create_str(size, &ft, mem[offset..]);
        offset += str.len;
        str = try bufPrint(mem[offset..], "{s}", .{"\n"});
        offset += str.len;
    }
    try stdout.writeAll(mem[0..offset]);

    return 0;
}
