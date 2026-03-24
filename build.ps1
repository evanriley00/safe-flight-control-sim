Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$toolchainRoot = Join-Path $env:LOCALAPPDATA "alire\cache\toolchains"
$gprbuild = Get-ChildItem -Path $toolchainRoot -Recurse -Filter gprbuild.exe -ErrorAction SilentlyContinue |
   Select-Object -First 1 -ExpandProperty FullName
$gnat = Get-ChildItem -Path $toolchainRoot -Recurse -Filter gnat.exe -ErrorAction SilentlyContinue |
   Select-Object -First 1 -ExpandProperty FullName

if (-not $gprbuild) {
   throw "Could not find gprbuild.exe under $toolchainRoot. Reinstall the Ada toolchain with Alire."
}

if (-not $gnat) {
   throw "Could not find gnat.exe under $toolchainRoot. Reinstall the Ada toolchain with Alire."
}

$gprbuildBin = Split-Path $gprbuild -Parent
$gnatBin = Split-Path $gnat -Parent
$env:PATH = $gprbuildBin + ";" + $gnatBin + ";" + $env:PATH

& $gprbuild -P "safe_flight_control_sim.gpr"
