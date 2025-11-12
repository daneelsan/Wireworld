BeginPackage["DanielS`Wireworld`Utilities`"]


$CellStateInformation::usage =
	"$CellStateInformation is an association mapping Wireworld cell states to their names and colors.";


$CellStates::usage =
	"$CellStates is a list of all possible Wireworld cell states.";


$CellColorRules::usage =
	"$CellColorRules is an association mapping Wireworld cell states to their corresponding colors.";


Begin["`Private`"]


$CellStateInformation = <|
	0 -> <|"Name" -> "empty", "Color" -> RGBColor[0, 0, 0] (* Black *)|>,
	1 -> <|"Name" -> "electron head", "Color" -> RGBColor[1, 1, 1] (* White *)|>,
	2 -> <|"Name" -> "electron tail", "Color" -> RGBColor[0, 0.5, 1] (* Blue *)|>,
	3 -> <|"Name" -> "wire", "Color" -> RGBColor[1, 0.5, 0] (* Orange *)|>
|>;


$CellStates =
	Keys[$CellStateInformation];


$CellColorRules =
	Normal[$CellStateInformation[[All, "Color"]]];


End[]

EndPackage[]
