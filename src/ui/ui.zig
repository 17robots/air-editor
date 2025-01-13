const std = @import("std");
const vaxis = @import("vaxis");
const UI = @This();

const VTable = struct {
    draw: *const fn (ptr: *anyopaque, x: i17, y: i17, ctx: vaxis.vxfw.DrawContext) std.mem.Allocator.Error!vaxis.vxfw.SubSurface,
    handle_event: *const fn (ptr: *anyopaque, ctx: *vaxis.vxfw.EventContext, event: vaxis.vxfw.Event) anyerror!void,
    focused: *const fn (ptr: *anyopaque) bool,
    hidden: *const fn (ptr: *anyopaque) bool,
    toggle_hidden: *const fn (ptr: *anyopaque) void,
    set_focused: *const fn (ptr: *anyopaque, focus: bool) void,
};

ptr: *anyopaque,
vtbl: *const VTable,
pub fn draw(s: UI, x: i17, y: i17, ctx: vaxis.vxfw.DrawContext) std.mem.Allocator.Error!vaxis.vxfw.SubSurface {
    return try s.vtbl.draw(s.ptr, x, y, ctx);
}
pub fn handle_event(s: UI, ctx: *vaxis.vxfw.EventContext, event: vaxis.vxfw.Event) anyerror!void {
    try s.vtbl.handle_event(s.ptr, ctx, event);
}
pub fn focused(s: UI) bool {
    return s.vtbl.focused(s.ptr);
}
pub fn set_focused(s: UI, focus: bool) bool {
    return s.vtbl.focused(s.ptr, focus);
}
pub fn hidden(s: UI) bool {
    return s.vtbl.hidden(s.ptr);
}
pub fn toggle_hidden(s: UI) void {
    s.vtbl.toggle_hidden(s.ptr);
}
