#!/usr/bin/env wolframscript

(* :!CodeAnalysis::BeginBlock:: *)
(* :!CodeAnalysis::Disable::SuspiciousSessionSymbol:: *)

If[FailureQ @ FindFile["Wolfram`PacletCICD`"],
    PacletInstall["Wolfram/PacletCICD"]
];

Needs["Wolfram`PacletCICD`" -> "cicd`"];

$inputFileName = Replace[$InputFileName, "" :> NotebookFileName[]];
$pacDir        = DirectoryName[$inputFileName, 2];
$buildDir      = FileNameJoin @ {$pacDir, "build", "DanielS__Wireworld"};

PacletDirectoryLoad @ $buildDir;
cicd`TestPaclet @ File @ $pacDir

(* :!CodeAnalysis::EndBlock:: *)