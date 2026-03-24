# Safe Flight Control Simulation

`Safe Flight Control Simulation` is a small Ada project designed to feel like the kind of safety-focused software used in mission-critical environments.

It simulates multiple aircraft moving through shared airspace, detects unsafe separation conditions, and applies simple controller advisories to resolve conflicts.

The project is intentionally scoped like an engineering sample rather than a toy script: bounded state, explicit domain types, deterministic execution, scenario-file inputs, and repeatable tests.

## Why This Project Exists

This project is meant to demonstrate:

- Safety-first design
- Strong typing
- Modular Ada package architecture
- Deterministic simulation behavior
- Conflict detection and resolution logic
- Automated regression tests
- Clear, intentional engineering over flashy complexity

Instead of being "just some Ada code," it is structured to resemble the shape of a real reliability-oriented control system.

## Architecture

```text
src/
  flight_types.ads / .adb
    Core domain types like altitude, speed, heading, and advisories

  aircraft.ads / .adb
    Aircraft state and movement logic

  airspace.ads / .adb
    Tracks all aircraft in the simulation

  safety.ads / .adb
    Detects unsafe separation and recommends actions

  controller.ads / .adb
    Applies advisories to resolve conflicts

  logger.ads / .adb
    Simple deterministic-friendly operational logging

  scenarios.ads / .adb
    Loads deterministic scenario files into the simulation airspace

  main.adb
    Runs the simulation loop
```

## What It Demonstrates

### 1. Safety-first design

- Strong domain-specific types for altitude, speed, heading, and nautical miles
- Explicit conflict thresholds
- No loose dynamic behavior

### 2. Modular system structure

Each responsibility is separated into its own package, which is much closer to how real long-lived Ada systems are organized.

### 3. Real-time simulation behavior

Aircraft advance on each tick based on speed and heading.

### 4. Decision logic

The system checks aircraft separation and issues simple advisories such as:

- `Climb_1000`
- `Descend_1000`
- `Turn_Left_15`
- `Turn_Right_15`

### 5. Repeatable verification

The repository includes an automated Ada test runner that validates:

- aircraft movement math
- advisory-level conflict detection
- emergency-level conflict detection
- controller conflict resolution behavior

## Simulation Rules

The current sample scenario uses a simple safety model:

- Emergency:
  - Horizontal separation `< 3 nm`
  - Vertical separation `< 500 ft`

- Advisory required:
  - Horizontal separation `< 5 nm`
  - Vertical separation `< 1000 ft`

When a conflict is detected, the controller applies altitude separation advisories to the involved aircraft.

## Deterministic Design

This project intentionally uses:

- File-based deterministic scenarios
- No randomness
- Deterministic simulation-minute log markers (`[T+0m]`, `[T+1m]`, ...)
- Same input -> same output

That makes it easier to reason about, test, and discuss in the context of defense or safety-critical systems.

## Why This Matters For Mission-Critical Software

This project is small, but it tries to model a few habits that matter in long-lived reliability-oriented codebases:

- domain constraints are encoded in types instead of left implicit
- data flow is explicit and package boundaries are narrow
- behavior is deterministic so results can be reproduced and reviewed
- system inputs are externalized into scenario files instead of hidden in code
- core behavior is covered by automated regression tests

That combination is closer to the mindset of safety-focused systems work than simply "writing something in Ada."

## Toolchain Setup

You can build this with either of these:

### Option 1: GNAT

Install GNAT / GCC Ada support, then run:

```bash
gprbuild -P safe_flight_control_sim.gpr
```

Or:

```bash
gnatmake -P safe_flight_control_sim.gpr
```

### Option 2: Alire

Install Alire, then provision the native toolchain and build tools:

```powershell
alr toolchain --select gnat_native gprbuild
```

### Windows helper scripts

This repository also includes local PowerShell helpers that auto-discover the Alire-installed toolchain:

```powershell
.\build.ps1
.\run.ps1
.\run.ps1 12
.\test.ps1
```

## Running

After building:

```bash
./main
```

Or pass a custom number of simulation steps:

```bash
./main 12
```

On Windows, the equivalent is:

```powershell
.\run.ps1
.\run.ps1 12
.\run.ps1 8 scenarios\crossing_sector.scn
```

If you want to run an alternate scenario directly with the executable:

```bash
./main 8 scenarios/crossing_sector.scn
```

The command line accepts either:

```text
main.exe [steps] [scenario_path]
main.exe [scenario_path]
```

## Testing

Run the automated regression suite with:

```powershell
.\test.ps1
```

The test runner verifies movement, conflict classification, and controller resolution logic.

## Scenario Files

Scenario files live in `scenarios/` and use one aircraft record per line:

```text
id,call_sign,x_nm,y_nm,altitude_ft,speed_kt,heading_deg
```

Blank lines and `#` comments are ignored.

Example:

```text
1,LNX101,10.0,10.0,31000,460,45
2,VTR220,23.0,23.0,31000,445,225
3,RDN330,60.0,10.0,28000,430,90
```

Included sample scenarios:

- `scenarios/default.scn` reproduces the baseline conflict-and-resolution case
- `scenarios/crossing_sector.scn` provides a second deterministic traffic pattern

## Example Behavior

The seeded scenario includes multiple aircraft on intersecting paths. On each step the system:

1. Prints current aircraft state
2. Checks for separation conflicts
3. Logs any conflict detected
4. Applies controller advisories
5. Advances the simulation by one minute

Example deterministic log output:

```text
=== Simulation Step2 ===
[T+1m] LNX101 | Alt:31000 ft | Spd:460 kt | Hdg:45 | Pos:1.54212E+01,1.54212E+01
[T+1m] VTR220 | Alt:31000 ft | Spd:445 kt | Hdg:225 | Pos:1.77556E+01,1.77556E+01
[T+1m] Conflict detected: Loss of separation between LNX101 and VTR220 | horizontal=3.30144E+00 nm | vertical=0 ft
[T+1m] Resolution issued: LNX101 -> DESCEND_1000, VTR220 -> CLIMB_1000
```

## Why Ada Fits This Project

Ada is a strong fit because it encourages:

- explicit modeling,
- safer constraints,
- clear interfaces,
- maintainable package boundaries,
- and engineering discipline that matters in long-lived critical systems.

## Future Upgrades

If you want to push this further into portfolio-level territory, the best next steps would be:

- Add bounded airspace sectors and handoff logic
- Add multiple advisory strategies
- Add richer controller rules for reroutes and heading changes
- Add a terminal dashboard or replay output

## Build Intent

This is intentionally small, clean, and understandable.

The goal is not to simulate the entire FAA. The goal is to show:

"I can think in terms of safe system design, structure code like an engineer, and learn the tools used in critical environments."
