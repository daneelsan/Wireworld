#!/usr/bin/env wolframscript

Needs["CCompilerDriver`"];

pacletDir = DirectoryName[$InputFileName, 2];
libDirSource = FileNameJoin[{pacletDir, "libWireworld"}];
libDirTarget = FileNameJoin[{pacletDir, "LibraryResources", $SystemID}];

srcFiles = FileNames["*.c", libDirSource];

warningsFlags = {"-Wall", "-Wextra", "-Werror", "-Wno-unused", "-Wno-unused-parameter"};

Print["Building the library in ", libDirTarget];
libPath = CCompilerDriver`CreateLibrary[
	srcFiles,
	If[$OperatingSystem === "Windows", "", "lib"] <> "Wireworld",
	"ShellCommandFunction" -> EchoLabel["Command:\n"],
	"ShellOutputFunction" -> EchoLabel["Output:\n"],
	"TargetDirectory" -> libDirTarget,
	"CleanIntermediate" -> True,
	"Language" -> "C",
	"CompileOptions" -> If[ $OperatingSystem === "Windows", { }, warningsFlags ]
];
If[!FileExistsQ[libPath],
	Print["Failed to build the library."];
	Exit[1]
];

Print["The library was built successfully: ", libPath];
Exit[0]