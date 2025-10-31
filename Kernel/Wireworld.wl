(* ::Package:: *)

BeginPackage["DanielS`Wireworld`"]

WireworldStateQ
$WireworldFunctionRule
$WireworldNumberRule
WireworldEvolve
WireworldPlot
ParseWireworld

WireworldQ
Wireworld

WireworldDraw


ClearAll["DanielS`Wireworld`*"]
ClearAll["DanielS`Wireworld`Private`*"]

Begin["`Private`"]  (* Begin Wireworld`Private`*)

Needs["DanielS`Wireworld`libWireworld`"]


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

WireworldStateQ[_?WireworldQ] := True;

WireworldStateQ[na_?NumericArrayQ] :=
	WireworldStateQ[Normal[na]];

WireworldStateQ[state_] :=
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
				"MessageParameters" -> {arg1, StringRiffle[$cellStates, ", "]},
				"Input" -> arg1
			|>]
		];
		meshOpt = OptionValue[WireworldPlot, {Mesh -> None}, Mesh];
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

Options[WireworldEvolve] = {
	Method -> Automatic
};

WireworldEvolve[iargs___] /; CheckArguments[WireworldEvolve[iargs], {1, 2}] :=
	Module[{args, opts, init, state, tspec, res, head},
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
		state = Wireworld[init];
		If[OptionValue[WireworldEvolve, {opts}, Method] === "Library",
			iWireworldEvolveLibrary[state, tspec]
			,
			res = iWireworldEvolveBuiltin[state, tspec];
			If[FailureQ[res] || Head[init] === List,
				Return[res]
			];
			head = Head[init];
			If[MatchQ[tspec, {{_}}],
				head[res]
				,
				head /@ res
			]
		]
	];


iWireworldEvolveBuiltin[state_, tspec_] :=
	Quiet[
		Check[
			WireworldEvolveFunction[Normal[state], tspec]
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


(* WireworldEvolveFunction is a wrapper around the CellularAutomaton function for the Wireworld cellular automaton *)
WireworldEvolveFunction = CellularAutomaton[$WireworldNumberRule, #1, {#2, Automatic}] &


iWireworldEvolveLibrary[init_?WireworldQ] :=
	Wireworld[WireworldStep[init]];

iWireworldEvolveLibrary[init_?WireworldQ, {{1}}] :=
	iWireworldEvolveLibrary[init];

iWireworldEvolveLibrary[init_?WireworldQ, {{tspec_}}] :=
	Wireworld[WireworldRun[Normal[init], tspec]];

iWireworldEvolveLibrary[init_?WireworldQ, tspec_Integer] :=
	Wireworld /@ NestList[WireworldRun[#, 1] &, Normal[init], tspec];

iWireworldEvolveLibrary[init_, tspec_] :=
	$Failed;


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
				"MessageParameters" -> {arg1, StringRiffle[$cellStates, ", "]},
				"Input" -> arg1
			|>]
		];
		state = NumericArray[arg1, "UnsignedInteger8"];
		System`Private`ConstructNoEntry[Wireworld, state]
	]

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
		ColorRules -> $cellColorRules,
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
			state,
			icon,
			{
				BoxForm`SummaryItem @ {"Rows: ", dims[[1]]},
				BoxForm`SummaryItem @ {"Columns: ", dims[[2]]}
			},
			{},
			fmt
		]
	];


Needs["DanielS`Wireworld`WireworldDraw`"]


(*******************************************************************************
ParseWireworld
*******************************************************************************)

ParseWireworld[File[file_]] /; FileExistsQ[file] :=
	ParseWireworld[Import[file, "Text"]];

ParseWireworld[str_String]:=
	Module[{state, dims},
		state = StringSplit[str, "\n"];
		(* Drop first line *)
		state = Rest[state];
		(* Determine dimensions *)
		dims = {Length[state], Max[StringLength /@ state]};
		(* Pad lines *)
		state = StringPadRight[state, dims[[2]], " "];
		(* Convert to characters *)
		state = Characters /@ state;
		(* Convert to cell states (see https://wiki.logre.eu/index.php/Projet_Wireworld/en#File_formats) *)
		state = state /. {" "|"." -> 0, "#" -> 3, "~" -> 2, "@" -> 1};
		(* Convert to SparseArray *)
		SparseArray[state]
	];


End[] (* End Wireworld`Private`*)

EndPackage[]
