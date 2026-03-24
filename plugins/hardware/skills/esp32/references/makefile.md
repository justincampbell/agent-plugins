# Makefile Template

Use this Makefile in new ESP-IDF projects. Replace `blink` with the project name.

- Wraps `idf.py` so you don't need to source `export.sh` manually
- `build/PROJECT.bin` is a real target with source dependencies for incremental builds
- Default target (`make` with no args) is `flash-monitor`
- Override port: `make flash PORT=/dev/cu.usbmodem1234`

```makefile
IDF = source ~/Code/espressif/esp-idf/export.sh >/dev/null 2>&1

PORT ?= /dev/cu.usbmodem1101
SRCS = $(wildcard main/*.c)

.PHONY: flash-monitor
flash-monitor: build/blink.bin ## Build, flash, and monitor (default)
	bash -c '$(IDF) && idf.py -p $(PORT) flash monitor'

build/blink.bin: $(SRCS) main/CMakeLists.txt CMakeLists.txt sdkconfig
	bash -c '$(IDF) && idf.py build'

.PHONY: build
build: build/blink.bin ## Build firmware

.PHONY: flash
flash: build/blink.bin ## Flash firmware to device
	bash -c '$(IDF) && idf.py -p $(PORT) flash'

.PHONY: monitor
monitor: ## Serial monitor (Ctrl+] to exit)
	bash -c '$(IDF) && idf.py -p $(PORT) monitor'

.PHONY: clean
clean: ## Remove build artifacts
	bash -c '$(IDF) && idf.py fullclean'

.PHONY: help
help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-16s %s\n", $$1, $$2}'
```
