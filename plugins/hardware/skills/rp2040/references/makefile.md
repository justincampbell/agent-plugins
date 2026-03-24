# Makefile Template

Use this Makefile in new Pico SDK projects. Replace `blink` with the project name.

- Wraps cmake/make with correct toolchain PATH
- Flashes via picotool (preferred) or UF2 copy (fallback)
- Default target (`make` with no args) is `flash`
- Override port: `make monitor PORT=/dev/cu.something`

```makefile
PICO_SDK_PATH ?= $(HOME)/Code/raspberrypi/pico-sdk
ARM_TOOLCHAIN ?= $(HOME)/Code/raspberrypi/arm-toolchain
PORT ?= /dev/cu.Maker-3F9E
SRCS = $(wildcard main/*.c)

.PHONY: flash
flash: build/main/blink.uf2 ## Build and flash firmware
	@if [ -d /Volumes/RPI-RP2 ]; then \
		cp build/main/blink.uf2 /Volumes/RPI-RP2/ && echo "Flashed via UF2 copy"; \
	else \
		picotool load build/main/blink.uf2 -f && picotool reboot && echo "Flashed via picotool"; \
	fi

build/main/blink.uf2: $(SRCS) main/CMakeLists.txt CMakeLists.txt
	@mkdir -p build
	cd build && PATH=$(ARM_TOOLCHAIN)/bin:$$PATH \
		PICO_SDK_PATH=$(PICO_SDK_PATH) \
		PICO_TOOLCHAIN_PATH=$(ARM_TOOLCHAIN) \
		cmake .. -DPICO_BOARD=seeed_xiao_rp2040 \
			-DCMAKE_C_COMPILER=$(ARM_TOOLCHAIN)/bin/arm-none-eabi-gcc \
			-DCMAKE_CXX_COMPILER=$(ARM_TOOLCHAIN)/bin/arm-none-eabi-g++ \
			2>/dev/null; \
	cd build && PATH=$(ARM_TOOLCHAIN)/bin:$$PATH make -j$$(sysctl -n hw.ncpu)

.PHONY: build
build: build/main/blink.uf2 ## Build firmware

.PHONY: monitor
monitor: ## Serial monitor (Ctrl+A then K to exit)
	screen $(PORT) 115200

.PHONY: clean
clean: ## Remove build artifacts
	rm -rf build

.PHONY: help
help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-16s %s\n", $$1, $$2}'
```
