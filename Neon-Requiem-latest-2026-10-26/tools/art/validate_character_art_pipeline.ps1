param(
	[string]$GodotConsolePath = 'C:\Users\Work\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe'
)

$ErrorActionPreference = 'Stop'
$projectRoot = (Resolve-Path (Join-Path $PSScriptRoot '../..')).Path

if (-not (Test-Path -LiteralPath $GodotConsolePath -PathType Leaf)) {
	Write-Error "Godot console executable not found: $GodotConsolePath. Pass -GodotConsolePath with the Godot 4 console executable."
	exit 2
}

Write-Host '[1/3] Full Python regression suite (preflighted)'
Push-Location $projectRoot
try {
	& python 'tests/run_python_tests.py'
	if ($LASTEXITCODE -ne 0) {
		Write-Error "Python regression suite failed or was blocked (exit $LASTEXITCODE)."
		exit $LASTEXITCODE
	}

	Write-Host '[2/3] Twelve-recruit workspace and attachment-plan audit'
	& python 'tools/art/audit_rigging_prep_all_12.py'
	if ($LASTEXITCODE -ne 0) {
		Write-Error "Twelve-recruit prep audit failed (exit $LASTEXITCODE)."
		exit $LASTEXITCODE
	}

	Write-Host '[3/3] Godot headless project and quarantined-art preflights'
	& $GodotConsolePath --headless --path $projectRoot --script 'res://tests/test_runner.gd'
	if ($LASTEXITCODE -ne 0) {
		Write-Error "Godot test runner failed (exit $LASTEXITCODE)."
		exit $LASTEXITCODE
	}
}
finally {
	Pop-Location
}

Write-Host 'PASS: Python suite, all-12 prep audit, and Godot regression suite completed.'
Write-Host 'LIMIT: art candidates remain quarantined; tests do not replace visual, semantic, pivot, deformation, or production approval.'
