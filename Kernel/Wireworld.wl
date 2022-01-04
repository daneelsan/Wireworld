(* ::Package:: *)

BeginPackage["Wireworld`"]

WireworldStateQ
$WireworldRule
WireworldEvolve
WireworldPlot
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
	3 -> <|"Name" -> "conductor", "Color" -> RGBColor[1, 0.5, 0] (* Orange *)|>
|>;

$cellStates = Keys[$cellStateInformation];

$cellColorRules = $cellStateInformation[[All, "Color"]];


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
$WireworldRule
*******************************************************************************)

(* Adapted from https://codegolf.stackexchange.com/a/44683/110183 *)
$WireworldRule = {
	Switch[#[[2, 2]],
		(* empty -> empty *)
		0, 0,
		(* electron head -> electron tail *)
		1, 2,
		(* electron tail -> conductor *)
		2, 3,
		(* conductor -> electron head if exactly one or two of the neighbouring cells are electron heads, otherwise remains conductor *)
		3, If[0 < Count[#, 1, 2] < 3, 1, 3]
	] &,
	{}, (* always {} when the first argument is a function *)
	{1, 1} (* Moore neighborhood *)
};


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
		If[FailureQ[res],
			Return[res]
		];

		If[MatchQ[tspec, {{_}}],
			SparseArray[res]
		,
			SparseArray /@ res
		]
	]

WireworldEvolveFunction = Function[{init, tspec}, CellularAutomaton[$WireworldRule, init, {tspec, All}]]


(*******************************************************************************
WireworldDraw
*******************************************************************************)

SyntaxInformation[WireworldDraw] = {
	"ArgumentsPattern" -> {_, OptionsPattern[]}
};

WireworldDraw[iargs___] /; CheckArguments[WireworldDraw[iargs], {0, 1}] :=
	Module[{args, opts, init},
		{args, opts} = ArgumentsOptions[WireworldDraw[iargs], {0, 1}];
		init = First[args];
		If[ListQ[init] && Length[init] === 2 && AllTrue[init, Function[n, IntegerQ[n] && n > 0]],
			init = SparseArray[ConstantArray[0, init]]
		];
		If[!WireworldStateQ[init],
			Return @ Failure["WireworldFailure", <|
				"MessageTemplate" -> "Argument `1` should be a list specifying the number of rows and columns of a new Wireworld state or a matrix of Wireworld cell states (`2`).",
				"MessageParameters" -> {init, StringRiffle[$cellStates, ", "]},
				"Input" -> init
			|>]
		];
		If[Head[init] === List,
			init = SparseArray[init]
		];
		iWireworldDraw[init, opts]
	]

iWireworldDraw[init_, opts___] :=
	Block[{$notebook},
		WithCleanup[
			resetVariables[];
			recordState[init];
		,
			dialogInput[$notebook, FilterRules[{opts}, Options[DialogInput]]]
		,
			clearAllVariables[];
			NotebookClose[$notebook]
		]
	]

resetVariables[] := (
	$history = {};
	$positionInTime = 0;
	$escaped = False;
	$buttonPressed = False;
	$startPoint = None;
	$endPoint = None;
)

setState[state_] := (
	$state = state;
	{$rows, $columns} = Dimensions[state];
)

recordState[state_] :=
	Which[
		$positionInTime === Length[$history],
			$positionInTime += 1;
			AppendTo[$history, state];
			setState[state];,
		$positionInTime < Length[$history],
			$history = Take[$history, $positionInTime];
			recordState[state];,
		True, (* should be unreachable *)
			$history = {};
			$positionInTime = 0;
			recordState[state];
	]

clearAllVariables[] := ClearAll[
	$state,
	$rows,
	$columns,
	$history,
	$positionInTime,
	$escaped,
	$buttonPressed,
	$startPoint,
	$endPoint
]

dialogReturn[arg_] := (clearAllVariables[]; DialogReturn[arg])

returnState[] := dialogReturn[$state]

escape[] :=
	If[CurrentValue["MouseButtons"] === {},
		dialogReturn[$Canceled]
	,
		$escaped = True;
	]

undo[] :=
	If[Length[$history] > 1 && $positionInTime > 1,
		$positionInTime -= 1;
		setState[$history[[$positionInTime]]];
	,
		Beep[]
	]

redo[] :=
	If[$positionInTime < Length[$history],
		$positionInTime += 1;
		setState[$history[[$positionInTime]]];
	,
		Beep[]
	]

fixMousePosition[{x_, y_}] :=
	Module[{nx, ny},
		nx = $rows + 1 - Ceiling[y];
		ny = Ceiling[x];
		If[1 <= nx <= $rows && 1 <= ny <= $columns,
			{nx, ny}
		,
			None
		]
	]
fixMousePosition[_] := None

handleMouseDown[mode_, pos_] :=
	Module[{npos},
		npos = fixMousePosition[pos];
		If[npos === None,
			Return[]
		];
		Switch[mode,
			Automatic,
				(* background -> wire, tail -> head, head -> background, wire -> tail *)
				recordState[ReplacePart[$state, npos -> {3, 2, 0, 1}[[Extract[$state, npos] + 1]]]],
			_Integer,
				recordState[ReplacePart[$state, npos -> mode]],
			_,
				(* unreachable *)
				dialogReturn[$Canceled]
		]
	]

handleMouseUp[mode_, pos_] := (
	If[TrueQ[$escaped || $buttonPressed],
		$escaped = False;
		$buttonPressed = False;
	,
		With[{npos = DeleteCases[fixMousePosition /@ $dragPoints["Elements"], None]},
			recordState[ReplacePart[$state, npos -> 3]]
		]
	];
	$dragPoints["DropAll"];
	$startPoint = None;
	$endPoint = None;
)

$dragPoints := $dragPoints = CreateDataStructure["DynamicArray"];

handleMouseDragged[_, {x_, y_}] :=
	If[!TrueQ[$escaped],
		$dragPoints["Append", $endPoint = {x, y}]
	];

onGraphicFramed[x_] :=
	Framed[x,
		RoundingRadius -> 5,
		FrameMargins -> {{5, 5}, {2, 2}},
		Alignment -> Center,
		Background -> White,
		FrameStyle -> Dynamic[
			Directive[
				If[CurrentValue["MouseOver"],
					RGBColor[0.205997, 0.736172, 0.930205],
					GrayLevel @ 0.7
				],
				AbsoluteThickness[1]
			]
		]
	]

Attributes[framedButton] = {HoldRest}
framedButton[{arg1_, label_}, args___] := framedButton[Tooltip[arg1, label], args]
framedButton[arg1_, args___] := Button[onGraphicFramed[arg1], $buttonPressed = True; args, Appearance -> None]

lowerLeftButtons[] :=
	Grid[{{
		framedButton[{"Undo", "undo"}, undo[]],
		framedButton[{"Redo", "redo"}, redo[]],
		framedButton[{"Clear", "clear drawing"}, recordState[SparseArray[ConstantArray[0, Dimensions[$state]]]]]
	}}]

lowerRightButtons[] :=
	Grid[{{
		framedButton[{"Return", "return state"}, returnState[]],
		framedButton[{"Cancel", "cancel"}, escape[]]
	}}]

getStatePlot[state_, opts_] :=
	iWireworldPlot[
		state,
		opts,
		Epilog -> {
			lowerLeftButtons[],
			lowerRightButtons[]
		}
	]

topAlignedRow[list_] := Grid[{list}, Alignment -> Top, Spacings -> {0, 0}]

dialogInput[nb_, opts_] :=
	DialogInput[
		EventHandler[
			Dynamic[iWireworldPlot[$state, {}]],
			{
				"MouseDown" :> handleMouseDown[Automatic, MousePosition["Graphics"]],
				"MouseDragged" :> handleMouseDragged[Automatic, MousePosition["Graphics"]],
				"MouseUp" :> handleMouseUp[Automatic, MousePosition["Graphics"]]
			}
		],
		NotebookEventActions -> {
			"EscapeKeyDown" :> escape[],
			"WindowClose" :> dialogReturn[$Canceled],
			{"MenuCommand", "Undo"} :> undo[],
			{"MenuCommand", "Redo"} :> redo[],
			{"MenuCommand", "HandleShiftReturn"} :> returnState[]
		},
		WindowTitle -> "WireworldDraw",
		WindowElements -> {"MagnificationPopUp", "StatusArea"},
		WindowFrameElements -> {"CloseBox", "ZoomBox", "ResizeArea"},
		Initialization :> Function[dialog, nb = dialog],
		opts
	]

(*WireworldSimpleDraw[init_, opts___] :=
	DynamicModule[{m, height, pos, x, y},
		m = init;
		height = Dimensions[init][[1]];
		Dynamic @ EventHandler[
			WireworldPlot[m],
			"MouseDown" \[RuleDelayed] (
				pos = MousePosition["Graphics"];
				If[pos =!= None,
					{x, y} = {height + 1 - #\[LeftDoubleBracket]2\[RightDoubleBracket], #\[LeftDoubleBracket]1\[RightDoubleBracket]} &@ Ceiling[pos];
					(* m\[LeftDoubleBracket]x, y\[RightDoubleBracket] = Mod[m\[LeftDoubleBracket]x, y\[RightDoubleBracket] + 1, 4]; *)
					m\[LeftDoubleBracket]x, y\[RightDoubleBracket] = {3, 2, 0, 1}[[m[[x, y]] + 1]];
				]
			)
		]
	]*)


End[] (* End Wireworld`Private`*)

EndPackage[]
