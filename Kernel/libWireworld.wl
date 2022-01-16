(* ::Package:: *)

BeginPackage["Wireworld`libWireworld`"]

InitializeWireworldLibrary

Begin["`Private`"]


InitializeWireworldLibrary[] :=
	Module[{libWireworld, lfWireworldStep},
		libWireworld = FindLibrary["libWireworld"];
		If[!FileExistsQ[libWireworld],
			Return @ Failure["WireworldFailure", <|
				"MessageTemplate" -> "Unable to find the `1` library.",
				"MessageParameters" -> {"libWireworld." <> Internal`DynamicLibraryExtension[]}
			|>]
		];

		lfWireworldStep = LibraryFunctionLoad[
			libWireworld,
			"wireworld_step",
			{{Integer, 2, "Constant"}},
			{Integer, 2}
		];
		If[Head[lfWireworldStep] =!= LibraryFunction,
			Return @ Failure["WireworldFailure", <|
				"MessageTemplate" -> "Unable to load the `1` library function.",
				"MessageParameters" -> {"wireworld_step"}
			|>]
		];

		$libraryInitialized = True;
		ClearAll[InitializeWireworldLibrary];
		InitializeWireworldLibrary[] = <|
			"wireworld_step" -> lfWireworldStep
		|>
	]


End[]

EndPackage[]
