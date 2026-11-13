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

# Install dedicated `agy-team` PowerShell/CMD helper to ~/.local/bin/agy-team.cmd
$BinDir = Join-Path $HOME ".local\bin"
New-Item -ItemType Directory -Force -Path $BinDir | Out-Null
$CliScript = @'
@echo off
set CMD=%1
if "%CMD%"=="" set CMD=status
if "%CMD%"=="init" (
    if not exist ".agents" mkdir ".agents"
    if not exist ".agents\TEAM_STATE.json" (
        echo {"enabled":true,"ticket_id":"FEAT-001","tier":3,"stage":"GATE_0_DISCOVERY","gate_0_user_approved":false,"gate_1_user_approved":false,"pr_user_approved":false,"gate_2_user_approved":false} > ".agents\TEAM_STATE.json"
    )
    if not exist ".agents\LESSONS_LEARNED.md" type nul > ".agents\LESSONS_LEARNED.md"
    if not exist ".agents\METRICS.log" type nul > ".agents\METRICS.log"
    echo [OK] AGY Autonomous Team initialized in %cd% (.agents\TEAM_STATE.json created).
    exit /b 0
)
if "%CMD%"=="remove" goto :remove
if "%CMD%"=="off" goto :remove
if "%CMD%"=="disable" goto :remove
if "%CMD%"=="status" (
    if exist ".agents\TEAM_STATE.json" (
        echo [ACTIVE] AGY Autonomous Team is ENABLED in %cd%:
        type ".agents\TEAM_STATE.json"
    ) else (
        echo [DORMANT] AGY Autonomous Team is NOT initialized in %cd%. Run "agy-team init" or type "/agy-team init" in chat to enable.
    )
    exit /b 0
)
echo Usage: agy-team {init^|remove^|off^|status} [--purge-docs]
exit /b 1
:remove
if exist ".agents" rmdir /s /q ".agents"
if exist ".taste-skill" rmdir /s /q ".taste-skill"
if "%2"=="--purge-docs" (
    if exist "docs" rmdir /s /q "docs"
    if exist "GLOSSARY.md" del /f /q "GLOSSARY.md"
    echo [OK] AGY Autonomous Team + docs/ completely purged from %cd%.
) else (
    echo [OK] AGY Autonomous Team removed from %cd% (.agents\ deleted; docs/ preserved).
)
'@
Set-Content -Path (Join-Path $BinDir "agy-team.cmd") -Value $CliScript -Encoding ASCII

Write-Host "[OK] Installed $PluginName globally to $TargetDir and CLI 'agy-team' to $BinDir\agy-team.cmd"
