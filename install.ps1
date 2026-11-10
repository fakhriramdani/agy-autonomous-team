$ErrorActionPreference = "Stop"

$PluginName = "autonomous-team-kit"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$TargetDir = Join-Path $HOME ".gemini\config\plugins\$PluginName"

New-Item -ItemType Directory -Force -Path (Split-Path -Parent $TargetDir) | Out-Null
if (Test-Path $TargetDir) {
    Remove-Item -Recurse -Force $TargetDir
}
Copy-Item -Recurse -Force $ScriptDir $TargetDir

Write-Host "[OK] Installed $PluginName to $TargetDir"
