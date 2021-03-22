const std = @import("std");

const glfw = @import("glfw");

pub fn main() anyerror!void {
    try glfw.init();
    defer glfw.deinit();

    std.debug.warn("glfw.getVersion() == {}\n", .{ glfw.getVersion() });
    std.debug.warn("glfw.getVersionString() == {s}\n", .{ glfw.getVersionString() });
}
