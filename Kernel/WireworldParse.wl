BeginPackage["DanielS`Wireworld`WireworldParse`"]


Begin["`Private`"]


Needs["DanielS`Wireworld`"]


WireworldParse[File[file_]] /; FileExistsQ[file] :=
	WireworldParse[Import[file, "Text"]];

WireworldParse[str_String]:=
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
		Wireworld[state]
	];


End[]


EndPackage[]
