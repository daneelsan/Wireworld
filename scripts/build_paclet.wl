#!/usr/bin/env wolframscript

Needs["PacletTools`"];

pacletDir = DirectoryName[$InputFileName, 2];
result = PacletBuild[pacletDir];
If[FailureQ[result],
	Print["Failed to build the paclet: ", pacletDir];
	Exit[1]
];

Print["Paclet build successfully (", result["TotalTime"], "): ", result["PacletArchive"]];
Exit[0]

