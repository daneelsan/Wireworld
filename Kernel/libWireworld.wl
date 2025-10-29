(* ::Package:: *)

BeginPackage["DanielS`Wireworld`libWireworld`"]

InitializeWireworldLibrary

Begin["`Private`"]


$libName = "Wireworld";

InitializeWireworldLibrary[] :=
	Module[{libWireworld, wireworldStepImm, wireworldRun, wireworldStepMut},
		libWireworld = FindLibrary[$libName];
		If[!FileExistsQ[libWireworld],
			Return @ Failure["WireworldFailure", <|
				"MessageTemplate" -> "Unable to find the `1` library.",
				"MessageParameters" -> {$libName <> "." <> Internal`DynamicLibraryExtension[]}
			|>]
		];

		wireworldStepImm = LibraryFunctionLoad[
			libWireworld,
			"wireworld_step_immutable",
			{{Integer, 2, "Constant"}},
			{Integer, 2}
		];
		If[Head[wireworldStepImm] =!= LibraryFunction,
			Return @ Failure["WireworldFailure", <|
				"MessageTemplate" -> "Unable to load the `1` library function.",
				"MessageParameters" -> {"wireworld_step_immutable"},
				"Library" -> libWireworld
			|>]
		];

		wireworldRun = LibraryFunctionLoad[
			libWireworld,
			"wireworld_run",
			{{LibraryDataType[SparseArray, Integer], "Constant"}, Integer},
			LibraryDataType[SparseArray, Integer]
		];
		If[Head[wireworldRun] =!= LibraryFunction,
			Return @ Failure["WireworldFailure", <|
				"MessageTemplate" -> "Unable to load the `1` library function.",
				"MessageParameters" -> {"wireworld_run"},
				"Library" -> libWireworld
			|>]
		];

		wireworldStepMut = LibraryFunctionLoad[
			libWireworld,
			"wireworld_step_mutable",
			{{Integer, 2, "Shared"}, Integer},
			"Void"
		];
		If[Head[wireworldStepMut] =!= LibraryFunction,
			Return @ Failure["WireworldFailure", <|
				"MessageTemplate" -> "Unable to load the `1` library function.",
				"MessageParameters" -> {"wireworld_step_mutable"},
				"Library" -> libWireworld
			|>]
		];

		ClearAll[InitializeWireworldLibrary];
		InitializeWireworldLibrary[] = <|
			"wireworld_step_immutable" -> wireworldStepImm,
			"wireworld_run" -> wireworldRun,
			"wireworld_step_mutable" -> wireworldStepMut
		|>
	]


End[]

EndPackage[]
