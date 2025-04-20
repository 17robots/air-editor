const std = @import("std");
const vaxis = @import("vaxis");

const log = std.log.scoped(.main);
const Event = union(enum) {
    key_press: vaxis.Key,
    winsize: vaxis.Winsize,
};

const App = struct {
    alloc: std.mem.Allocator,
    redraw: bool = false,
    quit: bool = false,
    tty: vaxis.Tty,
    vx: vaxis.Vaxis,
    pub fn init(alloc: std.mem.Allocator) !App {
        return .{ .alloc = alloc, .tty = try vaxis.Tty.init(), .vx = try vaxis.init(alloc, .{}) };
    }
    pub fn run(s: *App) !void {
        s.redraw = true;
        const tty = &s.tty;
        const vx = &s.vx;
        var loop: vaxis.Loop(Event) = .{ .tty = tty, .vaxis = vx };
        try loop.init();
        try loop.start();
        defer loop.stop();
        try s.vx.enterAltScreen(s.tty.anyWriter());
        try s.vx.queryTerminal(s.tty.anyWriter(), 1 * std.time.ns_per_s);
        var color_idx: u8 = 0;
        const message = "Hello world";
        const msg_len: u16 = @intCast(message.len);
        while (true) {
            const event = loop.nextEvent();
            switch (event) {
                .key_press => |k| {
                    if (k.matches('c', .{ .ctrl = true })) break;
                    color_idx = switch (color_idx) {
                        255 => 0,
                        else => color_idx + 1,
                    };
                    s.redraw = true;
                },
                .winsize => |w| {
                    try s.vx.resize(s.alloc, s.tty.anyWriter(), w);
                    s.redraw = true;
                },
            }
            if (s.redraw) {
                const win = s.vx.window();
                win.clear();
                const child = win.child(.{ .x_off = win.width / 2 - msg_len, .y_off = win.height / 2 });
                for (message, 0..) |_, i| child.writeCell(@intCast(i), 0, .{ .char = .{ .grapheme = message[i .. i + 1] }, .style = .{ .fg = .{ .index = color_idx } } });
                try s.vx.render(s.tty.anyWriter());
                s.redraw = false;
            }
        }
    }
    pub fn deinit(s: *App) void {
        s.vx.deinit(s.alloc, s.tty.anyWriter());
        s.tty.deinit();
    }
};

const AppConfig = struct {
    refresh_time: u64,
};
const PickerConfig = struct {};
const Config = struct {
    app_config: AppConfig,
    leader_key: vaxis.Key = vaxis.Key.space,
    picker_config: PickerConfig,
};
const Action = union(enum) {};

const EditMode = enum { normal, insert, visual };
const KeyMap = std.AutoHashMapUnmanaged(EditMode, std.AutoHashMapUnmanaged([]vaxis.Key, Action));

const AirEditor = struct {
    config: Config,
    editor: Editor,
    edit_mode: EditMode = .normal,
    key_map: KeyMap,
    input_buffer: std.ArrayList(vaxis.Key),
};

const BufferNode = union(enum) { split: struct { direction: enum { vertical, horizontal }, children: std.ArrayList(BufferNode) } };
const Editor = struct {
    alloc: std.mem.Allocator,
    buffers: std.ArrayList(Buffer),
    buffer_tree: struct { tree: BufferNode, floating: Buffer, bottom: Buffer, left: Buffer, right: Buffer, top: Buffer },
    focused_buffer: *Buffer,
};

const Buffer = struct {
    pub const BufferType = enum { documentation, file, picker };
    const Selection = struct { start: .{ usize, usize }, end: .{ usize, usize } };
    const Cursor = struct { x: i17, y: i17 };
    alloc: std.mem.Allocator,
    type: BufferType,
    buf_name: []const u8,
    editable: false,
    selection: ?std.ArrayList(Selection),
    cursors: std.ArrayList(Cursor),
    window_position: ?u32,
    modified: bool,
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const alloc = arena.allocator();
    var app = try App.init(alloc);
    errdefer app.deinit();
    try app.run();
    app.deinit();
}
