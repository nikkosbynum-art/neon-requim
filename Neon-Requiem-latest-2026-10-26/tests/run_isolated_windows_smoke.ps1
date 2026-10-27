[CmdletBinding()]
param(
    [string]$GodotGui = 'C:\Users\Work\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64.exe',
    [string]$GodotConsole = 'C:\Users\Work\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe',
    [string]$ApprovedTempRoot = 'C:\Users\Work\.codex\visualizations\2026\10\24\01a16c69-9c16-7e31-a6d9-fd542d45d004',
    [switch]$VisualAuditOnly
)

$ErrorActionPreference = 'Stop'
$projectRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$approvedTempRoot = $ApprovedTempRoot
if (-not (Test-Path -LiteralPath $approvedTempRoot -PathType Container)) {
    throw "Approved isolated test root is missing: $approvedTempRoot"
}
$runId = [Guid]::NewGuid().ToString('N')
$projectName = "Neon Requiem QA $runId"
$tempRoot = Join-Path $approvedTempRoot "NeonRequiem_WindowsSmoke_$runId"
$captureOutputRoot = Join-Path $approvedTempRoot "Recruitment_Layout_Captures_$runId"
$isolatedProject = Join-Path $tempRoot 'project'
$isolatedAppDataRoot = Join-Path $tempRoot 'appdata'
$expectedUserData = Join-Path (Join-Path $isolatedAppDataRoot 'Godot\app_userdata') $projectName
$realSave = Join-Path (Join-Path $env:APPDATA 'Godot\app_userdata\Neon Requiem') 'neon_requiem_save.json'
$realSaveHashBefore = $null
$originalAppData = $env:APPDATA
if (Test-Path -LiteralPath $realSave -PathType Leaf) {
    $realSaveHashBefore = (Get-FileHash -Algorithm SHA256 -LiteralPath $realSave).Hash
}
if (Test-Path -LiteralPath $expectedUserData) {
    throw "Refusing to use an existing user-data folder: $expectedUserData"
}
if (-not (Test-Path -LiteralPath $GodotGui -PathType Leaf)) { throw "Godot GUI executable not found: $GodotGui" }
if (-not (Test-Path -LiteralPath $GodotConsole -PathType Leaf)) { throw "Godot console executable not found: $GodotConsole" }

New-Item -ItemType Directory -Path $isolatedProject -Force | Out-Null
Copy-Item -LiteralPath (Join-Path $projectRoot 'project.godot') -Destination $isolatedProject
foreach ($relative in @('scenes', 'scripts', 'data', 'tests', 'tools')) {
    $sourceDirectory = Join-Path $projectRoot $relative
    $destinationDirectory = Join-Path $isolatedProject $relative
    New-Item -ItemType Directory -Path $destinationDirectory -Force | Out-Null
    Copy-Item -Path (Join-Path $sourceDirectory '*') -Destination $destinationDirectory -Recurse -Force
}
$addonsSource = Join-Path $projectRoot 'addons'
$addonsDestination = Join-Path $isolatedProject 'addons'
New-Item -ItemType Directory -Path $addonsDestination -Force | Out-Null
Copy-Item -Path (Join-Path $addonsSource '*') -Destination $addonsDestination -Recurse -Force
$assetRoot = Join-Path $isolatedProject 'assets\characters'
$breakerDrafts = Join-Path $assetRoot 'breaker\tier_01_drafts'
New-Item -ItemType Directory -Path $breakerDrafts -Force | Out-Null
foreach ($file in @('.gdignore', 'BREAKER_T1_head_candidate_01.png', 'BREAKER_T1_modular_parts_atlas_draft_01.png', 'BREAKER_T1_modular_parts_atlas_draft_02.png')) {
    Copy-Item -LiteralPath (Join-Path (Join-Path $projectRoot 'assets\characters\breaker\tier_01_drafts') $file) -Destination $breakerDrafts -Force
}
foreach ($character in @('bulwark', 'spark', 'specter', 'ironclad', 'stitch', 'recoil', 'echo', 'vector', 'deadlock', 'glitch')) {
    $profileRelative = "assets\characters\$character\tier_01_drafts\profile_mesh_rig_candidate_01"
    $profileSource = Join-Path $projectRoot $profileRelative
    $profileDestination = Join-Path $isolatedProject $profileRelative
    New-Item -ItemType Directory -Path $profileDestination -Force | Out-Null
    $imageName = "$($character.ToUpperInvariant())_T1_VISIBLE_PROFILE_MESH_INPUT_CANDIDATE_01.png"
    Copy-Item -LiteralPath (Join-Path $profileSource $imageName) -Destination $profileDestination -Force
}
foreach ($relative in @(
    'assets\characters\spark\tier_01_drafts\attachment_cutout_candidate_01',
    'assets\characters\specter\tier_01_drafts\attachment_cutout_candidate_01',
    'assets\characters\cipher\tier_01_drafts\reference_cutout_rig_candidate_01',
    'assets\characters\cipher\tier_01_drafts\reference_cutout_rig_candidate_07',
    'assets\characters\cipher\tier_01_drafts\reference_cutout_rig_candidate_09_knee_guard_review_02'
)) {
    $sourceDirectory = Join-Path $projectRoot $relative
    $destinationDirectory = Join-Path $isolatedProject $relative
    New-Item -ItemType Directory -Path $destinationDirectory -Force | Out-Null
    Copy-Item -Path (Join-Path $sourceDirectory '*') -Destination $destinationDirectory -Recurse -Force
}
$visualQaDestination = Join-Path $isolatedProject 'docs\visual_qa'
New-Item -ItemType Directory -Path $visualQaDestination -Force | Out-Null
Copy-Item -LiteralPath (Join-Path $projectRoot 'docs\visual_qa\CIPHER_T1_ANATOMY_TURNAROUND_01_2026-10-25.png') -Destination $visualQaDestination -Force
$configPath = Join-Path $isolatedProject 'project.godot'
$config = Get-Content -Raw -LiteralPath $configPath
$oldName = 'config/name="Neon Requiem"'
if (-not $config.Contains($oldName)) { throw 'Expected project-name setting was not found in the isolated config copy.' }
$config = $config.Replace($oldName, "config/name=`"$projectName`"")
Set-Content -LiteralPath $configPath -Value $config -Encoding utf8

try {
    New-Item -ItemType Directory -Path $isolatedAppDataRoot -Force | Out-Null
    $env:APPDATA = $isolatedAppDataRoot

    $importLog = Join-Path $tempRoot 'editor_import.log'
    & $GodotConsole --headless --editor --path $isolatedProject --quit --log-file $importLog
    $importExit = $LASTEXITCODE
    if ($importExit -ne 0) { throw "Godot clean editor import exited with code $importExit; log: $importLog" }
    if (-not (Test-Path -LiteralPath $importLog -PathType Leaf)) { throw 'Godot did not create the clean editor-import log.' }
    $importText = Get-Content -Raw -LiteralPath $importLog
    if ($importText -match '(?im)^.*(SCRIPT ERROR|Parse Error|Failed to load script|ERROR:.*autoload).*$') {
        throw "Godot clean editor import contains a script/autoload error: $($Matches[0])"
    }
    Write-Output 'PASS: fresh Godot editor import generated project class metadata without script/autoload errors.'

    $captureLog = Join-Path $tempRoot 'recruitment_capture.log'
    $captureArguments = "--path `"$isolatedProject`" --script res://tests/capture_recruitment_layout.gd --rendering-method gl_compatibility --log-file `"$captureLog`""
    $captureProcess = Start-Process -FilePath $GodotGui -ArgumentList $captureArguments -Wait -PassThru
    if ($captureProcess.ExitCode -ne 0) { throw "Godot Recruitment layout capture exited with code $($captureProcess.ExitCode); log: $captureLog" }
    if (-not (Test-Path -LiteralPath $captureLog -PathType Leaf)) { throw 'Godot did not create the Recruitment capture log.' }
    $captureText = Get-Content -Raw -LiteralPath $captureLog
    if ($captureText -match '(?im)^.*(SCRIPT ERROR|Parse Error|Failed to load script).*$') {
        throw "Godot Recruitment layout capture contains a script error: $($Matches[0])"
    }
    $capturePaths = @(
        (Join-Path $isolatedProject 'tests\recruitment_ui_800x450.png'),
        (Join-Path $isolatedProject 'tests\recruitment_ui_1280x720.png')
    )
    foreach ($capturePath in $capturePaths) {
        if (-not (Test-Path -LiteralPath $capturePath -PathType Leaf)) { throw "Expected Recruitment layout capture was not produced: $capturePath" }
    }
    $resolvedCaptureOutputRoot = [System.IO.Path]::GetFullPath($captureOutputRoot)
    $resolvedApprovedTempRoot = [System.IO.Path]::GetFullPath($approvedTempRoot).TrimEnd('\') + '\'
    if (-not $resolvedCaptureOutputRoot.StartsWith($resolvedApprovedTempRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "Refusing to preserve captures outside the approved temp root: $resolvedCaptureOutputRoot"
    }
    New-Item -ItemType Directory -Path $resolvedCaptureOutputRoot | Out-Null
    Copy-Item -LiteralPath $capturePaths[0] -Destination (Join-Path $resolvedCaptureOutputRoot 'recruitment_ui_800x450.png')
    Copy-Item -LiteralPath $capturePaths[1] -Destination (Join-Path $resolvedCaptureOutputRoot 'recruitment_ui_1280x720.png')
    Write-Output "PASS: Recruitment layout captures saved at 800x450 and 1280x720: $resolvedCaptureOutputRoot"

    $upgradeRebootLog = Join-Path $tempRoot 'upgrade_reboot_capture.log'
    $upgradeRebootArguments = "--path `"$isolatedProject`" --script res://tests/capture_upgrade_reboot_layout.gd --rendering-method gl_compatibility --log-file `"$upgradeRebootLog`""
    $upgradeRebootProcess = Start-Process -FilePath $GodotGui -ArgumentList $upgradeRebootArguments -Wait -PassThru -WindowStyle Hidden
    if ($upgradeRebootProcess.ExitCode -ne 0) {
        $debugCapturePaths = @(
            (Join-Path $isolatedProject 'tests\upgrade_locked_800x450.png'),
            (Join-Path $isolatedProject 'tests\upgrade_locked_1280x720.png'),
            (Join-Path $isolatedProject 'tests\reboot_confirmation_800x450.png'),
            (Join-Path $isolatedProject 'tests\reboot_confirmation_1280x720.png')
        )
        foreach ($debugCapturePath in $debugCapturePaths) {
            if (Test-Path -LiteralPath $debugCapturePath -PathType Leaf) {
                Copy-Item -LiteralPath $debugCapturePath -Destination (Join-Path $resolvedCaptureOutputRoot (Split-Path -Leaf $debugCapturePath))
            }
        }
        Write-Output "Partial Upgrade/Reboot captures preserved for diagnosis at: $resolvedCaptureOutputRoot"
        if (Test-Path -LiteralPath $upgradeRebootLog -PathType Leaf) { Get-Content -LiteralPath $upgradeRebootLog | Select-Object -Last 35 | Write-Output }
        throw "Godot Upgrade/Reboot UI capture exited with code $($upgradeRebootProcess.ExitCode); log: $upgradeRebootLog"
    }
    if (-not (Test-Path -LiteralPath $upgradeRebootLog -PathType Leaf)) { throw 'Godot did not create the Upgrade/Reboot capture log.' }
    $upgradeRebootText = Get-Content -Raw -LiteralPath $upgradeRebootLog
    if ($upgradeRebootText -match '(?im)^.*(UI CAPTURE TEST FAILED:|SCRIPT ERROR|Parse Error|Failed to load script).*$') {
        throw "Godot Upgrade/Reboot capture contains a script/test error: $($Matches[0])"
    }
    $upgradeRebootCapturePaths = @(
        (Join-Path $isolatedProject 'tests\upgrade_locked_800x450.png'),
        (Join-Path $isolatedProject 'tests\upgrade_locked_1280x720.png'),
        (Join-Path $isolatedProject 'tests\reboot_confirmation_800x450.png'),
        (Join-Path $isolatedProject 'tests\reboot_confirmation_1280x720.png')
    )
    foreach ($capturePath in $upgradeRebootCapturePaths) {
        if (-not (Test-Path -LiteralPath $capturePath -PathType Leaf)) { throw "Expected Upgrade/Reboot capture was not produced: $capturePath" }
    }
    for ($index = 0; $index -lt $upgradeRebootCapturePaths.Count; $index++) {
        Copy-Item -LiteralPath $upgradeRebootCapturePaths[$index] -Destination (Join-Path $resolvedCaptureOutputRoot (Split-Path -Leaf $upgradeRebootCapturePaths[$index]))
    }
    Write-Output "PASS: Upgrade/Reboot captures saved at 800x450 and 1280x720: $resolvedCaptureOutputRoot"
    if ($VisualAuditOnly) {
        Write-Output 'PASS: visual-only isolated workflow stopped after fresh import and layout captures.'
        return
    }

    $launchLog = Join-Path $tempRoot 'gui_launch.log'
    $launchArguments = "--path `"$isolatedProject`" --quit-after 120 --rendering-method gl_compatibility --log-file `"$launchLog`""
    $launchProcess = Start-Process -FilePath $GodotGui -ArgumentList $launchArguments -Wait -PassThru
    $launchExit = $launchProcess.ExitCode
    if ($launchExit -ne 0) { throw "Godot Windows GUI launch exited with code $launchExit; log: $launchLog" }
    if (-not (Test-Path -LiteralPath $launchLog -PathType Leaf)) { throw 'Godot did not create the GUI launch log.' }
    $launchText = Get-Content -Raw -LiteralPath $launchLog
    if ($launchText -match '(?im)^.*(SCRIPT ERROR|Parse Error|Failed to load script|ERROR:.*autoload).*$') {
        throw "Godot GUI launch log contains a startup error: $($Matches[0])"
    }
    Write-Output 'PASS: Godot 4.7.2 Windows GUI executable launched the copied main scene for 120 frames with Compatibility rendering and no script/autoload startup errors.'

    $suiteOutput = & $GodotConsole --headless --path $isolatedProject --script 'res://tests/test_runner.gd' 2>&1 | Out-String
    $suiteExit = $LASTEXITCODE
    $suiteLines = $suiteOutput.Trim() -split "`r?`n"
    $suiteLines | Select-Object -Last 18 | Write-Output
    if ($suiteExit -ne 0 -or $suiteOutput -match '(?im)TEST FAILED:|SCRIPT ERROR:|Parse Error:') {
        $suiteLines | Where-Object { $_ -match 'TEST FAILED:|SCRIPT ERROR:|Parse Error:|prototype test\(s\) failed' } | Write-Output
        throw "Godot full headless regression suite failed in isolated copy (exit $suiteExit)."
    }
    Write-Output 'PASS: full Godot headless regression suite passed in the disposable project copy.'

    $probePath = 'res://tests/user_data_path_save_probe.gd'
    $writerOutput = & $GodotConsole --headless --path $isolatedProject --script $probePath -- write $runId 2>&1 | Out-String
    $writerExit = $LASTEXITCODE
    Write-Output $writerOutput.Trim()
    if ($writerExit -ne 0) { throw "Isolated save writer process failed with code $writerExit." }
    $expectedUserDataNormalized = $expectedUserData.Replace('\', '/')
    $writerDataMatch = [regex]::Match($writerOutput, '(?m)^ISOLATED_USER_DATA_DIR=(.+)$')
    if (-not $writerDataMatch.Success -or $writerDataMatch.Groups[1].Value.Trim() -ne $expectedUserDataNormalized) {
        throw 'Writer process used an unexpected user:// directory.'
    }

    $readerOutput = & $GodotConsole --headless --path $isolatedProject --script $probePath -- read $runId 2>&1 | Out-String
    $readerExit = $LASTEXITCODE
    Write-Output $readerOutput.Trim()
    if ($readerExit -ne 0) { throw "Isolated save reader process failed with code $readerExit." }
    $readerDataMatch = [regex]::Match($readerOutput, '(?m)^ISOLATED_USER_DATA_DIR=(.+)$')
    if (-not $readerDataMatch.Success -or $readerDataMatch.Groups[1].Value.Trim() -ne $expectedUserDataNormalized) {
        throw 'Reader process used an unexpected user:// directory.'
    }
    if ($readerOutput -notmatch 'fresh Godot process restored permanent progression, x1-upgraded run, squad HP, and settings') {
        throw 'Fresh process did not report the full isolated save round trip.'
    }
    Write-Output 'PASS: separate Godot processes wrote and restored all three save sections inside the unique user-data directory.'

    if (Test-Path -LiteralPath $realSave -PathType Leaf) {
        $realSaveHashAfter = (Get-FileHash -Algorithm SHA256 -LiteralPath $realSave).Hash
        if ($null -eq $realSaveHashBefore) {
            throw 'The isolated verification unexpectedly created the normal Neon Requiem save.'
        }
        if ($realSaveHashBefore -ne $realSaveHashAfter) {
            throw 'The existing Neon Requiem save hash changed during isolated verification.'
        }
    } elseif ($null -ne $realSaveHashBefore) {
        throw 'The existing Neon Requiem save disappeared during isolated verification.'
    }
    Write-Output 'PASS: the normal Neon Requiem user save was not created, removed, or modified.'
}
finally {
    $env:APPDATA = $originalAppData
    $resolvedTempRoot = [System.IO.Path]::GetFullPath($tempRoot)
    $resolvedApprovedRoot = [System.IO.Path]::GetFullPath($approvedTempRoot).TrimEnd('\') + '\'
    if (-not $resolvedTempRoot.StartsWith($resolvedApprovedRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "Refusing to recursively remove a path outside the approved isolated test root: $resolvedTempRoot"
    }
    $resolvedAppData = [System.IO.Path]::GetFullPath($expectedUserData)
    $resolvedAppDataBase = [System.IO.Path]::GetFullPath((Join-Path $isolatedAppDataRoot 'Godot\app_userdata')).TrimEnd('\') + '\'
    if (-not $resolvedAppData.StartsWith($resolvedAppDataBase, [System.StringComparison]::OrdinalIgnoreCase) -or -not $resolvedAppData.EndsWith($projectName, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "Refusing to remove an unverified Godot user-data path: $resolvedAppData"
    }
    if (Test-Path -LiteralPath $resolvedAppData -PathType Container) {
        try { Remove-Item -LiteralPath $resolvedAppData -Recurse -Force -ErrorAction Stop }
        catch { Write-Warning "Could not remove isolated Godot user-data folder; it is safe to remove manually after Godot exits: $resolvedAppData ($($_.Exception.Message))" }
    }
    if (Test-Path -LiteralPath $resolvedTempRoot -PathType Container) {
        try { Remove-Item -LiteralPath $resolvedTempRoot -Recurse -Force -ErrorAction Stop }
        catch { Write-Warning "Could not remove isolated project copy; preserving logs at: $resolvedTempRoot ($($_.Exception.Message))" }
    }
}


