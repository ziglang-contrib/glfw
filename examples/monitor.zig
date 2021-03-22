const std = @import("std");

const glfw = @import("glfw");

pub fn main() anyerror!void {
    try glfw.init();
    defer glfw.deinit();

    var primaryMonitor = try glfw.Monitor.primary();

    if (primaryMonitor) |pm| {
        std.debug.warn("primaryMonitor.getName() == {s}\n", .{ try pm.getName() });
        std.debug.warn("primaryMonitor.getPosition() == {}\n", .{ try pm.getPosition() });
        std.debug.warn("primaryMonitor.getWorkarea() == {}\n", .{ try pm.getWorkarea() });
        std.debug.warn("primaryMonitor.getContentScale() == {}\n", .{ try pm.getContentScale() });
        std.debug.warn("primaryMonitor.getVideoMode() == {}\n", .{ try pm.getVideoMode() });

        var gammaRamp = try pm.getGammaRamp();
        std.debug.warn("primaryMonitor.getGammaRamp() == {}\n", .{ gammaRamp });

        try primaryMonitor.?.setGammaRamp(gammaRamp);
    } else {
        std.debug.warn("no primary monitor", .{});
    }

    var allMonitors = try glfw.Monitor.all();

    for (allMonitors) |monitor| {
        std.debug.warn("monitor.getName() == {s}\n", .{ try monitor.getName() });
    }
}
