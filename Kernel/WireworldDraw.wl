(* ::Package:: *)

BeginPackage["DanielS`Wireworld`WireworldDraw`"]

Needs["Wireworld`"]

Begin["`Private`"]


SyntaxInformation[Wireworld`WireworldDraw] = {
	"ArgumentsPattern" -> {_, OptionsPattern[]}
};

expr : Wireworld`WireworldDraw[___] /; CheckArguments[expr, {0, 1}] :=
	Module[{args, opts, init},
		{args, opts} = ArgumentsOptions[expr, {0, 1}];
		init = First[args];
		If[ListQ[init] && Length[init] === 2 && AllTrue[init, Function[n, IntegerQ[n] && n > 0]],
			init = SparseArray[ConstantArray[0, init]]
		];
		If[!WireworldStateQ[init],
			Return @ Failure["WireworldFailure", <|
				"MessageTemplate" -> "Argument `1` should be a list specifying the number of rows and columns of a new Wireworld state or a matrix of Wireworld cell states (`2`).",
				"MessageParameters" -> {init, StringRiffle[Wireworld`Private`$cellStates, ", "]},
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
	$dragPoints = <||>;
)

setState[state_] := (
	$state = state;
	{$rows, $columns} = Dimensions[state];
)

$maxHistoryLength = 100;

recordState[state_] :=
	Which[
		$positionInTime === Length[$history],
			$positionInTime += 1;
			If[Length[$history] > $maxHistoryLength,
				$history = Drop[$history, 1];
			];
			AppendTo[$history, state];
			setState[state];
		,
		$positionInTime < Length[$history],
			$history = Take[$history, $positionInTime];
			recordState[state];
		,
		True, (* should be unreachable *)
			$history = {};
			$positionInTime = 0;
			recordState[state];
	]

clearAllVariables[] :=
	ClearAll[
		$state,
		$rows,
		$columns,
		$history,
		$positionInTime,
		$escaped,
		(*$buttonPressed,*)
		$dragPoints
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

handleMouseClicked[mode_, pos_] :=
	Module[{npos},
		npos = fixMousePosition[pos];
		If[npos === None,
			Return[]
		];
		Switch[mode,
			Automatic,
				(* background -> wire, tail -> head, head -> background, wire -> tail *)
				recordState[ReplacePart[$state, npos -> {3, 2, 0, 1}[[Extract[$state, npos] + 1]]]]
			,
			_Integer,
				recordState[ReplacePart[$state, npos -> mode]]
			,
			_,
				(* unreachable *)
				Beep[]
		]
	]

handleMouseUp[mode_, pos_] := (
	If[TrueQ[$escaped || $buttonPressed],
		$escaped = False;
		$buttonPressed = False;
	,
		If[Length[$dragPoints] === 0,
			Return[]
		];
		Switch[mode,
			Automatic,
				recordState[ReplacePart[$state, Keys[$dragPoints] -> 3]]
			,
			_Integer,
				recordState[ReplacePart[$state, Keys[$dragPoints] -> mode]]
			,
			_,
				Beep[]
		]
	];
	$dragPoints = <||>;
)

handleMouseDragged[_, pos_] :=
	If[!TrueQ[$escaped],
		With[{npos = fixMousePosition[pos]},
			If[npos === None,
				$dragPoints = <||>;
				Return[]
			];
			If[KeyExistsQ[$dragPoints, npos],
				KeyDrop[$dragPoints, npos]
			,
				$dragPoints[npos] = True
			]
		]
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

SetAttributes[framedButton, {HoldRest}]
framedButton[{arg1_, label_}, args___] :=
	framedButton[Tooltip[arg1, label], args]
framedButton[arg1_, args___] :=
	Button[onGraphicFramed[arg1], ($buttonPressed = True; args), Appearance -> None]

lowerLeftButtons[] :=
	Grid[
		{{
			framedButton[{"Undo", "undo"}, undo[]],
			framedButton[{"Redo", "redo"}, redo[]],
			framedButton[{"Clear", "clear drawing"}, recordState[SparseArray[ConstantArray[0, Dimensions[$state]]]]]
		}},
		ImageSize -> {15, 15}
	]

lowerRightButtons[] :=
	Grid[
		{{
			framedButton[{"Return", "return state"}, returnState[]],
			framedButton[{"Cancel", "cancel"}, escape[]]
		}},
		ImageSize -> {15, 15}
	]

getStatePlot[state_, opts_] :=
	Wireworld`Private`iWireworldPlot[
		state,
		Epilog -> {
			lowerLeftButtons[],
			lowerRightButtons[]
		},
		opts
	]

topAlignedRow[list_] := Grid[{list}, Alignment -> Top, Spacings -> {0, 0}]

mainPanel[] :=
	EventHandler[
		Dynamic[Wireworld`Private`iWireworldPlot[$state, {}]],
		(*Dynamic[getStatePlot[$state, PlotRangePadding -> Scaled[0.075]]],*)
		{
			"MouseClicked" :> handleMouseClicked[Automatic, MousePosition["Graphics"]],
			"MouseDragged" :> handleMouseDragged[Automatic, MousePosition["Graphics"]],
			"MouseUp" :> handleMouseUp[Automatic, MousePosition["Graphics"]]
		}
	]

dialogInput[nb_, opts_] :=
	DialogInput[
		mainPanel[],
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

End[]

EndPackage[]
