param(
    [string]$GodotPath = $(if ($env:GODOT_BIN) { $env:GODOT_BIN } else { "godot" }),
    [switch]$Editor
)
$ErrorActionPreference = "Stop"
$projectPath = Split-Path -Parent $PSScriptRoot
if (-not (Get-Command $GodotPath -ErrorAction SilentlyContinue)) {
    throw "Godot was not found. Pass -GodotPath with the full path to your Godot 4.7.2 executable."
}
$godotArguments = @("--path", $projectPath)
if ($Editor) { $godotArguments += "--editor" }
& $GodotPath @godotArguments
exit $LASTEXITCODE
