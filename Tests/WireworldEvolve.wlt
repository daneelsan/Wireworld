BeginTestSection["WireworldEvolve"]

VerificationTest[(* 1 *)
	Needs["DanielS`Wireworld`"]
	,
	Null	
	,
	TestID -> "f554552c-d138-41a3-8d11-ffd4bcb3e697@@Tests/WireworldEvolve.wlt:3,1-9,2"
]

VerificationTest[(* 2 *)
	DanielS`Wireworld`WireworldEvolve[{{0,  0, 0, 0, 3, 3, 0, 0, 0, 0, 0},  {3,  3, 2, 1, 3, 0, 3, 3, 2, 1, 3}, {0,  0, 0, 0, 3, 3, 0, 0, 0, 0, 0}}]
	,
	{{{0,  0, 0, 0, 3, 3, 0, 0, 0, 0, 0},  {3,  3, 2, 1, 3, 0, 3, 3, 2, 1, 3}, {0,  0, 0, 0, 3, 3, 0, 0, 0, 0, 0}},  {{0,  0, 0, 0, 1, 3, 0, 0, 0, 0, 0},  {3,  3, 3, 2, 1, 0, 3, 3, 3, 2, 1}, 
   {0,  0, 0, 0, 1, 3, 0, 0, 0, 0, 0}}}	
	,
	TestID -> "63b3815c-a84b-4e06-b699-a6bb1e12f479@@Tests/WireworldEvolve.wlt:11,1-18,2"
]

VerificationTest[(* 3 *)
	DanielS`Wireworld`WireworldEvolve[SparseArray[Automatic,  {5,  11}, 0, {1,  {{0,  0, 2, 12, 14, 14},  {{5},  {6}, {1}, {2}, {3}, {4}, {5}, {7}, {8}, {9}, {10}, {11}, {5}, {6}}}, 
    {3,  3, 3, 3, 2, 1, 3, 3, 3, 2, 1, 3, 3, 3}}],  2]
	,
	{SparseArray[Automatic,  {5,  11}, 0, {1,  {{0,  0, 2, 12, 14, 14},  {{5},  {6}, {1}, {2}, {3}, {4}, {5}, {7}, {8}, {9}, {10}, {11}, {5}, {6}}}, 
    {3,  3, 3, 3, 2, 1, 3, 3, 3, 2, 1, 3, 3, 3}}],  SparseArray[Automatic,  {5,  11}, 0, 
   {1,  {{0,  0, 2, 12, 14, 14},  {{5},  {6}, {1}, {2}, {3}, {4}, {5}, {7}, {8}, {9}, {10}, {11}, {5}, {6}}}, {1,  3, 3, 3, 3, 2, 1, 3, 3, 3, 2, 1, 1, 3}}], 
  SparseArray[Automatic,  {5,  11}, 0, {1,  {{0,  0, 2, 12, 14, 14},  {{5},  {6}, {1}, {2}, {3}, {4}, {5}, {7}, {8}, {9}, {10}, {11}, {5}, {6}}}, 
    {2,  1, 1, 3, 3, 3, 2, 3, 3, 3, 3, 2, 2, 1}}]}	
	,
	TestID -> "62dcb28c-cdbe-49af-bdaa-9071e6cc0c1f@@Tests/WireworldEvolve.wlt:20,1-31,2"
]

VerificationTest[(* 4 *)
	DanielS`Wireworld`WireworldEvolve[SparseArray[Automatic,  {3,  5}, 0, {1,  {{0,  0, 5, 5},  {{1},  {2}, {3}, {4}, {5}}}, {3,  3, 2, 1, 3}}],  {2}]
	,
	{SparseArray[Automatic,  {3,  5}, 0, {1,  {{0,  0, 5, 5},  {{1},  {2}, {3}, {4}, {5}}}, {1,  3, 3, 3, 2}}]}	
	,
	TestID -> "41f9a3fb-6690-4456-a2dc-f7e1d186466f@@Tests/WireworldEvolve.wlt:33,1-39,2"
]

VerificationTest[(* 5 *)
	DanielS`Wireworld`WireworldEvolve[SparseArray[Automatic,  {3,  5}, 0, {1,  {{0,  0, 5, 5},  {{1},  {2}, {3}, {4}, {5}}}, {3,  3, 2, 1, 3}}],  {{2}}]
	,
	SparseArray[Automatic,  {3,  5}, 0, {1,  {{0,  0, 5, 5},  {{1},  {2}, {3}, {4}, {5}}}, {1,  3, 3, 3, 2}}]	
	,
	TestID -> "ed10c46b-fbf5-434d-8da6-575b1d7062eb@@Tests/WireworldEvolve.wlt:41,1-47,2"
]

VerificationTest[(* 6 *)
	DanielS`Wireworld`WireworldEvolve[SparseArray[Automatic,  {3,  5}, 0, {1,  {{0,  0, 5, 5},  {{1},  {2}, {3}, {4}, {5}}}, {3,  3, 2, 1, 3}}],  {50,  60, 2}]
	,
	{SparseArray[Automatic,  {3,  5}, 0, {1,  {{0,  0, 5, 5},  {{1},  {2}, {3}, {4}, {5}}}, {3,  3, 2, 1, 3}}],  
  SparseArray[Automatic,  {3,  5}, 0, {1,  {{0,  0, 5, 5},  {{1},  {2}, {3}, {4}, {5}}}, {1,  3, 3, 3, 2}}], 
  SparseArray[Automatic,  {3,  5}, 0, {1,  {{0,  0, 5, 5},  {{1},  {2}, {3}, {4}, {5}}}, {3,  2, 1, 3, 3}}], 
  SparseArray[Automatic,  {3,  5}, 0, {1,  {{0,  0, 5, 5},  {{1},  {2}, {3}, {4}, {5}}}, {3,  3, 3, 2, 1}}], 
  SparseArray[Automatic,  {3,  5}, 0, {1,  {{0,  0, 5, 5},  {{1},  {2}, {3}, {4}, {5}}}, {2,  1, 3, 3, 3}}], 
  SparseArray[Automatic,  {3,  5}, 0, {1,  {{0,  0, 5, 5},  {{1},  {2}, {3}, {4}, {5}}}, {3,  3, 2, 1, 3}}]}	
	,
	TestID -> "bd53546b-751c-42e5-a5dd-32e8320659de@@Tests/WireworldEvolve.wlt:49,1-60,2"
]

VerificationTest[
  DanielS`Wireworld`WireworldEvolve[{{3, 3, 1, 2, "a"}}],
  Failure["WireworldFailure", Association["MessageTemplate" -> "Initial state `1` should be a matrix of Wireworld cell states (`2`).", "MessageParameters" -> {{{3, 3, 1, 2, "a"}}, "0, 1, 2, 3"}, "Input" -> {{3, 3, 1, 2, "a"}}]],
  TestID -> "Untitled-2@@Tests/WireworldEvolve.wlt:62,1-67,2"
]

VerificationTest[(* 8 *)
	DanielS`Wireworld`WireworldEvolve[{{3,  3, 1, 2, 3}},  {{{2}}}]
	,
	Failure["WireworldFailure",  
  Association["MessageTemplate" -> "Time specification `1` should be t, {t}, {{t}}, {t1, t2}, or {t1, t2, dt} where t, t1, t2, and dt are machine integers and dt is positive.",  
   "MessageParameters" -> {{{{2}}}}, "Input" -> {{{2}}}]]	
	,
	TestID -> "1454aa6e-243c-494d-8b76-83ddbb42929d@@Tests/WireworldEvolve.wlt:69,1-77,2"
]

EndTestSection[]
