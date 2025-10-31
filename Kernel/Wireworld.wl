(* ::Package:: *)

BeginPackage["DanielS`Wireworld`"]


$WireworldFunctionRule
$WireworldNumberRule
Wireworld
WireworldDraw
WireworldEvolve
WireworldParse
WireworldPlot
WireworldQ
WireworldStateQ


ClearAll["DanielS`Wireworld`*"]
ClearAll["DanielS`Wireworld`Private`*"]

Begin["`Private`"]  (* Begin Wireworld`Private`*)

Needs["DanielS`Wireworld`Utilities`"]


(*******************************************************************************
WireworldStateQ
*******************************************************************************)

SyntaxInformation[WireworldStateQ] = {
	"ArgumentsPattern" -> {_}
};

WireworldStateQ[_?WireworldQ] := True;

WireworldStateQ[na_?NumericArrayQ] :=
	WireworldStateQ[Normal[na]];

WireworldStateQ[state_] :=
	MatrixQ[state, MemberQ[$CellStates, #] &]


(*******************************************************************************
Wireworld, WireworldQ
*******************************************************************************)

SyntaxInformation[Wireworld] = {
	"ArgumentsPattern" -> {_}
};

Wireworld[arg1_] ? System`Private`HoldEntryQ :=
	Module[{state},
		If[!WireworldStateQ[arg1],
			Return @ Failure["WireworldFailure", <|
				"MessageTemplate" -> "Argument `1` should be a matrix of Wireworld cell states (`2`).",
				"MessageParameters" -> {arg1, StringRiffle[$CellStates, ", "]},
				"Input" -> arg1
			|>]
		];
		state = NumericArray[arg1, "UnsignedInteger8"];
		System`Private`ConstructNoEntry[Wireworld, state]
	];


iCreateWireworld[state_] :=
	System`Private`ConstructNoEntry[Wireworld, state];


Wireworld /: HoldPattern[Normal[Wireworld[state_]]] :=
	state;

Wireworld /: Dimensions[w_Wireworld ? WireworldQ] :=
	Dimensions[Normal[w]];

Wireworld /: MatrixQ[w_Wireworld ? WireworldQ] :=
	True;

Wireworld /: SparseArray[w_Wireworld ? WireworldQ] :=
	SparseArray[Normal[Normal[w]]];

Wireworld /: NumericArray[w_Wireworld ? WireworldQ] :=
	Normal[w];

Wireworld /: NumericArray[w_Wireworld ? WireworldQ, type_] :=
	NumericArray[Normal[w], type];


SyntaxInformation[WireworldQ] = {
	"ArgumentsPattern" -> {_}
};

WireworldQ[expr_Wireworld] :=
	System`Private`NoEntryQ[expr];

WireworldQ[_] :=
	False;


stateIcon[state_] :=
	MatrixPlot[
		state,
		Frame -> False,
		PlotTheme -> "Basic",
		ColorRules -> $CellColorRules,
		MaxPlotPoints -> 30,
		AspectRatio -> 1,
		ImageSize -> Dynamic[{Automatic, 3.5 * CurrentValue["FontCapHeight"] / AbsoluteCurrentValue[Magnification]}]
	];


MakeBoxes[w_Wireworld, fmt_] /; WireworldQ[w] :=
	Module[{state, dims, icon},
		state = Normal[w];
		dims = Dimensions[state];
		icon = stateIcon[state];
		BoxForm`ArrangeSummaryBox[
			Wireworld,
			w,
			icon,
			{
				BoxForm`SummaryItem @ {"Rows: ", dims[[1]]},
				BoxForm`SummaryItem @ {"Columns: ", dims[[2]]}
			},
			{},
			fmt
		]
	];


(*******************************************************************************
	Load other packages
*******************************************************************************)
Needs["DanielS`Wireworld`WireworldEvolve`"]
Needs["DanielS`Wireworld`WireworldPlot`"]
Needs["DanielS`Wireworld`WireworldDraw`"]
Needs["DanielS`Wireworld`WireworldParse`"]


End[] (* End Wireworld`Private`*)

EndPackage[]
