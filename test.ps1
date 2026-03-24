Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$toolchainRoot = Join-Path $env:LOCALAPPDATA "alire\cache\toolchains"
$gprbuild = Get-ChildItem -Path $toolchainRoot -Recurse -Filter gprbuild.exe -ErrorAction SilentlyContinue |
   Select-Object -First 1 -ExpandProperty FullName
$gnat = Get-ChildItem -Path $toolchainRoot -Recurse -Filter gnat.exe -ErrorAction SilentlyContinue |
   Select-Object -First 1 -ExpandProperty FullName

if (-not $gprbuild -or -not $gnat) {
   throw "Could not find Ada toolchain binaries under $toolchainRoot."
}

$env:PATH = (Split-Path $gprbuild -Parent) + ";" + (Split-Path $gnat -Parent) + ";" + $env:PATH

& $gprbuild -P "safe_flight_control_sim_tests.gpr"
& (Join-Path $PSScriptRoot "test_runner.exe")
