# agent-plugins

Skills for Claude Code, organized as separate plugins.

## Install

```
/plugin marketplace add justincampbell/agent-plugins
```

### Developer Workflow

```
/plugin install justincampbell@justincampbell-agent-plugins
```

- `/justincampbell:local-review` — Launch a local diff review UI ([difit](https://github.com/yoshiko-pg/difit)) and address review comments
- `/justincampbell:open-pull-request` — Open a pull request with proper git workflow conventions
- `/justincampbell:issues` — Record ideas/bugs as GitHub issues and start work on them
- `/justincampbell:tmux-fork` — Fork the current conversation into a new tmux pane or window

### Hardware / Embedded

```
/plugin install hardware@justincampbell-agent-plugins
```

- `/hardware:esp32` — Develop, build, flash, and monitor ESP32 projects using ESP-IDF
- `/hardware:rp2040` — Develop, build, flash, and monitor RP2040 projects using the Pico SDK
- `/hardware:atopile` — Design electronic schematics and PCBs using atopile (hardware-as-code)
