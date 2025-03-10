const std = @import("std");

pub fn build(b: *std.Build) void {
    // Common options: x86_64-windows, x86_64-linux, x86_64-macos, aarch64-macos.
    const target = b.standardTargetOptions(.{});

    const optimize = b.standardOptimizeOption(.{});

    const lib_mod = b.createModule(.{
        .root_source_file = null,
        .target = target,
        .optimize = optimize,
    });

    const lib = b.addLibrary(.{
        .linkage = .dynamic,
        .name = "Wireworld",
        .root_module = lib_mod,
    });

    const cflags = [_][]const u8{
        "-std=c99",
        "-Wall",
        "-Wextra",
        "-Werror",
        "-Wno-unused-parameter",
    };
    lib.addCSourceFile(.{ .file = b.path("libWireworld/libWireworld.c"), .flags = &cflags });
    lib.linkLibC();

    // Modify these paths if needed.
    lib.addIncludePath(std.Build.LazyPath{ .cwd_relative = "/Applications/Wolfram.app/Contents/SystemFiles/IncludeFiles/C" });
    lib.addLibraryPath(std.Build.LazyPath{ .cwd_relative = "/Applications/Wolfram.app/Contents/SystemFiles/Libraries/MacOSX-ARM64" });

    const lib_install = b.addInstallArtifact(lib, .{});

    switch (target.result.os.tag) {
        .windows => {
            switch (target.result.cpu.arch) {
                .x86_64 => lib_install.dest_dir = .{ .custom = "../LibraryResources/Windows-x86-64" },
                else => unreachable,
            }
        },
        .macos => {
            switch (target.result.cpu.arch) {
                .x86_64 => lib_install.dest_dir = .{ .custom = "../LibraryResources/MacOSX-x86-64" },
                .aarch64 => lib_install.dest_dir = .{ .custom = "../LibraryResources/MacOSX-ARM64" },
                else => unreachable,
            }
        },
        .linux => {
            switch (target.result.cpu.arch) {
                .x86_64 => lib_install.dest_dir = .{ .custom = "../LibraryResources/Linux-x86-64" },
                else => unreachable,
            }
        },
        else => unreachable,
    }

    b.getInstallStep().dependOn(&lib_install.step);
}
