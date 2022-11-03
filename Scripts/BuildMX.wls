#!/usr/bin/env wolframscript

(* :!CodeAnalysis::BeginBlock:: *)
(* :!CodeAnalysis::Disable::SuspiciousSessionSymbol:: *)

If[ FailureQ @ FindFile[ "Wolfram`PacletCICD`" ],
    PacletInstall[ "Wolfram/PacletCICD" ]
];

Needs[ "Wolfram`PacletCICD`" -> "cicd`" ];

$inputFileName = Replace[ $InputFileName, "" :> NotebookFileName[ ] ];
$pacletDir     = DirectoryName[ $inputFileName, 2 ];
$mxFile        = FileNameJoin @ {
                     $pacletDir,
                     "Kernel",
                     ToString @ $SystemWordLength <> "Bit",
                     "Wireworld.mx"
                 };


If[ FileExistsQ @ $mxFile,
    Print[ "Removing existing MX file..." ];
    DeleteFile @ $mxFile
];

Print[ "Loading paclet..." ];
PacletDirectoryLoad @ $pacletDir;
Needs[ "Daniels`Wireworld`" ];

$mxDir = GeneralUtilities`EnsureDirectory @ DirectoryName @ $mxFile;
Print[ "MX target directory: ", $mxDir  ];
Print[ "Building MX file: "   , $mxFile ];

DumpSave[
    $mxFile,
    {
        "Daniels`Wireworld`",
        "Daniels`Wireworld`Private`"
    },
    "SymbolAttributes" -> False
];

If[ ! FileExistsQ @ $mxFile,
    cicd`ConsoleError[ "Failed to build MX file!", "Fatal" -> True ],
    $mxFile
]

(* :!CodeAnalysis::EndBlock:: *)