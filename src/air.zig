const std = @import("std");
const vaxis = @import("vaxis");

pub const AppConfig = struct {
    frame_rate: u64,
    tick_rate: u64,
};
pub const UIConfig = struct {
    use_nerd_icon_fonts: bool,
    ui_scale: u16,
    show_help_bar: bool,
    theme: []const u8,
    pub fn default() UIConfig {
        return .{
            .use_nerd_icon_fonts = false,
            .ui_scale = 100,
            .show_help_bar = false,
            .theme = "default",
        };
    }
};
pub const Config = struct {
    config: AppConfig,
    ui: UIConfig,
    styles: std.AutoHashMap([]const u8, vaxis.Style),
    pub fn init() Config {}
};
pub const Metadata = struct { version: []const u8, current_dir: []const u8 };
pub const Mode = enum { Normal, Insert, Visual };
pub const Action = union(enum) {};
pub const KeyMap = std.AutoArrayHashMap(Mode, std.AutoArrayHashMap(vaxis.Key, Action));
pub const Picker = struct {};
pub const Air = struct {
    config: Config,
    keymap: KeyMap,
    mode: Mode,
    picker: ?Picker,
    scroll: ?u16,
    metadata: Metadata,
};
