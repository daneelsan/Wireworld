(* ::Package:: *)

BeginPackage["Wireworld`"]

WireworldStateQ
$WireworldFunctionRule
$WireworldNumberRule
WireworldEvolve
WireworldPlot
(*
WireworldQ
Wireworld
*)

WireworldDraw

ClearAll["Wireworld`*"]
ClearAll["Wireworld`Private`*"]

Begin["`Private`"]  (* Begin Wireworld`Private`*)


(*******************************************************************************
cell state information
*******************************************************************************)

$cellStateInformation = <|
	0 -> <|"Name" -> "empty", "Color" -> RGBColor[0, 0, 0] (* Black *)|>,
	1 -> <|"Name" -> "electron head", "Color" -> RGBColor[1, 1, 1] (* White *)|>,
	2 -> <|"Name" -> "electron tail", "Color" -> RGBColor[0, 0.5, 1] (* Blue *)|>,
	3 -> <|"Name" -> "wire", "Color" -> RGBColor[1, 0.5, 0] (* Orange *)|>
|>;

$cellStates = Keys[$cellStateInformation];

$cellColorRules = Normal[$cellStateInformation[[All, "Color"]]];


(*******************************************************************************
WireworldStateQ
*******************************************************************************)

SyntaxInformation[WireworldStateQ] = {
	"ArgumentsPattern" -> {_}
};

WireworldStateQ[state_] /; CheckArguments[WireworldStateQ[state], 1] :=
	MatrixQ[state, MemberQ[$cellStates, #] &]


(*******************************************************************************
WireworldPlot
*******************************************************************************)

SyntaxInformation[WireworldPlot] = {
	"ArgumentsPattern" -> {_, OptionsPattern[]}
};

Options[WireworldPlot] = Options[ArrayPlot];

SetOptions[WireworldPlot, {
	ColorRules -> $cellColorRules,
	Mesh -> True,
	MeshStyle -> Directive[Thin, Darker[Gray]]
}];

WireworldPlot[args___] /; CheckArguments[WireworldPlot[args], 1] :=
	Module[{arg1, opts},
		{arg1, opts} = ArgumentsOptions[WireworldPlot[args], 1];
		arg1 = First[arg1];
		If[!WireworldStateQ[arg1],
			Return @ Failure["WireworldFailure", <|
				"MessageTemplate" -> "Argument `1` should be a matrix of Wireworld cell states (`2`).",
				"MessageParameters" -> {arg1, StringRiffle[$cellStates, ", "]},
				"Input" -> arg1
			|>]
		];
		iWireworldPlot[arg1, opts]
	]

iWireworldPlot[state_, opts___] :=
	ArrayPlot[
		state,
		opts,
		ColorRules -> $cellColorRules,
		Mesh -> True,
		MeshStyle -> Directive[Thin, Darker[Gray]]
	]


(*******************************************************************************
$WireworldFunctionRule
*******************************************************************************)

(* Adapted from https://codegolf.stackexchange.com/a/44683/110183 *)
$WireworldFunctionRule = {
	Switch[#[[2, 2]],
		(* empty -> empty *)
		0, 0,
		(* electron head -> electron tail *)
		1, 2,
		(* electron tail -> conductor *)
		2, 3,
		(* conductor -> electron head if exactly one or two of the neighbouring cells are electron heads, otherwise remains conductor *)
		3, If[0 < Count[#, 1, 2] < 3, 1, 3],
		_, 0 (* all other cell states die *)
	] &,
	{}, (* always {} when the first argument is a function *)
	{1, 1} (* Moore neighborhood *)
};


(*******************************************************************************
$WireworldNumberRule
*******************************************************************************)

(* Inspired from https://mathematica.stackexchange.com/questions/153388/how-to-calculate-cellularautomaton-rule-numbers-in-higher-dimensions *)
$WireworldNumberRule := $WireworldNumberRule =
	Module[{function, configurations, states},
		function = $WireworldFunctionRule[[1]];
		(* Generate all possible cell configurations (Moore neighborhood) *)
		configurations = Tuples[{3, 2, 1, 0}, {3, 3}];
		(* Compute the next center cell *)
		states = function /@ configurations;
		{
			FromDigits[states, Length[$cellStates]], (* Rule number *)
			Length[$cellStates], (* Number of colors *)
			{1, 1} (* Moore neighborhood *)
		}
	];


(*******************************************************************************
WireworldEvolve
*******************************************************************************)

SyntaxInformation[WireworldEvolve] = {
	"ArgumentsPattern" -> {_, _.}
};

WireworldEvolve[iargs___] /; CheckArguments[WireworldEvolve[iargs], {1, 2}] :=
	Module[{args, opts, init, tspec, res},
		{args, opts} = ArgumentsOptions[WireworldEvolve[iargs], {1, 2}];
		init = args[[1]];
		If[!WireworldStateQ[init],
			Return @ Failure["WireworldFailure", <|
				"MessageTemplate" -> "Initial state `1` should be a matrix of Wireworld cell states (`2`).",
				"MessageParameters" -> {init, StringRiffle[$cellStates, ", "]},
				"Input" -> init
			|>]
		];
		If[Length[args] === 1,
			tspec = 1
		,
			tspec = args[[2]]
		];

		Quiet[
			res = Check[
				WireworldEvolveFunction[init, tspec]
			,
				Failure["WireworldFailure", <|
					"MessageTemplate" -> "Time specification `1` should be t, {t}, {{t}}, {t1, t2}, or {t1, t2, dt} where t, t1, t2, and dt are machine integers and dt is positive.",
					"MessageParameters" -> {tspec},
					"Input" -> tspec
				|>]
			,
				{CellularAutomaton::offtg, CellularAutomaton::offts, CellularAutomaton::offtm}
			]
		,
			{CellularAutomaton::offtg, CellularAutomaton::offts, CellularAutomaton::offtm}
		];
		If[FailureQ[res] || Head[init] === List,
			Return[res]
		];

		If[MatchQ[tspec, {{_}}],
			SparseArray[res]
		,
			SparseArray /@ res
		]
	]

WireworldEvolveFunction = CellularAutomaton[$WireworldNumberRule, #1, {#2, Automatic}] &


(*******************************************************************************
Wireworld, WireworldQ
*******************************************************************************)

(*SyntaxInformation[Wireworld] = {
	"ArgumentsPattern" -> {_}
};

Wireworld[arg1_] ? System`Private`HoldEntryQ :=
	Module[{state},
		If[!WireworldStateQ[arg1],
			Return @ Failure["WireworldFailure", <|
				"MessageTemplate" -> "Argument `1` should be a matrix of Wireworld cell states (`2`).",
				"MessageParameters" -> {arg1, StringRiffle[$cellStates, ", "]},
				"Input" -> arg1
			|>]
		];
		If[ListQ[arg1],
			state = SparseArray[arg1]
		];
		System`Private`ConstructNoEntry[Wireworld, state]
	]

Wireworld /: HoldPattern[Normal[Wireworld[state_]]] := state;
Wireworld /: Dimensions[w_Wireworld ? WireworldQ] := Dimensions[Normal[w]];

SyntaxInformation[WireworldQ] = {
	"ArgumentsPattern" -> {_}
};

WireworldQ[expr_Wireworld] := System`Private`NoEntryQ[expr];
WireworldQ[_] := False;

stateIcon[state_] :=
	MatrixPlot[
		state,
		Frame -> False,
		PlotTheme -> "Basic",
		ColorRules \[Rule] $cellColorRules,
		MaxPlotPoints -> 30,
		Evaluate @ ElisionsDump`commonGraphicsOptions
	]

MakeBoxes[w_Wireworld, fmt_] /; WireworldQ[w] :=
	Module[{state, dims, icon},
		state = Normal[w];
		dims = Dimensions[state];
		icon = stateIcon[state];
		BoxForm`ArrangeSummaryBox[
			Wireworld,
			state,
			icon,
			{
				BoxForm`SummaryItem @ {"Rows: ", dims[[1]]},
				BoxForm`SummaryItem @ {"Columns: ", dims[[2]]}
			},
			{},
			fmt
		]
	]*)


Needs["Wireworld`WireworldDraw`"]


Needs["Wireworld`libWireworld`"]
Wireworld`Library`WireworldStep :=
	Module[{funs},
		funs = InitializeWireworldLibrary[];
		If[FailureQ[funs],
			Return[funs]
		];

		ClearAll[Wireworld`Library`WireworldStep];
		Wireworld`Library`WireworldStep = funs["wireworld_step"]
	]


End[] (* End Wireworld`Private`*)

EndPackage[]
