(* ::Package:: *)

BeginPackage["DanielS`Wireworld`libWireworld`"]

InitializeWireworldLibrary

WireworldStep

WireworldRun

Begin["`Private`"]


$libName = "Wireworld";

InitializeWireworldLibrary[] :=
	Module[{libWireworld, wireworldStepImm, wireworldRunMut},
		libWireworld = FindLibrary[$libName];
		If[!FileExistsQ[libWireworld],
			Return @ Failure["WireworldFailure", <|
				"MessageTemplate" -> "Unable to find the `1` library.",
				"MessageParameters" -> {$libName <> "." <> Internal`DynamicLibraryExtension[]}
			|>]
		];

		wireworldStepImm = LibraryFunctionLoad[
			libWireworld,
			"wireworld_numeric_array_step_immutable",
			{{LibraryDataType[NumericArray], "Constant"}},
			LibraryDataType[NumericArray]
		];
		If[Head[wireworldStepImm] =!= LibraryFunction,
			Return @ Failure["WireworldFailure", <|
				"MessageTemplate" -> "Unable to load the `1` library function.",
				"MessageParameters" -> {"wireworld_numeric_array_step_immutable"},
				"Library" -> libWireworld
			|>]
		];

		wireworldRunMut = LibraryFunctionLoad[
			libWireworld,
			"wireworld_numeric_array_run_mutable",
			{{LibraryDataType[NumericArray], "Constant"}, Integer},
			LibraryDataType[NumericArray]
		];
		If[Head[wireworldRunMut] =!= LibraryFunction,
			Return @ Failure["WireworldFailure", <|
				"MessageTemplate" -> "Unable to load the `1` library function.",
				"MessageParameters" -> {"wireworld_numeric_array_run_mutable"},
				"Library" -> libWireworld
			|>]
		];

		ClearAll[InitializeWireworldLibrary];
		InitializeWireworldLibrary[] = <|
			"wireworld_step" -> wireworldStepImm,
			"wireworld_run" -> wireworldRunMut
		|>
	];


WireworldStep :=
	Module[{funs},
		funs = InitializeWireworldLibrary[];
		If[FailureQ[funs],
			Return[funs]
		];

		ClearAll[WireworldStep];
		WireworldStep = funs["wireworld_step"]
	];


WireworldRun :=
	Module[{funs},
		funs = InitializeWireworldLibrary[];
		If[FailureQ[funs],
			Return[funs]
		];
		ClearAll[WireworldRun];
		WireworldRun = funs["wireworld_run"]
	];


End[]

EndPackage[]
