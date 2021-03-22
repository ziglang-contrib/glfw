const std = @import("std");
const Builder = std.build.Builder;

pub fn build(b: *Builder) void {
    const mode = b.standardReleaseOptions();
    const lib = b.addStaticLibrary("glfw", "src/main.zig");
    lib.setBuildMode(mode);
    lib.install();

    var main_tests = b.addTest("src/main.zig");
    main_tests.setBuildMode(mode);

    const test_step = b.step("test", "Run library tests");
    test_step.dependOn(&main_tests.step);

    build_example(b, "initialization");
    build_example(b, "error");
    build_example(b, "window");
    build_example(b, "monitor");
}

fn build_example(b: *Builder, comptime name: [:0]const u8) void {
    const mode = b.standardReleaseOptions();
    const exe = b.addExecutable(name, "examples/" ++ name ++ ".zig");
    exe.setBuildMode(mode);
    exe.install();

    exe.linkLibC();
    exe.linkSystemLibrary("glfw");

    exe.addPackagePath("glfw", "./glfw.zig");
}
