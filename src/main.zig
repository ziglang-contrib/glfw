const std = @import("std");
const mem = std.mem;

const builtin = @import("builtin");

const c = @import("./c.zig");
pub usingnamespace @import("./monitor.zig");
pub usingnamespace @import("./window.zig");

/// Video mode type.
pub const VideoMode = c.GLFWvidmode;

/// Gamma ramp type.
pub const GammaRamp = struct {
    red: []c_ushort,
    green: []c_ushort,
    blue: []c_ushort,
    size: usize,
};

/// Image type.
pub const Image = c.GLFWimage;

pub const Size = struct {
    width: i32,
    height: i32,
};

pub const Position = struct {
    x: i32,
    y: i32,
};

pub const Bounds = struct {
    top: i32,
    left: i32,
    bottom: i32,
    right: i32,
};

pub const Scale = struct {
    x: f32,
    y: f32,
};

pub const Error = error{
    /// This occurs if a GLFW function was called that must not be
    /// called unless the library is initialized.
    NotInitialized,
    /// This occurs if a GLFW function was called that needs and
    /// operates on the current OpenGL or OpenGL ES context but no
    /// context is current on the calling thread. One such function is
    /// glfwSwapInterval.
    NoCurrentContext,
    /// One of the arguments to the function was an invalid value, for
    /// example requesting a non-existent OpenGL or OpenGL ES version
    /// like 2.7.
    InvalidValue,
    /// A memory allocation failed.
    OutOfMemory,
    /// GLFW could not find support for the requested API on the system.
    ApiUnavailable,
    /// The requested OpenGL or OpenGL ES version (including any
    /// requested context or framebuffer hints) is not available on this
    /// machine.
    VersionUnavailable,
    /// A platform specific error occured that odes not match any of the more specific categories.
    PlatformError,
    /// If emitted during window creation, the requested pixel format is
    /// not supported.
    ///
    /// If emitted when querying the clipboard, the contents of the
    /// clipboard could not be converted to the requested format.
    FormatUnavailable,
    /// A window that does not have an OpenGL or OpenGL ES context was
    /// passed to a function that requires it to have one.
    NoWindowContext,
};

/// This function returns and clears the error code of the last error
/// that occurred on the calling thread.
pub fn getError() Error!void {
    return switch (c.glfwGetError(null)) {
        c.GLFW_NO_ERROR => return,
        c.GLFW_NOT_INITIALIZED => return Error.NotInitialized,
        c.GLFW_NO_CURRENT_CONTEXT => return Error.NoCurrentContext,
        c.GLFW_INVALID_VALUE => return Error.InvalidValue,
        c.GLFW_OUT_OF_MEMORY => return Error.OutOfMemory,
        c.GLFW_API_UNAVAILABLE => return Error.ApiUnavailable,
        c.GLFW_VERSION_UNAVAILABLE => return Error.VersionUnavailable,
        c.GLFW_PLATFORM_ERROR => return Error.PlatformError,
        c.GLFW_FORMAT_UNAVAILABLE => return Error.FormatUnavailable,
        c.GLFW_NO_WINDOW_CONTEXT => return Error.NoWindowContext,
        else => |code| std.debug.panic("unknown code: {}\n", .{ code }),
    };
}

/// This function initializes the GLFW library. Before most GLFW
/// functions can be used, GLFW must be initialized, and before an
/// application terminates GLFW should be terminated in order to free
/// any resources allocated during or after initialization.
///
/// If this function fails, it calls `deinit` before returning. If it
/// succeeds, you should call `deinit` before the application exits.
///
/// Additional calls to this function after successful initialization
/// but before termination will return GLFW_TRUE immediately.
pub fn init() !void {
    if (c.glfwInit() != c.GLFW_TRUE) {
        getError() catch |err| switch (err) {
            error.PlatformError => return err,
            else => unreachable,
        };
    }

    _ = c.glfwSetErrorCallback(glfwErrorCallback);
    _ = c.glfwSetMonitorCallback(glfwMonitorCallback);
}

/// This function destroys all remaining windows and cursors, restores
/// any modified gamma ramps and frees any other allocated resources.
/// Once this function is called, you must again call `init`
/// successfully before you will be able to use most GLFW functions.
///
/// If GLFW has been successfully initialized, this function should be
/// called before the application exits. If initialization fails, there
/// is no need to call this function, as it is called by `init` before
/// it returns failure.
pub fn deinit() void {
    c.glfwTerminate();
}

pub const HintName = enum(i32) {
    /// Specifies whether to also expose joystick hats as buttons, for
    /// compatibility with earlier versions of GLFW that did not have
    /// `getJoystickHats`.
    JoystickHatButtons = c.GLFW_JOYSTICK_HAT_BUTTONS,
    /// Specifies whether to set the current directory to the
    /// application to the Contents/Resources subdirectory of the
    /// application's bundle, if present.
    CocoaChdirResources = c.GLFW_COCOA_CHDIR_RESOURCES,
    /// Specifies whether to create a basic menu bar, either from a nib
    /// or manually, when the first window is created, which is when
    /// AppKit is initialized.
    CocoaMenubar = c.GLFW_COCOA_MENUBAR,
};

pub const Hint = union(HintName) {
    JoystickHatButtons: bool,
    CocoaChdirResources: bool,
    CocoaMenubar: bool,
};

/// This function sets hints for the next initialization of GLFW.
///
/// The values you set hints to are never reset by GLFW, but they only
/// take effect during initialization. Once GLFW has been initialized,
/// any values you set will be ignored until the library is terminated
/// and initialized again.

/// Some hints are platform specific. These may be set on any platform
/// but they will only affect their specific platform. Other platforms
/// will ignore them. Setting these hints requires no platform specific
/// headers or functions.
pub fn setHint(hint: Hint) void {
    c.glfwInitHint(@enumToInt(hint), switch (hint) {
        .JoystickHatButtons     => |value| toGLFWBool(value),
        .CocoaChdirResources    => |value| toGLFWBool(value),
        .CocoaMenubar           => |value| toGLFWBool(value),
    });
}

fn toGLFWBool(value: bool) i32 {
    return if (value) c.GLFW_TRUE else c.GLFW_FALSE;
}

/// This function retrieves the major, minor and revision numbers of the
/// GLFW library. It is intended for when you are using GLFW as a shared
/// library and want to ensure that you are using the minimum required
/// version.
pub fn getVersion() builtin.Version {
    var major: i32 = 0;
    var minor: i32 = 0;
    var patch: i32 = 0;
    c.glfwGetVersion(&major, &minor, &patch);
    return builtin.Version{ .major = @intCast(u32, major), .minor = @intCast(u32, minor), .patch = @intCast(u32, patch) };
}

/// This function returns the compile-time generated version string of
/// the GLFW library binary. It describes the version, platform,
/// compiler and any platform-specific compile-time options. It should
/// not be confused with the OpenGL or OpenGL ES version string, queried
/// with `glGetString`.
///
/// Do not use the version string to parse the GLFW library version. The
/// `getVersion` function provides the version of the running library
/// binary in numerical format.
pub fn getVersionString() [:0]const u8 {
    const string = c.glfwGetVersionString();
    return mem.spanZ(@as([*:0]const u8, string));
}

/// This is the function pointer type for error callbacks. An error
/// callback function has the following signature:
pub const ErrorCallback = fn(err: Error, description: [:0]const u8) void;

var errorCallback: ?ErrorCallback = null;

fn glfwErrorCallback(code: c_int, description: [*c]const u8) callconv(.C) void {
    if (errorCallback) |callback| {
        var err = switch (c.glfwGetError(null)) {
            c.GLFW_NO_ERROR => return,
            c.GLFW_NOT_INITIALIZED => Error.NotInitialized,
            c.GLFW_NO_CURRENT_CONTEXT => Error.NoCurrentContext,
            c.GLFW_INVALID_VALUE => Error.InvalidValue,
            c.GLFW_OUT_OF_MEMORY => Error.OutOfMemory,
            c.GLFW_API_UNAVAILABLE => Error.ApiUnavailable,
            c.GLFW_VERSION_UNAVAILABLE => Error.VersionUnavailable,
            c.GLFW_PLATFORM_ERROR => Error.PlatformError,
            c.GLFW_FORMAT_UNAVAILABLE => Error.FormatUnavailable,
            c.GLFW_NO_WINDOW_CONTEXT => Error.NoWindowContext,
            else => std.debug.panic("unknown code: {}\n", .{ code }),
        };

        callback(err, mem.spanZ(@as([*:0]const u8, description)));
    }
}

/// This function sets the error callback, which is called with an error
/// code and a human-readable description each time a GLFW error occurs.
///
/// The error code is set before the callback is called. Calling
/// `getError` from the error callback will return the same value as the
/// error code argument.
///
/// The error callback is called on the thread where the error occurred.
/// If you are using GLFW from multiple threads, your error callback
/// needs to be written accordingly.
///
/// Because the description string may have been generated specifically
/// for that error, it is not guaranteed to be valid after the callback
/// has returned. If you wish to use it after the callback returns, you
/// need to make a copy.
///
/// Once set, the error callback remains set even after the library has
/// been terminated.
pub fn setErrorCallback(newErrorCallback: ?ErrorCallback) ?ErrorCallback {
    var oldErrorCallback = errorCallback;
    errorCallback = newErrorCallback;
    return oldErrorCallback;
}

pub const MonitorCallback = fn(monitor: Monitor, event: i32) void;

var monitorCallback: ?MonitorCallback = null;

fn glfwMonitorCallback(handle: ?*c.GLFWmonitor, event: i32) callconv(.C) void {
    if (monitorCallback) |callback| {
        callback(.{ .handle = handle.?, }, event);
    }
}

/// This function sets the monitor configuration callback, or removes
/// the currently set callback. This is called when a monitor is
/// connected to or disconnected from the system.
pub fn setMonitorCallback(newMonitorCallback: ?MonitorCallback) ?MonitorCallback {
    var oldMonitorCallback = monitorCallback;
    monitorCallback = newMonitorCallback;
    return oldMonitorCallback;
}

/// This function processes only those events that are already in the event
/// queue and then returns immediately. Processing events will cause the window
/// and input callbacks associated with those events to be called.
///
/// On some platforms, a window move, resize or menu operation will cause event
/// processing to block. This is due to how event processing is designed on
/// those platforms. You can use the window refresh callback to redraw the
/// contents of your window when necessary during such operations.
///
/// Do not assume that callbacks you set will only be called in response to
/// event processing functions like this one. While it is necessary to poll for
/// events, window systems that require GLFW to register callbacks of its own
/// can pass events to GLFW in response to many window system function calls.
/// GLFW will pass those events on to the application callbacks before
/// returning.
///
/// Event processing is not required for joystick input to work.
pub fn pollEvents() !void {
    c.glfwPollEvents();

    getError() catch |err| switch (err) {
        Error.NotInitialized,
        Error.PlatformError => return err,
        else => unreachable,
    };
}

/// This function puts the calling thread to sleep until at least one event is
/// available in the event queue. Once one or more events are available, it
/// behaves exactly like `pollEvents`, i.e. the events in the queue are
/// processed and the function then returns immediately. Processing events will
/// cause the window and input callbacks associated with those events to be
/// called.
///
/// Since not all events are associated with callbacks, this function may return
/// without a callback having been called even if you are monitoring all
/// callbacks.
///
/// On some platforms, a window move, resize or menu operation will cause event
/// processing to block. This is due to how event processing is designed on
/// those platforms. You can use the window refresh callback to redraw the
/// contents of your window when necessary during such operations.
///
/// Do not assume that callbacks you set will only be called in response to
/// event processing functions like this one. While it is necessary to poll for
/// events, window systems that require GLFW to register callbacks of its own
/// can pass events to GLFW in response to many window system function calls.
/// GLFW will pass those events on to the application callbacks before
/// returning.
///
/// Event processing is not required for joystick input to work.
pub fn waitEvents() !void {
    c.glfwWaitEvents();

    getError() catch |err| switch (err) {
        Error.NotInitialized,
        Error.PlatformError => return err,
        else => unreachable,
    };
}

/// This function puts the calling thread to sleep until at least one event is
/// available in the event queue, or until the specified timeout is reached. If
/// one or more events are available, it behaves exactly like `pollEvents`,
// i.e. the events in the queue are processed and the function then returns
/// immediately. Processing events will cause the window and input callbacks
/// associated with those events to be called.
///
/// The timeout value must be a positive finite number.
///
/// Since not all events are associated with callbacks, this function may return
/// without a callback having been called even if you are monitoring all
/// callbacks.
///
/// On some platforms, a window move, resize or menu operation will cause event
/// processing to block. This is due to how event processing is designed on
/// those platforms. You can use the window refresh callback to redraw the
/// contents of your window when necessary during such operations.
///
/// Do not assume that callbacks you set will only be called in response to
/// event processing functions like this one. While it is necessary to poll for
/// events, window systems that require GLFW to register callbacks of its own
/// can pass events to GLFW in response to many window system function calls.
/// GLFW will pass those events on to the application callbacks before
/// returning.
///
/// Event processing is not required for joystick input to work.
pub fn waitEventsTimeout(timeout: f64) !void {
    c.glfwWaitEventsTimeout(timeout);

    getError() catch |err| switch (err) {
        Error.NotInitialized,
        Error.PlatformError => return err,
        else => unreachable,
    };
}

/// This function posts an empty event from the current thread to the event
/// queue, causing `waitEvents` or `waitEventsTimeout` to return.
pub fn postEmptyEvent() !void {
    c.glfwPostEmptyEvent();

    getError() catch |err| switch (err) {
        Error.NotInitialized,
        Error.PlatformError => return err,
        else => unreachable,
    };
}
