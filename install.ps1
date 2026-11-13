$ErrorActionPreference = "Stop"

$PluginName = "autonomous-team-kit"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$TargetDir = Join-Path $HOME ".gemini\config\plugins\$PluginName"

New-Item -ItemType Directory -Force -Path (Split-Path -Parent $TargetDir) | Out-Null
if (Test-Path $TargetDir) {
    Remove-Item -Recurse -Force $TargetDir
}
Copy-Item -Recurse -Force $ScriptDir $TargetDir

# Auto-register AGENTS.md globally for Gemini CLI (~/.gemini/GEMINI.md) and Claude Code (~/.claude/CLAUDE.md)
New-Item -ItemType Directory -Force -Path (Join-Path $HOME ".gemini") | Out-Null
Copy-Item -Force (Join-Path $ScriptDir "rules\AGENTS.md") (Join-Path $HOME ".gemini\GEMINI.md")
New-Item -ItemType Directory -Force -Path (Join-Path $HOME ".claude") | Out-Null
Copy-Item -Force (Join-Path $ScriptDir "rules\AGENTS.md") (Join-Path $HOME ".claude\CLAUDE.md")

Write-Host "[OK] Installed $PluginName globally to $TargetDir (Zero manual copy needed per project)"
