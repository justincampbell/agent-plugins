---
name: rp2040
description: Develop, build, flash, and monitor RP2040 projects using the Pico SDK. Use when working with RP2040 hardware, building firmware, or managing Pico SDK projects.
allowed-tools: Bash, Read, Write, Edit, Glob, Grep
---

# RP2040 Development with the Pico SDK

You help the user develop RP2040 firmware using the Raspberry Pi Pico SDK.

## Setup

- **Pico SDK**: `~/Code/raspberrypi/pico-sdk/` (v2.x)
- **ARM Toolchain**: `~/Code/raspberrypi/arm-toolchain/` (ARM GNU Toolchain 14.2)
- **picotool**: installed via Homebrew at `/opt/homebrew/bin/picotool`

The Homebrew `arm-none-eabi-gcc` is missing newlib/nosys.specs. Always use the full ARM toolchain at `~/Code/raspberrypi/arm-toolchain/`.

## Common Commands

All commands must use the correct toolchain PATH. Use the project Makefile when available:

- **Build**: `make build`
- **Flash**: `make flash`
- **Monitor serial**: `make monitor` (Ctrl+A then K to exit screen)
- **Clean**: `make clean`

Or directly:

```bash
# Build
cd build && PATH=$HOME/Code/raspberrypi/arm-toolchain/bin:$PATH make -j$(sysctl -n hw.ncpu)

# Flash (bootloader mode - board shows as /Volumes/RPI-RP2)
cp build/main/<name>.uf2 /Volumes/RPI-RP2/

# Flash (running mode - via picotool)
picotool load build/main/<name>.uf2 -f && picotool reboot

# Enter bootloader mode from running firmware
picotool reboot -u
```

## Creating a New Project

A minimal project needs:
- `CMakeLists.txt` (top-level, includes pico SDK, sets project name)
- `Makefile` (convenience wrapper — see `references/makefile.md`)
- `main/CMakeLists.txt` (registers source files, links libraries)
- `main/<name>.c` (entry point: `int main()`)
- `.gitignore` (build/)

## Project Structure

```
project/
├── .gitignore              # build/
├── CMakeLists.txt          # Top-level cmake, includes Pico SDK
├── Makefile                # Convenience wrapper (see references/makefile.md)
└── main/
    ├── CMakeLists.txt      # add_executable + target_link_libraries
    └── blink.c             # Entry point: int main()
```

## CMake Configuration

The cmake configure step requires explicit compiler paths:

```bash
PATH=$HOME/Code/raspberrypi/arm-toolchain/bin:$PATH \
PICO_SDK_PATH=$HOME/Code/raspberrypi/pico-sdk \
PICO_TOOLCHAIN_PATH=$HOME/Code/raspberrypi/arm-toolchain \
cmake .. -DPICO_BOARD=<board> \
  -DCMAKE_C_COMPILER=$HOME/Code/raspberrypi/arm-toolchain/bin/arm-none-eabi-gcc \
  -DCMAKE_CXX_COMPILER=$HOME/Code/raspberrypi/arm-toolchain/bin/arm-none-eabi-g++
```

## Workflow

1. `cmake` configure — only needed once per project (or after CMakeLists changes)
2. `make build` — compiles firmware, produces .uf2 file
3. `make flash` — writes to device (auto-detects bootloader vs picotool)
4. `make monitor` — view serial output (printf goes here)

Incremental builds are fast. Full clean build takes ~15s.

## USB Port

The device serial port is `/dev/cu.Maker-3F9E`. Check with `ls /dev/cu.*` if not found.

When in bootloader mode (hold BOOTSEL + plug USB, or `picotool reboot -u`), the board appears as `/Volumes/RPI-RP2`.

## Flashing Strategies

1. **UF2 copy** (board in bootloader mode): `cp firmware.uf2 /Volumes/RPI-RP2/` — board auto-reboots
2. **picotool** (board running or bootloader): `picotool load firmware.uf2 -f && picotool reboot` — more reliable on macOS

Prefer picotool — the UF2 volume copy can hang on macOS.

**Important**: `picotool reboot -u` only works when the board is in BOOTSEL mode already. If the board is running firmware without USB support exposed to picotool, you must physically hold BOOTSEL and re-plug USB.

## Status LEDs

The Pico SDK provides `pico_status_led` (link with `pico_status_led` in CMake) which abstracts LED differences across boards:

- **Simple LED boards** (e.g. Pico): `status_led_set_state(true/false)` — uses `PICO_DEFAULT_LED_PIN`
- **WS2812 boards** (e.g. RP2040-Zero): `colored_status_led_set_on_with_color(color)` / `colored_status_led_set_state(false)` — uses `PICO_DEFAULT_WS2812_PIN` via PIO
- Must call `status_led_init()` first
- Color macro: `PICO_COLORED_STATUS_LED_COLOR_FROM_RGB(r, g, b)`

This avoids hardcoding GPIO pins and works across all board definitions.

## .gitignore

```
build/
```

## Maintaining This Skill

When you learn something new that would be useful for future RP2040 projects (new board info, patterns, gotchas, etc.), proactively suggest updating this skill and its references. Keep board-specific details in `references/`, and general Pico SDK knowledge in this file.
