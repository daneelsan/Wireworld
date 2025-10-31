BeginPackage["DanielS`Wireworld`WireworldPlot`"]


iWireworldPlot


Begin["`Private`"]


Needs["DanielS`Wireworld`"]
Needs["DanielS`Wireworld`Utilities`"]


(*******************************************************************************
WireworldPlot
*******************************************************************************)

SyntaxInformation[WireworldPlot] = {
	"ArgumentsPattern" -> {_, OptionsPattern[]}
};

Options[WireworldPlot] = Options[ArrayPlot];

SetOptions[WireworldPlot, {
	ColorRules -> $CellColorRules,
	Mesh -> Automatic,
	MeshStyle -> Directive[Thin, Darker[Gray]]
}];

$meshThreshold = 10000;

WireworldPlot[args___] /; CheckArguments[WireworldPlot[args], 1] :=
	Module[{arg1, opts, meshOpt},
		{arg1, opts} = ArgumentsOptions[WireworldPlot[args], 1];
		arg1 = First[arg1];
		If[!WireworldStateQ[arg1],
			Return @ Failure["WireworldFailure", <|
				"MessageTemplate" -> "Argument `1` should be a matrix of Wireworld cell states (`2`).",
				"MessageParameters" -> {arg1, StringRiffle[$CellStates, ", "]},
				"Input" -> arg1
			|>]
		];
		meshOpt = OptionValue[WireworldPlot, opts, Mesh];
		If[meshOpt === Automatic,
			If[Times @@ Dimensions[arg1] <= $meshThreshold,
				meshOpt = True
				,
				meshOpt = False
			]
		];
		iWireworldPlot[arg1, Mesh -> meshOpt, opts]
	];


iWireworldPlot[ww_?WireworldQ, opts___] :=
	iWireworldPlot[Normal[ww], opts];

iWireworldPlot[state_, opts___] :=
	ArrayPlot[
		state,
		opts,
		ColorRules -> $CellColorRules,
		Mesh -> True,
		MeshStyle -> Directive[Thin, Darker[Gray]]
	]

End[]


EndPackage[]
