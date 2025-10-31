BeginPackage["DanielS`Wireworld`WireworldEvolve`"]


Begin["`Private`"]


Needs["DanielS`Wireworld`"]
Needs["DanielS`Wireworld`Utilities`"]
Needs["DanielS`Wireworld`libWireworld`"]


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
			FromDigits[states, Length[$CellStates]], (* Rule number *)
			Length[$CellStates], (* Number of colors *)
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
				"MessageParameters" -> {init, StringRiffle[$CellStates, ", "]},
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


End[]


EndPackage[]
