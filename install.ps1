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
set ARG2=%2
if "%CMD%"=="" set CMD=status
if "%CMD%"=="init" (
    if "%ARG2%"=="--oss" goto :init_oss
    if not exist ".agents" mkdir ".agents"
    echo {"enabled":true,"repo_mode":"standard","ticket_id":"FEAT-001","tier":3,"stage":"GATE_0_DISCOVERY","gate_0_user_approved":false,"gate_1_user_approved":false,"pr_user_approved":false,"gate_2_user_approved":false} > ".agents\TEAM_STATE.json"
    if not exist ".agents\LESSONS_LEARNED.md" type nul > ".agents\LESSONS_LEARNED.md"
    if not exist ".agents\METRICS.log" type nul > ".agents\METRICS.log"
    echo [OK] AGY Autonomous Team initialized in %cd% [repo_mode=standard].
    exit /b 0
)
if "%CMD%"=="init-oss" goto :init_oss
if "%CMD%"=="remove" goto :remove
if "%CMD%"=="off" goto :remove
if "%CMD%"=="disable" goto :remove
if "%CMD%"=="status" (
    if exist ".agents\TEAM_STATE.json" (
        echo [ACTIVE] AGY Autonomous Team is ENABLED in %cd%:
        type ".agents\TEAM_STATE.json"
    ) else (
        echo [DORMANT] AGY Autonomous Team is NOT initialized in %cd%. Run "agy-team init" (Standard) or "agy-team init-oss" (Open-Source Stealth).
    )
    exit /b 0
)
echo Usage: agy-team {init^|init-oss^|remove^|off^|status} [--oss^|--purge-docs]
exit /b 1
:init_oss
if not exist ".git" git init -q
if not exist "LICENSE" (
    if exist "%USERPROFILE%\.gemini\config\plugins\autonomous-team-kit\LICENSE" copy /y "%USERPROFILE%\.gemini\config\plugins\autonomous-team-kit\LICENSE" "LICENSE" > nul
)
if not exist ".git\info" mkdir ".git\info"
powershell -NoProfile -Command "$p='.git\info\exclude'; $b=\"# BEGIN AGY-TEAM-OSS-EXCLUDE`r`n/.agents/`r`n/.taste-skill/`r`n/GLOSSARY.md`r`n/docs/00-product/`r`n/docs/01-design/`r`n/docs/02-architecture/`r`n/docs/03-features/`r`n/docs/04-patches/`r`n/docs/scope.md`r`n/docs/prd.md`r`n/docs/design-spec.md`r`n/docs/preview.html`r`n/docs/figma-console.js`r`n/docs/figma-plugin/`r`n/docs/architecture.md`r`n/docs/tasks.md`r`n/docs/adr/`r`n/docs/code-review.md`r`n/docs/test-plan.md`r`n/docs/qa-report.md`r`n# END AGY-TEAM-OSS-EXCLUDE\"; if(Test-Path $p){$c=Get-Content -Raw $p; $c=[regex]::Replace([string]$c,'(?s)# BEGIN AGY-TEAM-OSS-EXCLUDE.*?# END AGY-TEAM-OSS-EXCLUDE','').TrimEnd(); Set-Content -Path $p -Value ($c+\"`r`n\"+$b)}else{Set-Content -Path $p -Value $b}"
if not exist ".agents" mkdir ".agents"
echo {"enabled":true,"repo_mode":"oss-stealth","ticket_id":"FEAT-001","tier":3,"stage":"GATE_0_DISCOVERY","gate_0_user_approved":false,"gate_1_user_approved":false,"pr_user_approved":false,"gate_2_user_approved":false} > ".agents\TEAM_STATE.json"
if not exist ".agents\LESSONS_LEARNED.md" type nul > ".agents\LESSONS_LEARNED.md"
if not exist ".agents\METRICS.log" type nul > ".agents\METRICS.log"
echo [OK] AGY Autonomous Team initialized in %cd% [repo_mode=oss-stealth: docs excluded via .git/info/exclude, code-only commits].
exit /b 0
:remove
if exist ".agents" rmdir /s /q ".agents"
if exist ".taste-skill" rmdir /s /q ".taste-skill"
if exist ".git\info\exclude" powershell -NoProfile -Command "$p='.git\info\exclude'; $c=Get-Content -Raw $p; if($null -ne $c){$c=[regex]::Replace($c,'(?s)# BEGIN AGY-TEAM-OSS-EXCLUDE.*?# END AGY-TEAM-OSS-EXCLUDE\r?\n?',''); Set-Content -Path $p -Value $c}"
if "%ARG2%"=="--purge-docs" (
    if exist "docs" rmdir /s /q "docs"
    if exist "GLOSSARY.md" del /f /q "GLOSSARY.md"
    echo [OK] AGY Autonomous Team + docs/ completely purged from %cd%.
) else (
    echo [OK] AGY Autonomous Team removed from %cd% (.agents\ & .git/info/exclude cleaned; docs/ preserved).
)
'@
Set-Content -Path (Join-Path $BinDir "agy-team.cmd") -Value $CliScript -Encoding ASCII

Write-Host "[OK] Installed $PluginName globally to $TargetDir and CLI 'agy-team' to $BinDir\agy-team.cmd"
