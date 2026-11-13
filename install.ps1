$ErrorActionPreference = "Stop"

$PluginName = "autonomous-team-kit"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$TargetDir = Join-Path $HOME ".gemini\config\plugins\$PluginName"

New-Item -ItemType Directory -Force -Path (Split-Path -Parent $TargetDir) | Out-Null
if (Test-Path $TargetDir) {
    Remove-Item -Recurse -Force $TargetDir
}
Copy-Item -Recurse -Force $ScriptDir $TargetDir

# Safe Non-Destructive Global Registration for Gemini CLI (~/.gemini/GEMINI.md) & Claude Code (~/.claude/CLAUDE.md)
# Never overwrites existing user content outside <!-- BEGIN AGY-AUTONOMOUS-TEAM --> ... <!-- END AGY-AUTONOMOUS-TEAM -->
function Update-GlobalMd {
    param([string]$FilePath, [string]$SourceAgentsMd)
    $Dir = Split-Path -Parent $FilePath
    New-Item -ItemType Directory -Force -Path $Dir | Out-Null
    $AgentsContent = Get-Content -Raw $SourceAgentsMd
    $Block = "<!-- BEGIN AGY-AUTONOMOUS-TEAM -->`r`n$AgentsContent`r`n<!-- END AGY-AUTONOMOUS-TEAM -->"
    if (Test-Path $FilePath) {
        $Existing = Get-Content -Raw $FilePath
        if ($null -ne $Existing -and $Existing.StartsWith("# Autonomous Team Kit")) {
            Set-Content -Path $FilePath -Value $Block -Encoding UTF8
        } elseif ($null -ne $Existing -and $Existing -match "(?s)<!-- BEGIN AGY-AUTONOMOUS-TEAM -->.*?<!-- END AGY-AUTONOMOUS-TEAM -->") {
            $Updated = [regex]::Replace($Existing, "(?s)<!-- BEGIN AGY-AUTONOMOUS-TEAM -->.*?<!-- END AGY-AUTONOMOUS-TEAM -->", $Block)
            Set-Content -Path $FilePath -Value $Updated -Encoding UTF8
        } else {
            Add-Content -Path $FilePath -Value "`r`n$Block" -Encoding UTF8
        }
    } else {
        Set-Content -Path $FilePath -Value $Block -Encoding UTF8
    }
}

$SourceRule = Join-Path $ScriptDir "rules\AGENTS.md"
Update-GlobalMd -FilePath (Join-Path $HOME ".gemini\GEMINI.md") -SourceAgentsMd $SourceRule
Update-GlobalMd -FilePath (Join-Path $HOME ".claude\CLAUDE.md") -SourceAgentsMd $SourceRule

Write-Host "[OK] Installed $PluginName globally to $TargetDir (Non-destructive & Smart Activation Guard enabled)"
