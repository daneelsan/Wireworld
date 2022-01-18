(* ::Package:: *)

BeginPackage["Wireworld`libWireworld`"]

InitializeWireworldLibrary

Begin["`Private`"]


InitializeWireworldLibrary[] :=
	Module[{libWireworld, wireworldStepImm, wireworldStepMut},
		libWireworld = FindLibrary["libWireworld"];
		If[!FileExistsQ[libWireworld],
			Return @ Failure["WireworldFailure", <|
				"MessageTemplate" -> "Unable to find the `1` library.",
				"MessageParameters" -> {"libWireworld." <> Internal`DynamicLibraryExtension[]}
			|>]
		];

		wireworldStepImm = LibraryFunctionLoad[
			libWireworld,
			"wireworld_step_immutable",
			{{LibraryDataType[NumericArray, "UnsignedInteger16", 2], "Constant"}},
			LibraryDataType[NumericArray, "UnsignedInteger16", 2]
		];
		If[Head[wireworldStepImm] =!= LibraryFunction,
			Return @ Failure["WireworldFailure", <|
				"MessageTemplate" -> "Unable to load the `1` library function.",
				"MessageParameters" -> {"wireworld_step_immutable"}
			|>]
		];

		wireworldStepMut = LibraryFunctionLoad[
			libWireworld,
			"wireworld_step_mutable",
			{{LibraryDataType[NumericArray, "UnsignedInteger16", 2], "Shared"}},
			"Void"
		];
		If[Head[wireworldStepMut] =!= LibraryFunction,
			Return @ Failure["WireworldFailure", <|
				"MessageTemplate" -> "Unable to load the `1` library function.",
				"MessageParameters" -> {"wireworld_step_mutable"}
			|>]
		];

		ClearAll[InitializeWireworldLibrary];
		InitializeWireworldLibrary[] = <|
			"wireworld_step_immutable" -> wireworldStepImm,
			"wireworld_step_mutable" -> wireworldStepMut
		|>
	]


End[]

EndPackage[]
