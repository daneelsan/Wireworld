BeginTestSection["WireworldStateQ"]

VerificationTest[(* 1 *)
	Needs["DanielS`Wireworld`"]
	,
	Null	
	,
	TestID -> "647c3b0f-2c68-4ba7-9109-d5c06ae7138c@@Tests/WireworldStateQ.wlt:3,1-9,2"
]

VerificationTest[(* 2 *)
	DanielS`Wireworld`WireworldStateQ[{{0,  0, 0, 0, 3, 3, 0, 0, 0, 0},  
   {3,  3, 2, 1, 3, 0, 3, 3, 2, 1}, {0,  0, 0, 0, 3, 3, 0, 0, 0, 0}}]
	,
	True	
	,
	TestID -> "d29b847b-8cad-44e5-b3a3-cc01fbacd76e@@Tests/WireworldStateQ.wlt:11,1-18,2"
]

VerificationTest[(* 3 *)
	DanielS`Wireworld`WireworldStateQ[SparseArray[Automatic,  {3,  10}, 0, 
   {1,  {{0,  5, 10, 15},  {{6},  {7}, {8}, {9}, {10}, {1}, {2}, {3}, {4}, {5}, {6}, {7}, 
      {8}, {9}, {10}}}, {1,  3, 3, 3, 3, 3, 3, 3, 3, 2, 1, 3, 3, 3, 3}}]]
	,
	True	
	,
	TestID -> "cacab01a-9512-4a95-a1bf-0d8ca811e3a7@@Tests/WireworldStateQ.wlt:20,1-28,2"
]

VerificationTest[(* 4 *)
	DanielS`Wireworld`WireworldStateQ[{{1},  {2,  3}}]
	,
	False	
	,
	TestID -> "cbb1a626-f430-43be-8947-3663dfe52990@@Tests/WireworldStateQ.wlt:30,1-36,2"
]

VerificationTest[(* 5 *)
	DanielS`Wireworld`WireworldStateQ[{{0,  5},  {2,  3}}]
	,
	False	
	,
	TestID -> "2fb2d6d6-93f5-475c-8583-1197601ba383@@Tests/WireworldStateQ.wlt:38,1-44,2"
]

EndTestSection[]
