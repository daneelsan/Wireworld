#!/usr/bin/env wolframscript

(* :!CodeAnalysis::BeginBlock:: *)
(* :!CodeAnalysis::Disable::SuspiciousSessionSymbol:: *)

If[ FailureQ @ FindFile[ "Wolfram`PacletCICD`" ],
    PacletInstall[ "Wolfram/PacletCICD" ]
];

Needs[ "Wolfram`PacletCICD`" -> "cicd`" ];
Needs[ "CCompilerDriver`"    -> "ccd`"  ];

$inputFileName = Replace[ $InputFileName, "" :> NotebookFileName[ ] ];
$pacletDir     = DirectoryName[ $inputFileName, 2 ];
$sourceDir     = FileNameJoin @ { $pacletDir, "libWireworld" };
$targetDir     = FileNameJoin @ { $pacletDir, "LibraryResources", $SystemID };
$targetFile    = FileNameJoin @ {
                     $targetDir,
                     "Wireworld." <> Internal`DynamicLibraryExtension[ ]
                 };

If[ FileExistsQ @ $targetFile,
    Print[ "Removing existing library file: ", $targetFile ];
    DeleteFile @ $targetFile;
    If[ FileExistsQ @ $targetFile,
        cicd`ConsoleError[ "Failed to delete existing file.", "Fatal" -> True ]
    ]
];

Print[ "Build source directory: " <> $sourceDir ];
Print[ "Build target directory: " <> $targetDir ];

$built = ccd`CreateLibrary[
    FileNames[ "*.c", $sourceDir ],
    "Wireworld",
    "TargetDirectory"     -> $targetDir,
    "CleanIntermediate"   -> True,
    "ShellOutputFunction" -> Print
];

If[ FileExistsQ @ $built,
    $built,
    cicd`ConsoleError[ "Failed to build the library.", "Fatal" -> True ]
]

(* :!CodeAnalysis::EndBlock:: *)