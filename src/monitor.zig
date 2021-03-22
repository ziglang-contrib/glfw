const std = @import("std");
const mem = std.mem;

const c = @import("./c.zig");
const glfw = @import("./main.zig");

const VideoMode = glfw.VideoMode;
/// Gamma ramp.
const GammaRamp = glfw.GammaRamp;

/// Opaque monitor object.
pub const Monitor = packed struct {
    const Self = @This();

    handle: *c.GLFWmonitor,

    /// This function returns a slice of `Monitor` for all currently
    /// connected monitors. The primary monitor is always first in the
    /// returned slice.
    pub fn all() ![]Monitor {
        var count: i32 = 0;
        var handles = c.glfwGetMonitors(&count);

        glfw.getError() catch |err| switch (err) {
            glfw.Error.NotInitialized => return err,
            else => unreachable,
        };

        return @ptrCast([*]Self, handles)[0..@intCast(usize, count)];
    }

    /// This function returns the primary monitor. This is usually the
    /// monitor where elements like the task bar or global menu bar
    /// are located.
    pub fn primary() !?Monitor {
        var maybeHandle = c.glfwGetPrimaryMonitor();

        glfw.getError() catch |err| switch (err) {
            glfw.Error.NotInitialized => return err,
            else => unreachable,
        };

        if (maybeHandle) |handle| {
            return Monitor{
                .handle = handle,
            };
        } else {
            return null;
        }
    }

    pub const Position = struct {
        x: i32,
        y: i32,
    };

    /// This function returns the position, in screen coordinates, of
    /// the upper-left corner of the specified monitor.
    pub fn getPosition(self: Self) !Position {
        var pos: Position = undefined;

        c.glfwGetMonitorPos(self.handle, &pos.x, &pos.y);

        glfw.getError() catch |err| switch (err) {
            glfw.Error.NotInitialized, glfw.Error.PlatformError => return err,
            else => unreachable,
        };

        return pos;
    }

    pub const Workarea = struct {
        x: i32,
        y: i32,
        width: i32,
        height: i32,
    };

    /// This function returns the position, in screen coordinates, of
    /// the upper-left corner of the work area of the specified monitor
    /// along with the work area size in screen coordinates. The work
    /// area is defined as the area of the monitor not occluded by the
    /// operating system task bar where present. If no task bar exists
    /// then the work area is the monitor resolution in screen
    /// coordinates.
    pub fn getWorkarea(self: Self) !Workarea {
        var workarea: Workarea = undefined;

        c.glfwGetMonitorWorkarea(self.handle, &workarea.x, &workarea.y, &workarea.width, &workarea.height);

        glfw.getError() catch |err| switch (err) {
            glfw.Error.NotInitialized, glfw.Error.PlatformError => return err,
            else => unreachable,
        };

        return workarea;
    }

    pub const PhysicalSize = struct {
        width: i32,
        height: i32,
    };

    /// This function returns the size, in millimetres, of the display
    /// area of the specified monitor.
    ///
    /// Some systems do not provide accurate monitor size information,
    /// either because the monitor EDID data is incorrect or because the
    /// driver does not report it accurately.
    pub fn getPhysicalSize(self: Self) !PhysicalSize {
        var physicalSize: PhysicalSize = undefined;

        c.glfwGetMonitorPhysicalSize(self.handle, &physicalSize.width, &physicalSize.height);

        glfw.getError() catch |err| switch (err) {
            glfw.Error.NotInitialized => return err,
            else => unreachable,
        };

        return physicalSize;
    }

    pub const ContentScale = struct {
        x: f32,
        y: f32,
    };

    /// This function retrieves the content scale for the specified
    /// monitor. The content scale is the ratio between the current DPI
    /// and the platform's default DPI. This is especially important for
    /// text and any UI elements. If the pixel dimensions of your UI
    /// scaled by this look appropriate on your machine then it should
    /// appear at a reasonable size on other machines regardless of
    /// their DPI and scaling settings. This relies on the system DPI
    /// and scaling settings being somewhat correct.
    ///
    /// The content scale may depend on both the monitor resolution and
    /// pixel density and on user settings. It may be very different
    /// from the raw DPI calculated from the physical size and current
    /// resolution.
    pub fn getContentScale(self: Self) !ContentScale {
        var contentScale: ContentScale = undefined;

        c.glfwGetMonitorContentScale(self.handle, &contentScale.x, &contentScale.y);

        glfw.getError() catch |err| switch (err) {
            glfw.Error.NotInitialized, glfw.Error.PlatformError => return err,
            else => unreachable,
        };

        return contentScale;
    }

    /// This function returns a human-readable name, encoded as UTF-8,
    /// of the specified monitor. The name typically reflects the make
    /// and model of the monitor and is not guaranteed to be unique
    /// among the connected monitors.
    pub fn getName(self: Self) ![:0]const u8 {
        var name: [*c]const u8 = c.glfwGetMonitorName(self.handle);

        glfw.getError() catch |err| switch (err) {
            glfw.Error.NotInitialized => return err,
            else => unreachable,
        };

        return mem.spanZ(@as([*:0]const u8, name));
    }

    /// This function sets the user-defined pointer of the specified
    /// monitor. The current value is retained until the monitor is
    /// disconnected. The initial value is `null`.
    ///
    /// This function may be called from the monitor callback, even for
    /// a monitor that is being disconnected.
    pub fn setUserPointer(self: *Self, comptime T: type, pointer: ?*T) !void {
        c.glfwSetMonitorUserPointer(self.handle, @ptrCast(?*c_void, pointer));

        glfw.getError() catch |err| switch (err) {
            glfw.Error.NotInitialized => return err,
            else => unreachable,
        };
    }

    /// This function returns the current value of the user-defined
    /// pointer of the specified monitor. The initial value is `null`.
    ///
    /// This function may be called from the monitor callback, even for
    /// a monitor that is being disconnected.
    pub fn getUserPointer(self: Self, comptime T: type) !?*T {
        var userPointer = c.glfwGetMonitorUserPointer(self.handle);

        glfw.getError() catch |err| switch (err) {
            glfw.Error.NotInitialized => return err,
            else => unreachable,
        };

        return @ptrCast(?*T, userPointer);
    }

    /// This function returns an array of all video modes supported by the
    /// specified monitor. The returned array is sorted in ascending order,
    /// first by color bit depth (the sum of all channel depths) and then by
    /// resolution area (the product of width and height).
    pub fn getVideoModes(self: Self) ![]*const VideoMode {
        var count: i32 = 0;
        var handles = c.glfwGetVideoModes(self.handle, &count);

        glfw.getError() catch |err| switch (err) {
            glfw.Error.NotInitialized, glfw.Error.PlatformError => return err,
            else => unreachable,
        };

        return handles[0..count];
    }

    /// This function returns the current video mode of the specified monitor.
    /// If you have created a full screen window for that monitor, the return
    /// value will depend on whether that window is iconified.
    pub fn getVideoMode(self: Self) !*const VideoMode {
        var videoMode = c.glfwGetVideoMode(self.handle);

        glfw.getError() catch |err| switch (err) {
            glfw.Error.NotInitialized, glfw.Error.PlatformError => return err,
            else => unreachable,
        };

        return videoMode;
    }

    /// This function generates an appropriately sized gamma ramp from the
    /// specified exponent and then calls `setGammaRamp` with it. The value must
    /// be a finite number greater than zero.
    ///
    /// The software controlled gamma ramp is applied in addition to the
    /// hardware gamma correction, which today is usually an approximation of
    /// sRGB gamma. This means that setting a perfectly linear ramp, or gamma
    /// 1.0, will produce the default (usually sRGB-like) behavior.
    ///
    /// For gamma correct rendering with OpenGL or OpenGL ES, see the
    /// `SRGBCapable` hint.
    pub fn setGamma(self: *Self, gamma: f32) !void {
        c.glfwSetGamma(self.handle, gamma);

        glfw.getError() catch |err| switch (err) {
            glfw.Error.NotInitialized, glfw.Error.InvalidValue, glfw.Error.PlatformError => return err,
            else => unreachable,
        };
    }

    /// This function returns the current gamma ramp of the specified monitor.
    pub fn getGammaRamp(self: Self) !GammaRamp {
        var gammaRamp = c.glfwGetGammaRamp(self.handle);

        glfw.getError() catch |err| switch (err) {
            glfw.Error.NotInitialized, glfw.Error.PlatformError => return err,
            else => unreachable,
        };

        return GammaRamp{
            .red = gammaRamp.*.red[0..gammaRamp.*.size],
            .green = gammaRamp.*.green[0..gammaRamp.*.size],
            .blue = gammaRamp.*.blue[0..gammaRamp.*.size],
            .size = gammaRamp.*.size,
        };
    }

    /// This function sets the current gamma ramp for the specified monitor. The
    /// original gamma ramp for that monitor is saved by GLFW the first time
    /// this function is called and is restored by glfwTerminate.
    ///
    /// The software controlled gamma ramp is applied in addition to the
    /// hardware gamma correction, which today is usually an approximation of
    /// sRGB gamma. This means that setting a perfectly linear ramp, or gamma
    /// 1.0, will produce the default (usually sRGB-like) behavior.
    ///
    /// For gamma correct rendering with OpenGL or OpenGL ES, see the
    /// `SRGBCapable` hint.
    pub fn setGammaRamp(self: *Self, gammaRamp: GammaRamp) !void {
        if (gammaRamp.red.len != gammaRamp.size or gammaRamp.green.len != gammaRamp.size or gammaRamp.blue.len != gammaRamp.size) {
            return glfw.Error.InvalidValue;
        }

        var raw = c.GLFWgammaramp{
            .red = gammaRamp.red.ptr,
            .green = gammaRamp.green.ptr,
            .blue = gammaRamp.blue.ptr,
            .size = @intCast(c_uint, gammaRamp.size),
        };

        c.glfwSetGammaRamp(self.handle, &raw);

        glfw.getError() catch |err| switch (err) {
            glfw.Error.NotInitialized, glfw.Error.PlatformError => return err,
            else => unreachable,
        };
    }
};
