# Waveshare RP2040-Zero

- Chip: RP2040 (Dual-core ARM Cortex-M0+, 133 MHz)
- Flash: 2MB
- RAM: 264KB SRAM
- USB-C connector
- Very compact form factor with castellated edges
- Board ID for cmake: `waveshare_rp2040_zero`
- Serial port: `/dev/cu.Maker-3F9E`

## LED

- **No standard GPIO LED** — no `PICO_DEFAULT_LED_PIN`
- **WS2812B NeoPixel on GPIO 16** (`PICO_DEFAULT_WS2812_PIN`)
- Use `pico_status_led` library with `colored_status_led_*` APIs
- Requires PIO (handled automatically by the library)

## Pin Mapping

- GPIO 0: UART0 TX
- GPIO 1: UART0 RX
- GPIO 2-5: General purpose
- GPIO 6: I2C1 SDA
- GPIO 7: I2C1 SCL
- GPIO 10: SPI1 SCK
- GPIO 11: SPI1 TX (MOSI)
- GPIO 12: SPI1 RX (MISO)
- GPIO 13: SPI1 CSn
- GPIO 16: WS2812 LED (NeoPixel)
- GPIO 26-29: ADC0-ADC3

## Bootloader Mode

Hold BOOTSEL button while plugging in USB. Board appears as `/Volumes/RPI-RP2` mass storage device.

## Notes

- Many knockoff/clone boards exist with identical pinout and behavior
- The SDK has a built-in board definition (`waveshare_rp2040_zero`) — no custom header needed
