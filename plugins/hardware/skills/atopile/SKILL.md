---
name: atopile
description: Design electronic schematics and PCBs using atopile (hardware-as-code). Use when working with .ato files, circuit design, or PCB projects.
---

# Atopile — Hardware as Code

You help the user design electronic circuits using atopile, a code-based EDA tool.

## Setup

Installed via Homebrew: `brew install atopile/tap/atopile`

Current version: 0.14.1005

KiCad 9.0 is needed for PCB layout (atopile auto-installs its KiCad plugin).

## The .ato Language

Python-inspired DSL for circuit design:

```ato
import ElectricPower, Resistor, I2C
from "atopile/espressif-esp32-c3/espressif-esp32-c3-mini.ato" import ESP32_C3_MINI_1

module MyBoard:
    micro = new ESP32_C3_MINI_1
    power = new ElectricPower
    power ~ micro.power
```

### Key syntax

- `~` connects signals/interfaces of the same type
- `~>` bridge connection (passes through a module, e.g. power through regulator)
- `->` specializes/replaces a component type
- `new` instantiates a module/component
- Values with units: `100ohm`, `10kohm`, `4.7uF`, `3.3V`, `100uA`
- Tolerances: `100ohm +/- 10%` or `3V to 3.6V`
- Assertions: `assert expr within range`

## Project Structure

```
hardware/
├── ato.yaml           # Project manifest
├── .ato/              # Cached dependencies (auto-managed)
├── build/             # Build outputs (KiCad files, BOM)
├── elec/
│   ├── src/           # .ato source files
│   └── layout/        # KiCad layout files
└── .gitignore         # .ato/, build/
```

## ato.yaml Format

```yaml
requires-atopile: ^0.14.0

paths:
  src: ./elec/src
  layout: ./elec/layout

builds:
  default:
    entry: project.ato:MainModule

dependencies:
- type: registry
  identifier: atopile/espressif-esp32-c3
  release: 0.3.0
```

## Common Commands

- **Build**: `ato build` — compiles .ato → KiCad PCB + BOM
- **Add package**: `ato add atopile/espressif-esp32-c3`
- **Sync deps**: `ato sync` — install all dependencies from ato.yaml
- **Create project**: `ato create` (interactive, requires terminal)

## Package Registry

Browse at [packages.atopile.io](https://packages.atopile.io)

### Generic Components (import directly, no path needed in v0.14.x)

- `ElectricPower`, `FloatPower` — power interfaces
- `Resistor` — auto-picks from JLCPCB library based on `.value` and `.package`
- `Capacitor`, `CapacitorElectrolytic`
- `Inductor`
- `LED`, `LEDIndicator`, `LEDIndicatorRed/Green/Blue`
- `Diode`, `ZenerDiode`, `SchottkyDiode`
- `NFET`, `PFET`, `NPN`, `PNP`
- `Connector2Pin` through `Connector10Pin`
- `ButtonPullup`, `ButtonPulldown`
- `Crystal`, `Oscillator`
- `LowPassFilter`
- `VDiv` — voltage divider
- `TestPoint`

### Interfaces (import directly)

`GPIO`, `I2C`, `SPI`, `UART`, `USB2`, `CAN`, `Analog`, `Power`, `SWD`, `JTAG`, `QSPI`

### Notable Packages

- `atopile/espressif-esp32-c3` — ESP32-C3-MINI module
- `atopile/esp32-s3` — ESP32-S3
- `atopile/rp2040` — RP2040
- `atopile/usb-connectors` — USB-C connectors

## Custom Components & Footprints

Components need `trait is_atomic_part` with bundled `.kicad_mod` footprint files to appear in the PCB.
Registry packages include these automatically. For custom through-hole parts (headers, pots), you can:

1. Define the component with `signal` and `pin` mappings
2. Assign a `footprint` attribute (may not be picked up without `is_atomic_part`)
3. Or assign footprints manually in KiCad after build

Example from registry packages:
```ato
#pragma experiment("TRAITS")
import is_atomic_part

component MyPart:
    trait is_atomic_part<manufacturer="Foo", partnumber="BAR", footprint="my_footprint.kicad_mod">
    signal pin1 ~ pin 1
```

Without `is_atomic_part`, you get a warning: "No pickers and no footprint... Will not appear in netlist or pcb."
The build still succeeds — the netlist is captured, just not placed in the PCB.

## Gotchas

- `ato create` is interactive — cannot run from non-terminal (e.g., Claude Code). Set up projects manually.
- No potentiometer component exists in the registry — create custom components for pots.
- Multiple imports on one line (`import A, B`) is deprecated — use separate `import` statements.
- The `paths.src` in ato.yaml does NOT affect the `entry` path — entry is always relative to project root.
- `Connector3Pin` etc. are NOT in the stdlib despite being listed in some docs. Define your own header components.

## Workflow

1. Write/edit `.ato` source files
2. `ato build` to compile
3. Open generated KiCad PCB for physical layout (manual step)
4. Re-run `ato build` to sync changes without losing routing
5. Export Gerbers from KiCad for manufacturing

## Maintaining This Skill

When you learn something new about atopile (new packages, syntax changes, gotchas, etc.), proactively update this skill file or add references.
