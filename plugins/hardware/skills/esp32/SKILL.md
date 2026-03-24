---
name: esp32
description: Develop, build, flash, and monitor ESP32 projects using ESP-IDF. Use when working with ESP32 hardware, building firmware, or managing ESP-IDF projects.
allowed-tools: Bash, Read, Write, Edit, Glob, Grep
---

# ESP32 Development with ESP-IDF

You help the user develop ESP32 firmware using the ESP-IDF framework.

## Setup

ESP-IDF is installed at `~/Code/espressif/esp-idf/` (v6.1).

Before running any `idf.py` commands, source the environment. All `idf.py` commands in bash must be run after sourcing:

```bash
bash -c 'source ~/Code/espressif/esp-idf/export.sh >/dev/null 2>&1 && idf.py <command>'
```

## Common Commands

- **Set target**: `idf.py set-target esp32c3`
- **Build**: `idf.py build`
- **Flash**: `idf.py -p /dev/cu.usbmodem1101 flash`
- **Monitor serial**: `idf.py -p /dev/cu.usbmodem1101 monitor` (exit with Ctrl+])
- **Flash + monitor**: `idf.py -p /dev/cu.usbmodem1101 flash monitor`
- **Clean**: `idf.py fullclean`

## Creating a New Project

Copy from examples at `~/Code/espressif/esp-idf/examples/` or create manually.

A minimal project needs:
- `CMakeLists.txt` (top-level, sets project name)
- `Makefile` (from template in `references/makefile.md` — update project name in bin target)
- `main/CMakeLists.txt` (registers source files)
- `main/<name>.c` (entry point: `void app_main(void)`)
- `.gitignore` (build/, sdkconfig.old)

## Project Structure

```
project/
├── .gitignore              # build/, sdkconfig.old
├── CMakeLists.txt          # Top-level cmake, sets project name
├── Makefile                # Convenience wrapper (see references/makefile.md)
├── sdkconfig               # Generated config (commit this)
└── main/
    ├── CMakeLists.txt      # idf_component_register(SRCS ...)
    └── app_main.c          # Entry point: void app_main(void)
```

## Workflow

1. `idf.py set-target <chip>` — only needed once per project (creates sdkconfig + build dir)
2. `idf.py build` — compiles firmware
3. `idf.py -p <port> flash` — writes to device
4. `idf.py -p <port> monitor` — view serial output (printf goes here), Ctrl+] to exit

`set-target` is slow (initializes submodules on first run). Clean build + flash takes ~42s. Incremental builds are fast (~5s) — idf.py and make both track dependencies well.

## USB Port

The device typically appears at `/dev/cu.usbmodem1101`. Check with `ls /dev/cu.usb*` if not found.

## .gitignore

```
build/
sdkconfig.old
```

## Maintaining This Skill

When you learn something new that would be useful for future ESP32 projects (new board info, patterns, gotchas, etc.), proactively suggest updating this skill and its references. Keep chip/board-specific details in `references/`, and general ESP-IDF knowledge in this file.
