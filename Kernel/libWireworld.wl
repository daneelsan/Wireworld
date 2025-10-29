(* ::Package:: *)

BeginPackage["DanielS`Wireworld`libWireworld`"]

InitializeWireworldLibrary

Begin["`Private`"]


$libName = "Wireworld";

InitializeWireworldLibrary[] :=
	Module[{libWireworld, wireworldStepImm, wireworldRunImm, wireworldStepMut},
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

		wireworldRunImm = LibraryFunctionLoad[
			libWireworld,
			"wireworld_run_immutable",
			{LibraryDataType[SparseArray, Integer], Integer},
			LibraryDataType[SparseArray, Integer]
		];
		If[Head[wireworldRunImm] =!= LibraryFunction,
			Return @ Failure["WireworldFailure", <|
				"MessageTemplate" -> "Unable to load the `1` library function.",
				"MessageParameters" -> {"wireworld_run_immutable"},
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
			"wireworld_run_immutable" -> wireworldRunImm,
			"wireworld_step_mutable" -> wireworldStepMut
		|>
	]


End[]

EndPackage[]
