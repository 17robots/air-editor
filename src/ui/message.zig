const std = @import("std");
const vaxis = @import("vaxis");
const UI = @import("ui.zig");
const Message = @This();

message: vaxis.vxfw.Text,
focused: bool,
hidden: bool,
pub fn init() Message {
    return .{ .message = .{ .text = "Hello World" }, .focused = false, .hidden = false };
}
pub fn handle_event(ptr: *anyopaque, ctx: *vaxis.vxfw.EventContext, event: vaxis.vxfw.Event) anyerror!void {
    const s: *Message = @ptrCast(@alignCast(ptr));
    switch (event) {
        .focus_in => {
            s.focused = true;
            try ctx.requestFocus(s.message.widget());
        },
        .focus_out => s.focused = false,
        else => {},
    }
}
pub fn draw(ptr: *anyopaque, x: i17, y: i17, ctx: vaxis.vxfw.DrawContext) std.mem.Allocator.Error!vaxis.vxfw.SubSurface {
    const s: *Message = @ptrCast(@alignCast(ptr));
    return .{ .origin = .{ .col = x, .row = y }, .surface = try s.message.draw(ctx.withConstraints(ctx.min, ctx.max)) };
}
pub fn ui(s: *Message) UI {
    return .{ .ptr = s, .vtbl = &.{ .draw = draw, .handle_event = handle_event, .focused = focused_fn, .hidden = hidden_fn, .toggle_hidden = toggle_hidden_fn, .set_focused = set_focused_fn } };
}
pub fn focused_fn(ptr: *anyopaque) bool {
    const s: *Message = @ptrCast(@alignCast(ptr));
    return s.focused;
}
pub fn set_focused_fn(ptr: *anyopaque, focus: bool) void {
    const s: *Message = @ptrCast(@alignCast(ptr));
    s.focused = focus;
}
pub fn hidden_fn(ptr: *anyopaque) bool {
    const s: *Message = @ptrCast(@alignCast(ptr));
    return s.hidden;
}
pub fn toggle_hidden_fn(ptr: *anyopaque) void {
    const s: *Message = @ptrCast(@alignCast(ptr));
    s.hidden = !s.hidden;
}
