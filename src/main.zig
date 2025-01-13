const std = @import("std");
const vaxis = @import("vaxis");
const ui = @import("ui.zig");

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const alloc = arena.allocator();
    var app = try vaxis.vxfw.App.init(alloc);
    errdefer app.deinit();
    const screen = try alloc.create(ui.Screen);
    screen.* = ui.Screen.init(alloc);
    var message = ui.Message.init();
    message.focused = true;
    try screen.add_child(message.ui(), .{ .x = 0, .y = 0 });
    try app.run(screen.widget(), .{});
    app.deinit();
}
