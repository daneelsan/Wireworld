const std = @import("std");

pub fn build(b: *std.build.Builder) void {
    const lib = b.addSharedLibrary("Wireworld", null, .unversioned);

    const cflags = [_][]const u8{
        "-std=c99",
        "-Wall",
        "-Wextra",
        "-Werror",
        "-Wno-unused-parameter",
    };
    lib.addCSourceFile("libWireworld/libWireworld.c", &cflags);
    lib.linkLibC();

    // Modify these paths if needed.
    lib.addIncludeDir("/Applications/Mathematica.app/Contents/SystemFiles/IncludeFiles/C");
    lib.addLibPath("/Applications/Mathematica.app/Contents/SystemFiles/Libraries/MacOSX-ARM64");

    // Options: Debug, ReleaseSafe, ReleaseFast, or ReleaseSmall.
    const mode = b.standardReleaseOptions();
    lib.setBuildMode(mode);

    // Common options: x86_64-windows, x86_64-linux, x86_64-macos, aarch64-macos.
    const target = b.standardTargetOptions(.{});
    lib.setTarget(target);

    switch (target.getOsTag()) {
        .windows => {
            switch (target.getCpuArch()) {
                .x86_64 => lib.setOutputDir("LibraryResources/Windows-x86-64"),
                else => {},
            }
        },
        .macos => {
            switch (target.getCpuArch()) {
                .x86_64 => lib.setOutputDir("LibraryResources/MacOSX-x86-64"),
                .aarch64 => lib.setOutputDir("LibraryResources/MacOSX-ARM64"),
                else => {},
            }
        },
        .linux => {
            switch (target.getCpuArch()) {
                .x86_64 => lib.setOutputDir("LibraryResources/Linux-x86-64"),
                else => {},
            }
        },
        else => {}
    }
    lib.install();
}
