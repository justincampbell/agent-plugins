# Seeed Studio XIAO ESP32C3

- Chip: ESP32-C3 (RISC-V)
- No user-controllable built-in LED (only a charge indicator LED)
- USB-C connector with built-in USB CDC
- Pin labels use D prefix: D0-D10 map to GPIO numbers
  - D8 = GPIO 8
  - D9 = GPIO 9
  - D10 = GPIO 10
- Very small form factor
- External LED + resistor (220-330 ohm) needed for blink testing
  - Wire: GPIO pin → resistor → LED anode (long leg) → LED cathode (short leg) → GND
