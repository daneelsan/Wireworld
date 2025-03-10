# Wireworld

Wireworld is a Turing-complete cellular automaton first proposed by Brian Silverman in 1987 suited for simulating logic gates and other real-world computer elements.

## Installation

Install the paclet (version `1.0.0`) from github releases:

```Mathematica
PacletInstall["https://github.com/daneelsan/Wireworld/releases/download/v1.0.0/Wireworld-1.0.0.paclet"]
```

## Usage

Load the Wireworld` package:

```Mathematica
Needs["Wireworld`"]
```

Wireworld symbols:

```Mathematica
In[]:= Names["Wireworld`*"]
Out[]= {
	"WireworldDraw",
	"WireworldEvolve",
	"WireworldPlot",
	"WireworldStateQ",
	"$WireworldFunctionRule",
	"$WireworldNumberRule",
	"$WireworldRule"
}
```

Open the documentation of the `WireworldEvolve` function:

```Mathematica
NotebookOpen[Information[WireworldEvolve, "Documentation"]["Local"]]
```

![ref/WireworldEvolve](./screenshots/ref-WireworldEvolve.png)

## Examples

### A Clock Generator

A period 12 electron clock generator:

```Mathematica
In[]:= state = {
	{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	{0, 0, 3, 3, 3, 0, 3, 2, 1, 3, 3, 0, 0, 0},
	{0, 3, 0, 0, 0, 3, 0, 0, 0, 0, 0, 3, 0, 0},
	{0, 3, 0, 0, 0, 3, 0, 0, 0, 0, 0, 3, 0, 0},
	{0, 3, 0, 0, 0, 2, 0, 0, 0, 0, 0, 3, 0, 0},
	{0, 0, 3, 3, 1, 0, 0, 0, 0, 0, 0, 3, 0, 0},
	{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0},
	{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0},
	{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0}
};

In[]:= ListAnimate[WireworldPlot /@ WireworldEvolve[state, 11]]
```

![A clock generator](./screenshots/example-ClockGenerator.gif)

### The Diode

A diode allows electrons to flow in only one direction:

```Mathematica
In[]:= state = {
	{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	{3, 3, 2, 1, 3, 3, 3, 3, 2, 1, 3, 0, 3, 3, 2, 1, 3, 3, 3, 3, 2},
	{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	{0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	{3, 3, 2, 1, 3, 3, 3, 3, 2, 0, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3},
	{0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
};

In[]:= ListAnimate[WireworldPlot /@ WireworldEvolve[state, 8]]
```

![Two diodes](./screenshots/example-Diode.gif)

### The OR gate

Two clock generators sending electrons into an OR gate:

```Mathematica
In[]:= state = {
	{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	{0, 0, 0, 3, 3, 3, 3, 3, 3, 2, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	{0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 3, 3, 3, 3, 2, 1, 0, 0, 0, 0, 0, 0, 0},
	{0, 0, 0, 3, 3, 3, 1, 2, 3, 3, 3, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 0, 0, 0},
	{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 0, 0, 0},
	{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 3, 3, 3, 3, 2, 1, 3},
	{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 0, 0, 0},
	{0, 0, 0, 2, 1, 3, 3, 3, 3, 2, 1, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 0, 0, 0},
	{0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 3, 3, 3, 3, 3, 3, 0, 0, 0, 0, 0, 0, 0},
	{0, 0, 0, 3, 3, 3, 3, 3, 3, 3, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
};

In[]:= ListAnimate[WireworldPlot /@ WireworldEvolve[state, 20]]
```

![An OR gate](./screenshots/example-OR.gif)

## Wolfram Paclet Repository

A copy of the lastest released paclet is in the Wolfram Paclet Repository (WPR):
https://resources.wolframcloud.com/PacletRepository/resources/DanielS/Wireworld/

## Build

1. Build the `Wireworld` paclet using the `build_paclet.wls` wolframscript:

```sh
./scripts/build_paclet.wls
```

The paclet will be placed under the `build` directory:

```sh
ls build/*.paclet # build/Wireworld-1.0.0.paclet
```

2. Install the built paclet:

```Mathematica
PacletInstall["./build/Wireworld-1.0.0.paclet"]
```

## Build libWireworld

The `LibraryLink` library `libWireworld` contains the low-level functions `` Wireworld`Library`WireworldStepImmutable `` and `` Wireworld`Library`WireworldStepMutable ``. There are two ways to build it:

### build_library.wls

Run `scripts/build_library.wls`:

```sh
./scripts/build_library.wls
```

The library will be stored in `LibraryResources/$SystemID/`:

```sh
ls LibraryResources/MacOSX-ARM64 # libWireworld.dylib
```

Note: this script only builds the library for your builtin `$SystemID`.

### zig build

Use `zig build` (https://ziglang.org) to build the library:

```sh
zig version # 0.14.0
zig build
```

The library will be stored in `LibraryResources/$SystemID/`:

```sh
ls LibraryResources/MacOSX-ARM64 # libWireworld.dylib
```

One can also cross compile specifying the target:

```sh
zig build -Dtarget=x86_64-linux
ls LibraryResources/Linux-x86-64 # libWireworld.so
```

The mapping between `zig targets` and `$SystemID` is:

```Mathematica
{
	"Linux-x86-64" -> "x86_64-linux",
	"MacOSX-x86-64" -> "x86_64-macos",
	"Windows-x86-64" -> "x86_64-windows",
	"MacOSX-ARM64" -> "aarch64-macos",
}
```

Note: other targets will be stored in `zig-out/lib`.

The build configuration is specified in `build.zig`. If necessary, change the location of the Wolfram libraries and headers:

```zig
lib.addIncludeDir(...);
lib.addLibPath(...);
```
