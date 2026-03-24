param(
   [int]$Steps = 8,
   [string]$ScenarioPath = "scenarios/default.scn"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$exePath = Join-Path $PSScriptRoot "main.exe"

if (-not (Test-Path $exePath)) {
   & (Join-Path $PSScriptRoot "build.ps1")
}

& $exePath $Steps $ScenarioPath
