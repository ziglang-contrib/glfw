const std = @import("std");

const glfw = @import("glfw");

var icon_pixels = [_]u8{ 0xFF, 0xFF, 0xFF, 0xFF };

pub fn main() anyerror!void {
    try glfw.init();
    defer glfw.deinit();

    var window = try glfw.Window.init(400, 300, "monitor", null, null);
    defer window.deinit();

    try window.setTitle("new title");
    std.debug.warn("window.shouldClose() == {}\n", .{try window.shouldClose()});

    var icon: glfw.Image = undefined;
    icon.width = 1;
    icon.height = 1;
    icon.pixels = &icon_pixels;

    try window.setIcon(icon);

    var pos = try window.getPos();
    std.debug.warn("window.getPos() == {}\n", .{pos});

    pos.x += 100;
    pos.y += 100;
    try window.setPos(pos);
    std.debug.warn("window.setPos({})\n", .{pos});

    var size = try window.getSize();
    std.debug.warn("window.getSize() == {}\n", .{size});

    size.width += 200;
    size.height += 200;
    try window.setSize(size);
    std.debug.warn("window.setSize({})\n", .{size});

    try window.setSizeLimits(glfw.Size{ .width = 200, .height = 100 }, glfw.Size{ .width = 800, .height = 600 });
    std.debug.warn("window.setSizeLimits(...)\n", .{});

    try window.setAspectRatio(glfw.Size{ .width = 4, .height = 3 });
    std.debug.warn("window.setAspectRatio(...)\n", .{});

    var framebufferSize = try window.getFramebufferSize();
    std.debug.warn("window.getFramebufferSize() == {}\n", .{framebufferSize});

    var frameSize = try window.getFrameSize();
    std.debug.warn("window.getFrameSize() == {}\n", .{frameSize});

    while (!try window.shouldClose()) {
        try glfw.pollEvents();
        try window.swapBuffers();
    }
}
