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

const FontStyle = enum {
    Regular,
    Italic,
    Bold,
    BoldItalic,
};

fn create_font_list(size: u8, style: FontStyle, fonts: []const FontType, mem: []u8) ![]u8 {
    var offset: u64 = 0;
    const comma = ",";
    var s = mem;
    for (fonts, 1..) |font, i| {
        s = try bufPrint(
            mem[offset..],
            "{s}:{s}:size={d}:style={s}",
            .{ font.type, font.name, size, @tagName(style) },
        );
        offset += s.len;
        if (i < fonts.len) {
            _ = try bufPrint(mem[offset..], "{s}", .{comma});
            offset += 1;
        }
    }
    return mem[0..offset];
}

fn print_default_list_entry(style: FontStyle, fl: []const u8) !void {
    const config_entry = switch (style) {
        .Regular => "URxvt.font",
        .Italic => "URxvt.italic",
        .Bold => "URxvt.bold",
        .BoldItalic => "URxvt.boldItalic",
    };
    try std.fmt.format(getStdOut().writer(), "{s}: {s}\n", .{ config_entry, fl });
}

fn create_font_change_keysym(size: u8, fonts: []const FontType, mem: []u8, print: bool) ![]const u8 {
    const prefix = "\\033]";
    const postfix = "\\007";
    const startn: u10 = 710;
    var currn: u10 = startn;
    var endn = currn + 4;
    var offset: u64 = 0;
    const command = "command:";

    var s = try bufPrint(mem[offset..], "{s}", .{command});
    offset += s.len;

    while (currn < endn) : (currn += 1) {
        const i = currn - startn;
        std.log.debug("{d}:{d}:{d}", .{ size, i, offset });
        s = try bufPrint(mem[offset..], "{s}{d};", .{ prefix, currn });
        offset += s.len;
        s = try create_font_list(size, @enumFromInt(i), fonts, mem[offset..]);
        if (print) {
            try print_default_list_entry(@enumFromInt(i), s);
        }
        offset += s.len;
        s = try bufPrint(mem[offset..], "{s}", .{postfix});
        offset += s.len;
    }
    return mem[0..offset];
}

pub fn main() !u8 {
    const ft = [_]FontType{
        FontType{ .type = "xft", .name = "Hermit" },
        FontType{ .type = "xft", .name = "Noto Sans Symbols 2" },
        FontType{ .type = "xft", .name = "Noto Sans Mono CJK SC" },
        FontType{ .type = "xft", .name = "Noto Color Emoji" },
    };
    const sizes = [_]u8{ 8, 10, 12, 14, 16, 18, 20, 22, 24 };

    const len: u32 = 300 * ft.len * sizes.len;
    var buf: [len]u8 = undefined;
    var fba = fbai(&buf);
    const alloc = fba.allocator();

    const mem = try alloc.alloc(u8, len);
    defer alloc.free(mem);

    const stdout = getStdOut();
    var key: []const u8 = undefined;
    var str: []const u8 = undefined;
    var offset: u64 = 0;
    inline for (sizes, 1..) |size, i| {
        key = try bufPrint(mem[offset..], "{s}{d}: ", .{ "URxvt.keysym.M-C-", i });
        offset += key.len;
        str = try create_font_change_keysym(size, &ft, mem[offset..], size == sizes[0]);
        offset += str.len;
        str = try bufPrint(mem[offset..], "{s}", .{"\n"});
        offset += str.len;
    }
    std.log.debug("fba mem: {d}, output len: {d}, extra: {d}", .{ len, offset, len - offset });
    try stdout.writeAll(mem[0..offset]);

    return 0;
}
