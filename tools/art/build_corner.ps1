param([string]$Blender = "")
$ErrorActionPreference = "Stop"

if (-not $Blender) {
    $command = Get-Command blender -ErrorAction SilentlyContinue
    if ($command) { $Blender = $command.Source }
}
if (-not $Blender) {
    $candidates = Get-ChildItem "$env:ProgramFiles\Blender Foundation\Blender*\blender.exe" -ErrorAction SilentlyContinue |
        Sort-Object FullName -Descending
    if ($candidates) { $Blender = $candidates[0].FullName }
}
if (-not $Blender -or -not (Test-Path -LiteralPath $Blender)) {
    throw 'Blender was not found. Pass its executable: .\tools\art\build_corner.ps1 -Blender "C:\path\to\blender.exe"'
}

$source = Join-Path $PSScriptRoot "build_corner.py"
& $Blender --background --factory-startup --python-exit-code 1 --python $source
if ($LASTEXITCODE -ne 0) { throw "Blender export failed (exit $LASTEXITCODE)." }
Write-Host "Corner models rebuilt. Return to Godot and let the assets reimport."
