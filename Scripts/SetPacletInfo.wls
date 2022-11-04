#!/usr/bin/env wolframscript

$inputFileName  = Replace[ $InputFileName, "" :> NotebookFileName[ ] ];
$pacletDir      = DirectoryName[ $inputFileName, 2 ];
$pacletInfoFile = FileNameJoin @ { $pacletDir, "PacletInfo.wl" };

$actionURL = Module[ { domain, repo, runID },
    domain = Environment[ "GITHUB_SERVER_URL" ];
    repo   = Environment[ "GITHUB_REPOSITORY" ];
    runID  = Environment[ "GITHUB_RUN_ID"     ];
    URLBuild @ { domain, repo, "actions", "runs", runID }
];

Export[
    $pacletInfoFile,
    StringReplace[
        ReadString @ $pacletInfoFile,
        {
            "$ActionURL$" -> $actionURL,
            "$BuildDate$" -> DateString[ "DateTimeShort", TimeZone -> 0 ]
        }
    ],
    "String"
]