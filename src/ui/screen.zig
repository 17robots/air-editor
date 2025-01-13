const std = @import("std");
const vaxis = @import("vaxis");
const UI = @import("ui.zig");
pub const Layout = struct { x: i17, y: i17 };
const Screen = @This();

children: std.ArrayList(UI),
layout: std.ArrayList(Layout),
alloc: std.mem.Allocator,
pub fn init(alloc: std.mem.Allocator) Screen {
    return .{ .alloc = alloc, .children = std.ArrayList(UI).init(alloc), .layout = std.ArrayList(Layout).init(alloc) };
}
pub fn draw(ptr: *anyopaque, ctx: vaxis.vxfw.DrawContext) std.mem.Allocator.Error!vaxis.vxfw.Surface {
    const max = ctx.max.size();
    const s: *Screen = @ptrCast(@alignCast(ptr));
    var visible_children: usize = 0;
    for (s.children.items) |c| visible_children += if (c.hidden()) 0 else 1;
    var children = std.ArrayList(vaxis.vxfw.SubSurface).init(s.alloc);
    for (0..s.children.items.len) |i| {
        if (!s.children.items[i].hidden()) try children.append(try s.children.items[i].draw(s.layout.items[i].x, s.layout.items[i].y, ctx));
    }
    return .{
        .size = max,
        .widget = s.widget(),
        .focusable = true,
        .buffer = &.{},
        .children = children.items,
    };
}
pub fn handle_event(ptr: *anyopaque, ctx: *vaxis.vxfw.EventContext, event: vaxis.vxfw.Event) anyerror!void {
    const s: *Screen = @ptrCast(@alignCast(ptr));
    var focused: ?*const UI = null;
    for (s.children.items) |c| {
        if (!c.hidden()) {
            if (c.focused()) focused = &c;
        }
    }
    // global events
    switch (event) {
        .key_press => |k| {
            if (k.matches('c', .{ .ctrl = true })) {
                ctx.quit = true;
                return;
            }
            if (k.matches('h', .{ .ctrl = true })) {
                for (s.children.items) |*c| c.toggle_hidden();
                ctx.redraw = true;
            }
            if (focused) |f| return f.handle_event(ctx, event);
            return;
        },
        else => {
            if (focused) |f| return f.handle_event(ctx, event);
            return;
        },
    }
}
pub fn deinit(s: Screen) void {
    s.children.deinit();
    s.layout.deinit();
}
pub fn widget(s: *Screen) vaxis.vxfw.Widget {
    return .{ .userdata = s, .eventHandler = Screen.handle_event, .drawFn = Screen.draw };
}
pub fn add_child(s: *Screen, child: UI, layout: Layout) !void {
    try s.children.append(child);
    try s.layout.append(layout);
}
