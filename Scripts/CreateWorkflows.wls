#!/usr/bin/env wolframscript
(* ::Package:: *)

$inputFileName = Replace[$InputFileName, "" :> NotebookFileName[]];
$pacletDir     = DirectoryName[$inputFileName, 2];


PacletInstall["Wolfram/PacletCICD"];
Needs["Wolfram`PacletCICD`"];


$supportedSystemIDs = {"Windows-x86-64", "MacOSX-x86-64", "Linux-x86-64"};


(* ::Subsubsection:: *)
(*Compile and Build Paclet*)


compileAndBuildPacletWF = Module[{
	compile, compileJobs, buildPacletSteps, customBuildPacletSteps,
	customBuildPacletJob
},
	compile = Workflow["Compile"];
	compileJobs = compile["Jobs"];
	buildPacletSteps = compileJobs["BuildPaclet"]["Steps"];
	customBuildPacletSteps =
		Insert[
			buildPacletSteps,
			Splice @ {
				WorkflowStep[File["Scripts/BuildMX.wls"]],
				WorkflowStep[File["Scripts/SetPacletInfo.wls"]]
			},
			3
		];
	customBuildPacletJob = WorkflowJob[
		customBuildPacletSteps,
		<|
			"Name" -> "BuildPaclet",
			"Needs" -> Keys @ KeyDrop[compileJobs, "BuildPaclet"]
		|>
	];
	Workflow[<|
		"Name" -> "CompileAndBuildPaclet",
		"Jobs" -> {
			Splice @ Values @ KeyDrop[compileJobs, "BuildPaclet"],
			customBuildPacletJob
		}
	|>]
];


(* ::Subsubsection:: *)
(*Compile, Build Paclet, Test And Check*)


downloadBuiltPacletStep = WorkflowStep[<|
	"Name" -> "DownloadBuiltPaclet",
	"Uses" -> "actions/download-artifact@v3",
	"With" -> <|"name" -> "artifact", "path" -> "build"|>
|>];


createTestJob[os_]:=
	Module[{meta,job,data},
		meta = <|"Name" -> "Test-" <> os, "Needs" -> "BuildPaclet"|>;
		job = WorkflowJob[File["Scripts/TestPaclet.wls"], meta, OperatingSystem -> os];
		data = job["Data"];
		data["steps"] = Insert[data["steps"], downloadBuiltPacletStep["Data"], 4];
		WorkflowJob[data]
	];


testJobs = createTestJob /@ $supportedSystemIDs;


checkWF = WorkflowJob["Check", <|"Needs"-> Map[#["Name"] &, testJobs]|>];


compileBuildTestCheckWF = Workflow[<|
	"Name" -> "CompileBuildTestCheck",
	"On"-> <|
		"push" -> <|"branches" -> "master"|>,
		"pull_request" -> <|"branches" -> "master"|>,
		"workflow_dispatch" -> True
	|>,
	"Jobs" -> Join[
		Values @ compileAndBuildPacletWF["Jobs"],
		testJobs,
		{checkWF}
	]
|>];


Module[{file},
	file = WorkflowExport[$pacletDir, compileBuildTestCheckWF];
	If[FileExistsQ[file],
		Print["Successfully workflow exported: ", file],
		Exit[1]
	]
];


(* ::Subsubsection:: *)
(*Submit*)


submitJob = WorkflowJob["Submit", <|"Needs" -> {"Check"}|>];


submitWF = Workflow[
	"Submit",
	<|
		"Jobs" -> Join[
			Values @ compileBuildTestCheckWF["Jobs"],
			{submitJob}
		]
	|>
];


Module[{file},
	file = WorkflowExport[$pacletDir, submitWF];
	If[FileExistsQ[file],
		Print["Successfully workflow exported: ", file],
		Exit[1]
	]
];
