const std = @import("std");
const mem = std.mem;

const c = @import("./c.zig");
const glfw = @import("./main.zig");

/// Opaque window object.
pub const Window = struct {
    const Self = @This();

    handle: *c.GLFWwindow,

    pub const ClientApi = enum(i32) {
        OpenGLApi   = c.GLFW_OPENGL_API,
        OpenGLESApi = c.GLFW_OPENGL_ES_API,
        NoApi       = c.GLFW_NO_API,
    };

    pub const ContextCreationApi = enum(i32) {
        NativeContextApi    = c.GLFW_NATIVE_CONTEXT_API,
        EGLContextApi       = c.GLFW_EGL_CONTEXT_API,
        OSMesaContextApi    = c.GLFW_OSMESA_CONTEXT_API,
    };

    pub const ContextRobustness = enum(i32) {
        NoRobustness        = c.GLFW_NO_ROBUSTNESS,
        NoResetNotification = c.GLFW_NO_RESET_NOTIFICATION,
        LoseContextOnReset  = c.GLFW_LOSE_CONTEXT_ON_RESET,
    };

    pub const ContextReleaseBehavior = enum(i32) {
        AnyReleaseBehavior      = c.GLFW_ANY_RELEASE_BEHAVIOR,
        ReleaseBehaviorFlush    = c.GLFW_RELEASE_BEHAVIOR_FLUSH,
        ReleaseBehaviorNone     = c.GLFW_RELEASE_BEHAVIOR_NONE,
    };

    pub const OpenGLProfile = enum(i32) {
        OpenGLAnyProfile = c.GLFW_OPENGL_ANY_PROFILE,
        OpenGLCompatProfile = c.GLFW_OPENGL_COMPAT_PROFILE,
        OpenGLCoreProfile = c.GLFW_OPENGL_CORE_PROFILE,
    };

    pub const HintName = enum(i32) {
        Resizable               = c.GLFW_RESIZABLE,
        Visible                 = c.GLFW_VISIBLE,
        Decorated               = c.GLFW_DECORATED,
        DepthBits               = c.GLFW_DEPTH_BITS,
        Focused                 = c.GLFW_FOCUSED,
        AutoIconify             = c.GLFW_AUTO_ICONIFY,
        Floating                = c.GLFW_FLOATING,
        Maximized               = c.GLFW_MAXIMIZED,
        CenterCursor            = c.GLFW_CENTER_CURSOR,
        TransparentFramebuffer  = c.GLFW_TRANSPARENT_FRAMEBUFFER,
        FocusOnShow             = c.GLFW_FOCUS_ON_SHOW,
        ScaleToMonitor          = c.GLFW_SCALE_TO_MONITOR,
        RedBits                 = c.GLFW_RED_BITS,
        GreenBits               = c.GLFW_GREEN_BITS,
        BlueBits                = c.GLFW_BLUE_BITS,
        AlphaBits               = c.GLFW_ALPHA_BITS,
        AccumRedBits            = c.GLFW_ACCUM_RED_BITS,
        AccumGreenBits          = c.GLFW_ACCUM_GREEN_BITS,
        AccumBlueBits           = c.GLFW_ACCUM_BLUE_BITS,
        AccumAlphaBits          = c.GLFW_ACCUM_ALPHA_BITS,
        AuxBuffers              = c.GLFW_AUX_BUFFERS,
        Stereo                  = c.GLFW_STEREO,
        StencilBits             = c.GLFW_STENCIL_BITS,
        Samples                 = c.GLFW_SAMPLES,
        SRGBCapable             = c.GLFW_SRGB_CAPABLE,
        DoubleBuffer            = c.GLFW_DOUBLEBUFFER,
        RefreshRate             = c.GLFW_REFRESH_RATE,
        ClientApi               = c.GLFW_CLIENT_API,
        ContextCreationApi      = c.GLFW_CONTEXT_CREATION_API,
        ContextVersionMajor     = c.GLFW_CONTEXT_VERSION_MAJOR,
        ContextVersionMinor     = c.GLFW_CONTEXT_VERSION_MINOR,
        OpenGLForwardCompat     = c.GLFW_OPENGL_FORWARD_COMPAT,
        OpenGLDebugContext      = c.GLFW_OPENGL_DEBUG_CONTEXT,
        OpenGLProfile           = c.GLFW_OPENGL_PROFILE,
        ContextRobustness       = c.GLFW_CONTEXT_ROBUSTNESS,
        ContextReleaseBehavior  = c.GLFW_CONTEXT_RELEASE_BEHAVIOR,
        ContextNoError          = c.GLFW_CONTEXT_NO_ERROR,
        CocoaRetinaFramebuffer  = c.GLFW_COCOA_RETINA_FRAMEBUFFER,
        CocoaFrameName          = c.GLFW_COCOA_FRAME_NAME,
        CocoaGraphicsSwitching  = c.GLFW_COCOA_GRAPHICS_SWITCHING,
        X11ClassName            = c.GLFW_X11_CLASS_NAME,
        X11InstanceName         = c.GLFW_X11_INSTANCE_NAME,
    };

    pub const Hint = union(HintName) {
        ContextNoError: bool,
        Resizable: bool,
        Visible: bool,
        Decorated: bool,
        Focused: bool,
        AutoIconify: bool,
        Floating: bool,
        Maximized: bool,
        CenterCursor: bool,
        TransparentFramebuffer: bool,
        FocusOnShow: bool,
        ScaleToMonitor: bool,
        RedBits: ?i32,
        GreenBits: ?i32,
        BlueBits: ?i32,
        AlphaBits: ?i32,
        DepthBits: ?i32,
        StencilBits: ?i32,
        AccumRedBits: ?i32,
        AccumGreenBits: ?i32,
        AccumBlueBits: ?i32,
        AccumAlphaBits: ?i32,
        AuxBuffers: ?i32,
        Samples: ?i32,
        RefreshRate: ?i32,
        Stereo: bool,
        SRGBCapable: bool,
        DoubleBuffer: bool,
        ClientApi: ClientApi,
        ContextCreationApi: ContextCreationApi,
        ContextVersionMajor: i32,
        ContextVersionMinor: i32,
        ContextRobustness: ContextRobustness,
        ContextReleaseBehavior: ContextReleaseBehavior,
        OpenGLForwardCompat: bool,
        OpenGLDebugContext: bool,
        OpenGLProfile: OpenGLProfile,
        CocoaRetinaFramebuffer: bool,
        CocoaFrameName: [:0]const u8,
        CocoaGraphicsSwitching: bool,
        X11ClassName: [:0]const u8,
        X11InstanceName: [:0]const u8,
    };

    pub fn defaultHints() void {
        c.glfwDefaultWindowHints();

        glfw.getError() catch |err| switch (err) {
            .NotInitialized => return err,
            else => unreachable,
        };
    }

    /// This function sets hints for the next call to `Window.init`. The hints,
    /// once set, retain their values until changed by a call to this function
    /// or `Window.defaultHints`, or until the library is terminated.
    ///
    /// This function does not check whether the specified hint values are
    /// valid. If you set hints to invalid values this will instead be reported
    /// by the next call to `Window.init`.
    ///
    /// Some hints are platform specific. These may be set on any platform but
    /// they will only affect their specific platform. Other platforms will
    /// ignore them. Setting these hints requires no platform specific headers
    /// or functions.
    pub fn hint(hint: Hint) !void {
        switch (hint) {
            .ContextNoError         => |value| c.glfwWindowHint(@enumToInt(hint), toGLFWBool(value)),
            .Resizable              => |value| c.glfwWindowHint(@enumToInt(hint), toGLFWBool(value)),
            .Visible                => |value| c.glfwWindowHint(@enumToInt(hint), toGLFWBool(value)),
            .Decorated              => |value| c.glfwWindowHint(@enumToInt(hint), toGLFWBool(value)),
            .Focused                => |value| c.glfwWindowHint(@enumToInt(hint), toGLFWBool(value)),
            .AutoIconify            => |value| c.glfwWindowHint(@enumToInt(hint), toGLFWBool(value)),
            .Floating               => |value| c.glfwWindowHint(@enumToInt(hint), toGLFWBool(value)),
            .Maximized              => |value| c.glfwWindowHint(@enumToInt(hint), toGLFWBool(value)),
            .CenterCursor           => |value| c.glfwWindowHint(@enumToInt(hint), toGLFWBool(value)),
            .TransparentFramebuffer => |value| c.glfwWindowHint(@enumToInt(hint), toGLFWBool(value)),
            .FocusOnShow            => |value| c.glfwWindowHint(@enumToInt(hint), toGLFWBool(value)),
            .ScaleToMonitor         => |value| c.glfwWindowHint(@enumToInt(hint), toGLFWBool(value)),
            .RedBits                => |value| c.glfwWindowHint(@enumToInt(hint), toGLFWInt(value)),
            .GreenBits              => |value| c.glfwWindowHint(@enumToInt(hint), toGLFWInt(value)),
            .BlueBits               => |value| c.glfwWindowHint(@enumToInt(hint), toGLFWInt(value)),
            .AlphaBits              => |value| c.glfwWindowHint(@enumToInt(hint), toGLFWInt(value)),
            .DepthBits              => |value| c.glfwWindowHint(@enumToInt(hint), toGLFWInt(value)),
            .StencilBits            => |value| c.glfwWindowHint(@enumToInt(hint), toGLFWInt(value)),
            .AccumRedBits           => |value| c.glfwWindowHint(@enumToInt(hint), toGLFWInt(value)),
            .AccumGreenBits         => |value| c.glfwWindowHint(@enumToInt(hint), toGLFWInt(value)),
            .AccumBlueBits          => |value| c.glfwWindowHint(@enumToInt(hint), toGLFWInt(value)),
            .AccumAlphaBits         => |value| c.glfwWindowHint(@enumToInt(hint), toGLFWInt(value)),
            .AuxBuffers             => |value| c.glfwWindowHint(@enumToInt(hint), toGLFWInt(value)),
            .Samples                => |value| c.glfwWindowHint(@enumToInt(hint), toGLFWInt(value)),
            .RefreshRate            => |value| c.glfwWindowHint(@enumToInt(hint), toGLFWInt(value)),
            .Stereo                 => |value| c.glfwWindowHint(@enumToInt(hint), toGLFWBool(value)),
            .SRGBCapable            => |value| c.glfwWindowHint(@enumToInt(hint), toGLFWBool(value)),
            .DoubleBuffer           => |value| c.glfwWindowHint(@enumToInt(hint), toGLFWBool(value)),
            .ClientApi              => |value| c.glfwWindowHint(@enumToInt(hint), @enumToInt(value)),
            .ContextCreationApi     => |value| c.glfwWindowHint(@enumToInt(hint), @enumToInt(value)),
            .ContextVersionMajor    => |value| c.glfwWindowHint(@enumToInt(hint), toGLFWInt(value)),
            .ContextVersionMinor    => |value| c.glfwWindowHint(@enumToInt(hint), toGLFWInt(value)),
            .ContextRobustness      => |value| c.glfwWindowHint(@enumToInt(hint), @enumToInt(value)),
            .ContextReleaseBehavior => |value| c.glfwWindowHint(@enumToInt(hint), @enumToInt(value)),
            .OpenGLForwardCompat    => |value| c.glfwWindowHint(@enumToInt(hint), toGLFWBool(value)),
            .OpenGLDebugContext     => |value| c.glfwWindowHint(@enumToInt(hint), toGLFWBool(value)),
            .OpenGLProfile          => |value| c.glfwWindowHint(@enumToInt(hint), @enumToInt(value)),
            .CocoaRetinaFramebuffer => |value| c.glfwWindowHint(@enumToInt(hint), toGLFWBool(value)),
            .CocoaFrameName         => |value| c.glfwWindowHintString(@enumToInt(hint), value.ptr),
            .CocoaGraphicsSwitching => |value| c.glfwWindowHint(@enumToInt(hint), toGLFWBool(value)),
            .X11ClassName           => |value| c.glfwWindowHintString(@enumToInt(hint), value.ptr),
            .X11InstanceName        => |value| c.glfwWindowHintString(@enumToInt(hint), value.ptr),
        }

        glfw.getError() catch |err| switch (err) {
            error.NotInitialized => return err,
            else => unreachable,
        };
    }

    pub const AttributeName = enum(i32) {
        Focused                 = c.GLFW_FOCUSED,
        Iconified               = c.GLFW_ICONIFIED,
        Maximized               = c.GLFW_MAXIMIZED,
        Hovered                 = c.GLFW_HOVERED,
        Visible                 = c.GLFW_VISIBLE,
        Resizable               = c.GLFW_RESIZABLE,
        Decorated               = c.GLFW_DECORATED,
        AutoIconify             = c.GLFW_AUTO_ICONIFY,
        Floating                = c.GFLW_FLOATING,
        TransparentFramebuffer  = c.GLFW_TRANSPARENT_FRAMEBUFFER,
        FocusOnShow             = c.GLFW_FOCUS_ON_SHOW,
        ClientApi               = c.GLFW_CLIENT_API,
        ContextCreationApi      = c.GLFW_CONTEXT_CREATION_API,
        ContextVersionMajor     = c.GLFW_CONTEXT_VERSION_MAJOR,
        ContextVersionMinor     = c.GLFW_CONTEXT_VERSION_MINOR,
        ContextRevision         = c.GLFW_CONTEXT_REVISION,
        OpenGLForwardCompat     = c.GLFW_OPENGL_FORWARD_COMPAT,
        OpenGLDebugContext      = c.GLFW_OPENGGL_DEBUG_CONTEXT,
        OpenGLProfile           = c.GLFW_OPENGL_PROFILE,
        ContextReleaseBehavior  = c.GLFW_CONTEXT_RELEASE_BEHAVIOR,
        ContextNoError          = c.GLFW_CONTEXT_NO_ERROR,
        ContextRobustness       = c.GLFW_CONTEXT_ROBUSTNESS,
    };

    pub const Attribute = union(AttributeName) {
        Focused: bool,
        Iconified: bool,
        Maximized: bool,
        Hovered: bool,
        Visible: bool,
        Resizable: bool,
        Decorated: bool,
        AutoIconify: bool,
        Floating: bool,
        TransparentFramebuffer: bool,
        FocusOnShow: bool,
        ClientApi: ClientApi,
        ContextCreationApi: ContextCreationApi,
        ContextVersionMajor: i32,
        ContextVersionMinor: i32,
        ContextRevision: i32,
        OpenGLForwardCompat: bool,
        OpenGLDebugContext: bool,
        OpenGLProfile: OpenGLProfile,
        ContextReleaseBehavior: ContextReleaseBehavior,
        ContextNoError: bool,
        ContextRobustness: ContextRobustness,
    };

    /// This function returns the value of an attribute of the specified window
    /// or its OpenGL or OpenGL ES context.
    pub fn getAttrib(self: Self, attrib: AttributeName) !Attribute {
        var attribute = blk: { switch (attrib) {
            .Focused
                => {
                    var value = c.glfwGetWindowAttrib(self.handle, @enumToInt(attrib));
                    break :blk Attribute{ .Focused = value == c.GLFW_TRUE };
                },
            .Iconified
                => {
                    var value = c.glfwGetWindowAttrib(self.handle, @enumToInt(attrib));
                    break :blk Attribute{ .Iconified = value == c.GLFW_TRUE };
                },
            .Maximized
                => {
                    var value = c.glfwGetWindowAttrib(self.handle, @enumToInt(attrib));
                    break :blk Attribute{ .Maximized = value == c.GLFW_TRUE };
                },
            .Hovered
                => {
                    var value = c.glfwGetWindowAttrib(self.handle, @enumToInt(attrib));
                    break :blk Attribute{ .Hovered = value == c.GLFW_TRUE };
                },
            .Visible
                => {
                    var value = c.glfwGetWindowAttrib(self.handle, @enumToInt(attrib));
                    break :blk Attribute{ .Visible = value == c.GLFW_TRUE };
                },
            .Resizable
                => {
                    var value = c.glfwGetWindowAttrib(self.handle, @enumToInt(attrib));
                    break :blk Attribute{ .Resizable = value == c.GLFW_TRUE };
                },
            .Decorated
                => {
                    var value = c.glfwGetWindowAttrib(self.handle, @enumToInt(attrib));
                    break :blk Attribute{ .Decorated = value == c.GLFW_TRUE };
                },
            .AutoIconify
                => {
                    var value = c.glfwGetWindowAttrib(self.handle, @enumToInt(attrib));
                    break :blk Attribute{ .AutoIconify = value == c.GLFW_TRUE };
                },
            .Floating
                => {
                    var value = c.glfwGetWindowAttrib(self.handle, @enumToInt(attrib));
                    break :blk Attribute{ .Floating = value == c.GLFW_TRUE };
                },
            .TransparentFramebuffer
                => {
                    var value = c.glfwGetWindowAttrib(self.handle, @enumToInt(attrib));
                    break :blk Attribute{ .TransparentFramebuffer = value == c.GLFW_TRUE };
                },
            .FocusOnShow
                => {
                    var value = c.glfwGetWindowAttrib(self.handle, @enumToInt(attrib));
                    break :blk Attribute{ .FocusOnShow = value == c.GLFW_TRUE };
                },
            .ClientApi
                => {
                    var value = @intToEnum(ClientApi, c.glfwGetWindowAttrib(self.handle, @enumToInt(attrib)));
                    break :blk Attribute{ .ClientApi = value, };
                },
            .ContextCreationApi
                => {
                    var value = @intToEnum(ContextCreationApi, c.glfwGetWindowAttrib(self.handle, @enumToInt(attrib)));
                    break :blk Attribute{ .ContextCreationApi = value, };
                },
            .ContextVersionMajor
                => {
                    var value = c.glfwGetWindowAttrib(self.handle, @enumToInt(attrib));
                    break :blk Attribute{ .ContextVersionMajor = value, };
                },
            .ContextVersionMinor
                => {
                    var value = c.glfwGetWindowAttrib(self.handle, @enumToInt(attrib));
                    break :blk Attribute{ .ContextVersionMinor = value, };
                },
            .ContextRevision
                => {
                    var value = c.glfwGetWindowAttrib(self.handle, @enumToInt(attrib));
                    break :blk Attribute{ .ContextRevision = value, };
                },
            .OpenGLForwardCompat
                => {
                    var value = c.glfwGetWindowAttrib(self.handle, @enumToInt(attrib));
                    break :blk Attribute{ .OpenGLForwardCompat = value == c.GLFW_TRUE };
                },
            .OpenGLDebugContext
                => {
                    var value = c.glfwGetWindowAttrib(self.handle, @enumToInt(attrib));
                    break :blk Attribute{ .OpenGLDebugContext = value == c.GLFW_TRUE };
                },
            .OpenGLProfile
                => {
                    var value = @intToEnum(OpenGLProfile, c.glfwGetWindowAttrib(self.handle, @enumToInt(attrib)));
                    break :blk Attribute{ .OpenGLProfile = value, };
                },
            .ContextReleaseBehavior
                => {
                    var value = @intToEnum(ContextReleaseBehavior, c.glfwGetWindowAttrib(self.handle, @enumToInt(attrib)));
                    break :blk Attribute{ .ContextReleaseBehavior = value, };
                },
            .ContextNoError
                => {
                    var value = c.glfwGetWindowAttrib(self.handle, @enumToInt(attrib));
                    break :blk Attribute{ .ContextNoError = value == c.GLFW_TRUE };
                },
            .ContextRobustness
                => {
                    var value = @intToEnum(ContextRobustness, c.glfwGetWindowAttrib(self.handle, @enumToInt(attrib)));
                    break :blk Attribute{ .ContextRobustness = value, };
                },
        } };

        glfw.getError() catch |err| switch (err) {
            glfw.Error.NotInitialized,
            glfw.Error.PlatformError => return err,
            else => unreachable,
        };

        return attribute;
    }

    /// This function sets the value of an attribute of the specified window.
    ///
    /// The supported attributes are `Decorated`, `Resizable`, `Floating`,
    /// `AutoIconify` and `FocusOnShow`.
    ///
    /// Some of these attributes are ignored for full screen windows. The new
    /// value will take effect if the window is later made windowed.
    ///
    /// Some of these attributes are ignored for windowed mode windows. The new
    /// value will take effect if the window is later made full screen.
    pub fn setAttrib(self: *Self, attribute: Attribute) !void {
        switch (attribute) {
            Resizable               => |value| c.glfwSetWindowAttrib(self.handle, @enumToInt(attribute), toGLFWBool(value)),
            Decorated               => |value| c.glfwSetWindowAttrib(self.handle, @enumToInt(attribute), toGLFWBool(value)),
            AutoIconify             => |value| c.glfwSetWindowAttrib(self.handle, @enumToInt(attribute), toGLFWBool(value)),
            Floating                => |value| c.glfwSetWindowAttrib(self.handle, @enumToInt(attribute), toGLFWBool(value)),
            FocusOnShow             => |value| c.glfwSetWindowAttrib(self.handle, @enumToInt(attribute), toGLFWBool(value)),
            else => std.debug.panic("unsupported attribute in setter"),
        }

        glfw.getError() catch |err| switch (err) {
            glfw.Error.NotInitialized,
            glfw.Error.PlatformError => return err,
            else => unreachable,
        };
    }

    fn toGLFWBool(value: bool) callconv(.Inline) i32 {
        return if (value) c.GLFW_TRUE else c.GLFW_FALSE;
    }

    fn toGLFWInt(value: ?i32) callconv(.Inline) i32 {
        return if (value) |v| v else c.GLFW_DONT_CARE;
    }

    /// This function creates a window and its associated OpenGL or OpenGL ES
    /// context. Most of the options controlling how the window and its context
    /// should be created are specified with window hints.
    ///
    /// Successful creation does not change which context is current. Before you
    /// can use the newly created context, you need to make it current. For
    /// information about the share parameter, see Context object sharing.
    ///
    /// The created window, framebuffer and context may differ from what you
    /// requested, as not all parameters and hints are hard constraints. This
    /// includes the size of the window, especially for full screen windows. To
    /// query the actual attributes of the created window, framebuffer and
    /// context, see `WIndow.getAttrib`, `Window.getSize` and
    /// `Window.getFramebufferSize`.
    ///
    /// To create a full screen window, you need to specify the monitor the
    /// window will cover. If no monitor is specified, the window will be
    /// windowed mode. Unless you have a way for the user to choose a specific
    /// monitor, it is recommended that you pick the primary monitor. For more
    /// information on how to query connected monitors, see Retrieving monitors.
    ///
    /// For full screen windows, the specified size becomes the resolution of
    /// the window's desired video mode. As long as a full screen window is not
    /// iconified, the supported video mode most closely matching the desired
    /// video mode is set for the specified monitor. For more information about
    /// full screen windows, including the creation of so called windowed full
    /// screen or borderless full screen windows, see "Windowed full screen"
    /// windows.
    ///
    /// Once you have created the window, you can switch it between windowed and
    /// full screen mode with REPLACEME(glfwSetWindowMonitor). This will not affect its
    /// OpenGL or OpenGL ES context.
    ///
    /// By default, newly created windows use the placement recommended by the
    /// window system. To create the window at a specific position, make it
    /// initially invisible using the `Visible` window hint, set its position
    /// and then show it.
    ///
    /// As long as at least one full screen window is not iconified, the
    /// screensaver is prohibited from starting.
    ///
    /// Window systems put limits on window sizes. Very large or very small
    /// window dimensions may be overridden by the window system on creation.
    /// Check the actual size after creation.
    ///
    /// The swap interval is not set during window creation and the initial value may vary depending on driver settings and defaults.
    pub fn init(width: i32, height: i32, title: [:0]const u8, monitor: ?glfw.Monitor, share: ?glfw.Window) !Self {
        var handle = c.glfwCreateWindow(width, height, title.ptr, if (monitor) |m| m.handle else null, if (share) |s| s.handle else null);

        if (handle == null) {
            glfw.getError() catch |err| switch (err) {
                glfw.Error.NotInitialized,
                glfw.Error.InvalidValue,
                glfw.Error.ApiUnavailable,
                glfw.Error.VersionUnavailable,
                glfw.Error.FormatUnavailable,
                glfw.Error.PlatformError => return err,
                else => unreachable,
            };
        }

        return Self{ .handle = handle.? };
    }

    /// This function destroys the specified window and its context. On calling
    /// this function, no further callbacks will be called for that window.
    ///
    /// If the context of the specified window is current on the main thread, it
    /// is detached before being destroyed.
    pub fn deinit(self: *Self) void {
        c.glfwDestroyWindow(self.handle);

        glfw.getError() catch |err| switch (err) {
            glfw.Error.NotInitialized,
            glfw.Error.PlatformError => std.debug.panic("cannot handle: {}\n", .{ err }),
            else => unreachable,
        };
    }

    /// This function returns the value of the close flag of the specified
    /// window.
    pub fn shouldClose(self: Self) !bool {
        var result = c.glfwWindowShouldClose(self.handle);

        glfw.getError() catch |err| switch (err) {
            glfw.Error.NotInitialized => return err,
            else => unreachable,
        };

        return result == c.GLFW_TRUE;
    }

    /// This function sets the value of the close flag of the specified window.
    /// This can be used to override the user's attempt to close the window, or
    /// to signal that it should be closed.
    pub fn setShouldClose(self: *Self, value: bool) !void {
        c.glfwSetWindowShouldClose(self.handle, toGLFWBool(value));

        glfw.getError() catch |err| switch (err) {
            glfw.Error.NotInitialized => return err,
            else => unreachable,
        };
    }

    /// This function sets the window title, encoded as UTF-8, of the specified
    /// window.
    pub fn setTitle(self: *Self, title: [:0]const u8) !void {
        c.glfwSetWindowTitle(self.handle, title.ptr);

        glfw.getError() catch |err| switch (err) {
            glfw.Error.NotInitialized,
            glfw.Error.PlatformError => return err,
            else => unreachable,
        };
    }

    /// This function sets the icon of the specified window. If passed an array
    /// of candidate images, those of or closest to the sizes desired by the
    /// system are selected. If no images are specified, the window reverts to
    /// its default icon.
    ///
    /// The pixels are 32-bit, little-endian, non-premultiplied RGBA, i.e. eight
    /// bits per channel with the red channel first. They are arranged
    /// canonically as packed sequential rows, starting from the top-left
    /// corner.
    ///
    /// The desired image sizes varies depending on platform and system
    /// settings. The selected images will be rescaled as needed. Good sizes
    /// include 16x16, 32x32 and 48x48.
    pub fn setIcon(self: *Self, icon: glfw.Image) !void {
        return self.setIcons(&[1]glfw.Image{ icon });
    }

    /// This function sets the icon of the specified window. If passed an array
    /// of candidate images, those of or closest to the sizes desired by the
    /// system are selected. If no images are specified, the window reverts to
    /// its default icon.
    ///
    /// The pixels are 32-bit, little-endian, non-premultiplied RGBA, i.e. eight
    /// bits per channel with the red channel first. They are arranged
    /// canonically as packed sequential rows, starting from the top-left
    /// corner.
    ///
    /// The desired image sizes varies depending on platform and system
    /// settings. The selected images will be rescaled as needed. Good sizes
    /// include 16x16, 32x32 and 48x48.
    pub fn setIcons(self: *Self, icons: []glfw.Image) !void {
        c.glfwSetWindowIcon(self.handle, @intCast(i32, icons.len), icons.ptr);

        glfw.getError() catch |err| switch (err) {
            glfw.Error.NotInitialized,
            glfw.Error.PlatformError => return err,
            else => unreachable,
        };
    }

    pub const Position = struct {
        x: i32,
        y: i32,
    };

    /// This function retrieves the position, in screen coordinates, of the
    /// upper-left corner of the content area of the specified window.
    pub fn getPos(self: Self) !Position {
        var position: Position = undefined;

        c.glfwGetWindowPos(self.handle, &position.x, &position.y);

        glfw.getError() catch |err| switch (err) {
            glfw.Error.NotInitialized,
            glfw.Error.PlatformError => return err,
            else => unreachable,
        };

        return position;
    }

    /// This function sets the position, in screen coordinates, of the
    /// upper-left corner of the content area of the specified windowed mode
    /// window. If the window is a full screen window, this function does
    /// nothing.
    ///
    /// Do not use this function to move an already visible window unless you
    /// have very good reasons for doing so, as it will confuse and annoy the
    /// user.
    ///
    /// The window manager may put limits on what positions are allowed. GLFW
    /// cannot and should not override these limits.
    pub fn setPos(self: *Self, position: Position) !void {
        c.glfwSetWindowPos(self.handle, position.x, position.y);

        glfw.getError() catch |err| switch (err) {
            glfw.Error.NotInitialized,
            glfw.Error.PlatformError => return err,
            else => unreachable,
        };
    }

    /// This function retrieves the size, in screen coordinates, of the content
    /// area of the specified window. If you wish to retrieve the size of the
    /// framebuffer of the window in pixels, see `Window.getFramebufferSize`.
    pub fn getSize(self: Self) !glfw.Size {
        var size: glfw.Size = undefined;

        c.glfwGetWindowSize(self.handle, &size.width, &size.height);

        glfw.getError() catch |err| switch (err) {
            glfw.Error.NotInitialized,
            glfw.Error.PlatformError => return err,
            else => unreachable,
        };

        return size;
    }

    /// This function sets the size, in screen coordinates, of the content area
    /// of the specified window.
    ///
    /// For full screen windows, this function updates the resolution of its
    /// desired video mode and switches to the video mode closest to it, without
    /// affecting the window's context. As the context is unaffected, the bit
    /// depths of the framebuffer remain unchanged.
    ///
    /// If you wish to update the refresh rate of the desired video mode in
    /// addition to its resolution, see REPLACEME(glfwSetWindowMonitor).
    ///
    /// The window manager may put limits on what sizes are allowed. GLFW cannot
    /// and should not override these limits.
    pub fn setSize(self: Self, size: glfw.Size) !void {
        c.glfwSetWindowSize(self.handle, size.width, size.height);

        glfw.getError() catch |err| switch (err) {
            glfw.Error.NotInitialized,
            glfw.Error.PlatformError => return err,
            else => unreachable,
        };
    }

    /// This function sets the size limits of the content area of the specified
    /// window. If the window is full screen, the size limits only take effect
    /// once it is made windowed. If the window is not resizable, this function
    /// does nothing.
    ///
    /// The size limits are applied immediately to a windowed mode window and
    /// may cause it to be resized.
    ///
    /// The maximum dimensions must be greater than or equal to the minimum
    /// dimensions and all must be greater than or equal to zero.
    pub fn setSizeLimits(self: *Self, min: ?glfw.Size, max: ?glfw.Size) !void {
        var minwidth: i32 = if (min) |m| m.width else c.GLFW_DONT_CARE;
        var minheight: i32 = if (min) |m| m.height else c.GLFW_DONT_CARE;
        var maxwidth: i32 = if (max) |m| m.width else c.GLFW_DONT_CARE;
        var maxheight: i32 = if (max) |m| m.height else c.GLFW_DONT_CARE;

        c.glfwSetWindowSizeLimits(self.handle, minwidth, minheight, maxwidth, maxheight);

        glfw.getError() catch |err| switch (err) {
            glfw.Error.NotInitialized,
            glfw.Error.PlatformError => return err,
            else => unreachable,
        };
    }

    /// This function sets the required aspect ratio of the content area of the
    /// specified window. If the window is full screen, the aspect ratio only
    /// takes effect once it is made windowed. If the window is not resizable,
    /// this function does nothing.
    ///
    /// The aspect ratio is specified as a numerator and a denominator and both
    /// values must be greater than zero. For example, the common 16:9 aspect
    /// ratio is specified as 16 and 9, respectively.
    ///
    /// If the aspect is `null`, then the aspect ratio limit is disabled.
    pub fn setAspectRatio(self: *Self, aspect: ?glfw.Size) !void {
        if (aspect) |a| {
            c.glfwSetWindowAspectRatio(self.handle, a.width, a.height);
        } else {
            c.glfwSetWindowAspectRatio(self.handle, c.GLFW_DONT_CARE, c.GLFW_DONT_CARE);
        }

        glfw.getError() catch |err| switch (err) {
            glfw.Error.NotInitialized,
            glfw.Error.PlatformError => return err,
            else => unreachable,
        };
    }

    /// This function retrieves the size, in pixels, of the framebuffer of the
    /// specified window. If you wish to retrieve the size of the window in
    /// screen coordinates, see `Window.getSize`.
    pub fn getFramebufferSize(self: Self) !glfw.Size {
        var framebufferSize: glfw.Size = undefined;

        c.glfwGetFramebufferSize(self.handle, &framebufferSize.width, &framebufferSize.height);

        glfw.getError() catch |err| switch (err) {
            glfw.Error.NotInitialized,
            glfw.Error.PlatformError => return err,
            else => unreachable,
        };

        return framebufferSize;
    }

    /// This function retrieves the size, in screen coordinates, of each edge of
    /// the frame of the specified window. This size includes the title bar, if
    /// the window has one. The size of the frame may vary depending on the
    /// window-related hints used to create it.
    ///
    /// Because this function retrieves the size of each window frame edge and
    /// not the offset along a particular coordinate axis, the retrieved values
    /// will always be zero or positive.
    pub fn getFrameSize(self: Self) !glfw.Bounds {
        var frameSize: glfw.Bounds = undefined;

        c.glfwGetWindowFrameSize(self.handle, &frameSize.left, &frameSize.top, &frameSize.right, &frameSize.bottom);

        glfw.getError() catch |err| switch (err) {
            glfw.Error.NotInitialized,
            glfw.Error.PlatformError => return err,
            else => unreachable,
        };

        return frameSize;
    }

    /// This function retrieves the content scale for the specified window. The
    /// content scale is the ratio between the current DPI and the platform's
    /// default DPI. This is especially important for text and any UI elements.
    /// If the pixel dimensions of your UI scaled by this look appropriate on
    /// your machine then it should appear at a reasonable size on other
    /// machines regardless of their DPI and scaling settings. This relies on
    /// the system DPI and scaling settings being somewhat correct.
    ///
    /// On systems where each monitors can have its own content scale, the
    /// window content scale will depend on which monitor the system considers
    /// the window to be on.
    pub fn getContentScale(self: Self) !glfw.Scale {
        var scale: glfw.Scale = undefined;

        c.glfwGetWindowContentScale(self.handle, &scale.x, &scale.y);

        glfw.getError() catch |err| switch (err) {
            glfw.Error.NotInitialized,
            glfw.Error.PlatformError => return err,
            else => unreachable,
        };

        return scale;
    }

    /// This function returns the opacity of the window, including any
    /// decorations.
    ///
    /// The opacity (or alpha) value is a positive finite number between zero
    /// and one, where zero is fully transparent and one is fully opaque. If the
    /// system does not support whole window transparency, this function always
    /// returns one.
    pub fn getOpacity(self: Self) !f32 {
        var opacity = c.glfwGetWindowOpacity(self.handle);

        glfw.getError() catch |err| switch (err) {
            glfw.Error.NotInitialized,
            glfw.Error.PlatformError => return err,
            else => unreachable,
        };

        return opacity;
    }

    /// This function sets the opacity of the window, including any decorations.
    ///
    /// The opacity (or alpha) value is a positive finite number between zero
    /// and one, where zero is fully transparent and one is fully opaque.
    ///
    /// The initial opacity value for newly created windows is one.
    ///
    /// A window created with framebuffer transparency may not use whole window
    /// transparency. The results of doing this are undefined.
    pub fn setOpacity(self: *Self, opacity: f32) !void {
        c.glfwSetWindowOpacity(self.handle, opacity);

        glfw.getError() catch |err| switch (err) {
            glfw.Error.NotInitialized,
            glfw.Error.PlatformError => return err,
            else => unreachable,
        };
    }

    /// This function iconifies (minimizes) the specified window if it was
    /// previously restored. If the window is already iconified, this function
    /// does nothing.
    ///
    /// If the specified window is a full screen window, the original monitor
    /// resolution is restored until the window is restored.
    pub fn iconify(self: *Self) !void {
        c.glfwIconifyWindow(self.handle);

        glfw.getError() catch |err| switch (err) {
            glfw.Error.NotInitialized,
            glfw.Error.PlatformError => return err,
            else => unreachable,
        };
    }

    /// This function restores the specified window if it was previously
    /// iconified (minimized) or maximized. If the window is already restored,
    /// this function does nothing.
    ///
    /// If the specified window is a full screen window, the resolution chosen
    /// for the window is restored on the selected monitor.
    pub fn restore(self: *Self) !void {
        c.glfwRestoreWindow(self.handle);

        glfw.getError() catch |err| switch (err) {
            glfw.Error.NotInitialized,
            glfw.Error.PlatformError => return err,
            else => unreachable,
        };
    }

    /// This function maximizes the specified window if it was previously not
    /// maximized. If the window is already maximized, this function does
    /// nothing.
    ///
    /// If the specified window is a full screen window, this function does
    /// nothing.
    pub fn maximize(self: *Self) !void {
        c.glfwMaximizeWindow(self.handle);

        glfw.getError() catch |err| switch (err) {
            glfw.Error.NotInitialized,
            glfw.Error.PlatformError => return err,
            else => unreachable,
        };
    }

    /// This function makes the specified window visible if it was previously
    /// hidden. If the window is already visible or is in full screen mode, this
    /// function does nothing.
    ///
    /// By default, windowed mode windows are focused when shown Set the
    /// `FocusOnShow` window hint to change this behavior for all newly created
    /// windows, or change the behavior for an existing window with
    /// `Window.setAttrib`.
    pub fn show(self: *Self) !void {
        c.glfwShowWindow(self.handle);

        glfw.getError() catch |err| switch (err) {
            glfw.Error.NotInitialized,
            glfw.Error.PlatformError => return err,
            else => unreachable,
        };
    }

    /// This function hides the specified window if it was previously visible.
    /// If the window is already hidden or is in full screen mode, this function
    /// does nothing.
    pub fn hide(self: *Self) !void {
        c.glfwHideWindow(self.handle);

        glfw.getError() catch |err| switch (err) {
            glfw.Error.NotInitialized,
            glfw.Error.PlatformError => return err,
            else => unreachable,
        };
    }

    /// This function brings the specified window to front and sets input focus.
    /// The window should already be visible and not iconified.
    ///
    /// By default, both windowed and full screen mode windows are focused when
    /// initially created. Set the GLFW_FOCUSED to disable this behavior.
    ///
    /// Also by default, windowed mode windows are focused when shown with
    /// `Window.show`. Set the `FocusOnShow` window hint to disable this
    /// behavior.
    ///
    /// Do not use this function to steal focus from other applications unless
    /// you are certain that is what the user wants. Focus stealing can be
    /// extremely disruptive.
    ///
    /// For a less disruptive way of getting the user's attention, see attention
    /// requests.
    pub fn focus(self: *Self) !void {
        c.glfwFocusWindow(self.handle);

        glfw.getError() catch |err| switch (err) {
            glfw.Error.NotInitialized,
            glfw.Error.PlatformError => return err,
            else => unreachable,
        };
    }

    /// This function requests user attention to the specified window. On
    /// platforms where this is not supported, attention is requested to the
    /// application as a whole.
    ///
    /// Once the user has given attention, usually by focusing the window or
    /// application, the system will end the request automatically.
    pub fn requestAttention(self: *Self) !void {
        c.glfwRequestWindowAttention(self.handle);

        glfw.getError() catch |err| switch (err) {
            glfw.Error.NotInitialized,
            glfw.Error.PlatformError => return err,
            else => unreachable,
        };
    }

    /// This function returns the handle of the monitor that the specified
    /// window is in full screen on.
    pub fn getMonitor(self: Self) !?glfw.Monitor {
        var handle = c.glfwGetWindowMonitor(self.handle);

        glfw.getError() catch |err| switch (err) {
            glfw.Error.NotInitialized,
            glfw.Error.PlatformError => return err,
            else => unreachable,
        };

        if (handle) |h| {
            return glfw.Monitor{ .handle = handle };
        } else {
            return null;
        }
    }

    /// This function sets the monitor that the window uses for full screen mode
    /// or, if the monitor is `null`, makes it windowed mode.
    ///
    /// When setting a monitor, this function updates the width, height and
    /// refresh rate of the desired video mode and switches to the video mode
    /// closest to it. The window position is ignored when setting a monitor.
    ///
    /// When the monitor is `null`, the position and size are used to place the
    /// window content area. The refresh rate is ignored when no monitor is
    /// specified.
    ///
    /// If you only wish to update the resolution of a full screen window or the
    /// size of a windowed mode window, see `Window.setSize`.
    ///
    /// When a window transitions from full screen to windowed mode, this
    /// function restores any previous window settings such as whether it is
    /// decorated, floating, resizable, has size or aspect ratio limits, etc.
    pub fn setMonitor(self: *Self, monitor: ?glfw.Monitor, position: glfw.Position, size: glfw.Size, refreshRate: ?i32) !void {
        c.glfwSetWindowMonitor(self.handle, if (monitor) |m| m.handle else null, position.x, position.y, size.width, size.height, if (refreshRate) |rr| rr else c.GLFW_DONT_CARE);

        glfw.getError() catch |err| switch (err) {
            glfw.Error.NotInitialized,
            glfw.Error.PlatformError => return err,
            else => unreachable,
        };
    }

    /// This function sets the user-defined pointer of the specified window. The
    /// current value is retained until the window is destroyed. The initial
    /// value is `null`.
    pub fn setUserPointer(self: *Self, comptime T: type, pointer: ?*T) !void {
        c.glfwSetWindowUserPointer(self.handle, if (pointer) |ptr| @ptrToInt(ptr) else null);

        glfw.getError() catch |err| switch (err) {
            glfw.Error.NotInitialized => return err,
            else => unreachable,
        };
    }
    
    /// This function returns the current value of the user-defined pointer of
    /// the specified window. The initial value is `null`.
    pub fn getUserPointer(self: Self, comptime T: type) !?*T {
        var ptr = c.glfwGetWindowUserPointer(self.handle);

        glfw.getError() catch |err| switch (err) {
            glfw.Error.NotInitialized => return err,
            else => unreachable,
        };

        if (ptr) |pointer| {
            return @intToPtr(*T, pointer);
        } else {
            return null;
        }
    }

    /// This function swaps the front and back buffers of the specified window
    /// when rendering with OpenGL or OpenGL ES. If the swap interval is greater
    /// than zero, the GPU driver waits the specified number of screen updates
    /// before swapping the buffers.
    ///
    /// The specified window must have an OpenGL or OpenGL ES context.
    /// Specifying a window without a context will generate a `NoWindowContext`
    /// error.
    ///
    /// This function does not apply to Vulkan. If you are rendering with
    /// Vulkan, see vkQueuePresentKHR instead.
    pub fn swapBuffers(self: *Self) !void {
        c.glfwSwapBuffers(self.handle);

        glfw.getError() catch |err| switch (err) {
            glfw.Error.NotInitialized,
            glfw.Error.PlatformError,
            glfw.Error.NoWindowContext => return err,
            else => unreachable,
        };
    }
};
