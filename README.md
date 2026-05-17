<p align="center">
  <a href="https://mithraeums.github.io">
    <img src="https://mithraeums.github.io/assets/banner-claw-dark.svg" alt="hakoCLAW — a standalone agent for the inner chamber" width="100%"/>
  </a>
</p>

<p align="center">
  <em>A standalone terminal AI agent in a single C file. Quiet, model-agnostic, skill-driven.</em>
</p>

<p align="center">
  <a href="https://github.com/mithraeums/hakoCLAW/releases"><img src="https://img.shields.io/badge/version-v0.1.4-b89656?style=flat-square&labelColor=14130f" alt="v0.1.4"/></a>
  <img src="https://img.shields.io/badge/license-GPL--3.0-c8c2b2?style=flat-square&labelColor=14130f" alt="GPL-3.0"/>
  <img src="https://img.shields.io/badge/C99-single%20file-c8c2b2?style=flat-square&labelColor=14130f" alt="C99 single file"/>
  <img src="https://img.shields.io/badge/providers-13%2B-c8c2b2?style=flat-square&labelColor=14130f" alt="13+ providers"/>
  <img src="https://img.shields.io/badge/platforms-5-c8c2b2?style=flat-square&labelColor=14130f" alt="5 platforms"/>
</p>

<p align="center">
  <sub><a href="https://mithraeums.github.io">site</a> &nbsp;·&nbsp; <a href="https://github.com/mithraeums/hakoCLAW/releases">releases</a> &nbsp;·&nbsp; <a href="CHANGELOG.md">changelog</a> &nbsp;·&nbsp; <a href="https://github.com/mithraeums/hako">hako</a> &nbsp;·&nbsp; <a href="https://github.com/mithraeums">org</a></sub>
</p>

<br>

```
    █       █     hakoCLAW v0.1.4
   ███     ███    provider: gemini
 ███████████████  model: gemini-2.5-flash
 ███░████████░██  trust: granted
 ███████████████
 ███████████████
```
<table>
  <tr>
    <td width="33%" valign="top"><b>Local first.</b><br/><sub>Your text, your keys, your weights. No telemetry. No silent network. The cursor is a private place.</sub></td>
    <td width="33%" valign="top"><b>Single binary.</b><br/><sub>One C file. Builds with <code>gcc -lpthread</code>. Curl on PATH for HTTP. Nothing else linked.</sub></td>
    <td width="33%" valign="top"><b>Bring your own deity.</b><br/><sub>Anthropic, OpenAI, Gemini, Groq, Cerebras, Ollama, plus 7 more. Set a key, set a model, that's the wire.</sub></td>
  </tr>
</table>

<p align="center"><sub><b>—— I ——</b></sub></p>

## Overview

- **Terminal-class line editor.** Termios raw mode, cursor keys, history (↑ ↓), `^R` reverse-search, Home/End, kill-word, kill-line, bracketed paste. Multi-row aware redraw, no flicker.
- **13 providers, 3 wire formats.** Anthropic native (SSE), OpenAI function-calling, Ollama local. Aliases route Gemini, Groq, Cerebras, DeepSeek, Mistral, Together, Fireworks, OpenRouter, xAI/Grok, custom over OpenAI-compat. `koi` slot reserved for [hakoAI](https://github.com/mithraeums/hakoAI).
- **Trust-gated tools.** `read_file`, `list_dir`, `write_file` (with staging), `run_shell` (10s timeout). Untrusted dir = all tools refused. `/trust` once per project.
- **Persistent sessions + skills.** Per-cwd session id, 7-day resume, append-only JSONL history. Skills are markdown — flat or directory dispatchers ([corp](https://github.com/mithraeums/skills/tree/main/corp)-style) — pulled on demand via the `read_skill` tool. Notes you keep on disk for the agent to find.
- **Self-update.** `hakoc --update` pulls the latest GitHub release, verifies sha256, atomically replaces the binary. No reinstall, no rebuild.
- **Streaming + spinners.** Anthropic SSE streams live tokens. 8 spinner styles × 12 thinking labels rotate per turn (`⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏`).

<p align="center"><sub><b>—— II ——</b></sub></p>

## Build & Run

### Build

```sh
gcc hakoCLAW.c -o hakoc -lpthread        # one-liner

make                                      # cross-OS Makefile
make UNIVERSAL=1                          # macOS arm64 + x86_64 fat binary
make asan                                 # ASan + UBSan build
```

> Deps: libc + pthread + `curl(1)` on PATH. No third-party libraries linked.

### Install

```sh
curl -fsSL https://mithraeums.github.io/install.sh | sh
```

Detects OS and arch, downloads the latest signed release, verifies the sha256 sidecar, drops `hakoc` into `/usr/local/bin` (or `~/.local/bin`). No package manager. No daemon. No telemetry.

<table align="center">
  <tr>
    <td align="center"><b>macOS</b><br/><sub>universal2 · arm64 + x86_64</sub></td>
    <td align="center"><b>Linux</b><br/><sub>x86_64 · arm64</sub></td>
    <td align="center"><b>FreeBSD</b><br/><sub>x86_64</sub></td>
    <td align="center"><b>Windows</b><br/><sub>x86_64 · MinGW</sub></td>
    <td align="center"><b>iSh</b><br/><sub>linux-x86_64 binary</sub></td>
  </tr>
</table>

### First turn

```sh
hakoc                    # interactive REPL
> /login gemini          # opens browser, prompts for free-tier key
> /model gemini-2.5-flash
> what's in this directory?
```

Or one-shot:

```sh
hakoc -p "summarize README.md"
```

Self-update:

```sh
hakoc --update           # check + atomic-replace if newer
```

<p align="center"><sub><b>—— III ——</b></sub></p>

## Key Bindings & Commands

### Normal Mode

| Key | Action |
|---|---|
| ← → | move cursor |
| ↑ ↓ | history prev / next |
| Home / End · `^A` / `^E` | line start / end |
| `^U` / `^K` / `^W` | kill to start / end / word |
| `^R` | reverse-incremental history search |
| `^L` | clear screen |
| Backspace · Delete | delete back / forward at cursor |
| `^C` | cancel current line |
| `^D` (empty) | EOF / exit |

*Bracketed paste enabled in raw mode — multi-line pastes batch-insert.*

### Slash commands (inside prompt):

```
/help            /clear
/login [<prov>]  /provider <name>   /model <id>      /models
/history [local|global]
/skills [reload]    /skill install <url>    /skill uninstall <name>
/tools on|off       /trust [revoke]         /usage
/sessions           /resume <id>            /session [new]
/quit
```

<p align="center"><sub><b>—— IV ——</b></sub></p>

## Configuration

### Auth · Trust · State

```
~/.hakoc/state              provider, model, api key (mode 0600)
~/.hakoc/history            append-only JSONL chat log
~/.hakoc/skills/            markdown behaviors (flat or dir-dispatcher)
~/.hakoc/input_history      line editor history (last 500)
~/.hakocrc                  user config
<cwd>/.hakoc/state          per-project session id, turn count
<cwd>/.hakoc/trust          sentinel: tools allowed in this cwd
```

Keys are read in this order: `CLAW_API_KEY` env → `<PROVIDER>_API_KEY` env → `~/.hakoc/state` → `~/.hakocrc`. `/login <provider>` opens the provider console in your browser, prompts with input hidden, persists 0600.

First run in any directory asks for trust. Untrusted = no tool access at all.

### Provider/Model

| Provider       | id (`/provider <id>`)    | Free tier      | Wire format       |
|---             |---                       |---             |---                |
| Anthropic      | `anthropic` · `claude`   | —              | native + SSE      |
| OpenAI         | `openai` · `gpt`         | —              | function-calling  |
| Ollama (local) | `ollama` · `local`       | ∞              | native            |
| Gemini         | `gemini` · `google`      | ✓ generous     | OpenAI-compat     |
| Groq           | `groq`                   | ✓ fastest      | OpenAI-compat     |
| Cerebras       | `cerebras`               | ✓              | OpenAI-compat     |
| OpenRouter     | `openrouter`             | `:free` models | OpenAI-compat     |
| Mistral        | `mistral`                | rate-limited   | OpenAI-compat     |
| DeepSeek       | `deepseek`               | —              | OpenAI-compat     |
| Together       | `together`               | —              | OpenAI-compat     |
| Fireworks      | `fireworks`              | —              | OpenAI-compat     |
| xAI            | `xai` · `grok`           | —              | OpenAI-compat     |
| custom         | `custom`                 | depends        | OpenAI-compat     |

*13 provider names; 3 wire formats (Anthropic, Ollama, OpenAI-compat). Quickest path with no card: `hakoc` → `/login gemini` → `/model gemini-2.5-flash`. Does **not** bypass paid subscriptions (Claude Pro, ChatGPT Plus) — those are first-party-client-only.*

<p align="center"><sub><b>—— V ——</b></sub></p>

## Skills

```
~/.hakoc/skills/
├── style.md                  flat skill — whole file injected
└── corp/                     directory skill — SKILL.md is the dispatcher
    ├── SKILL.md
    └── .claude/agents/
        ├── CEO.md
        ├── DEV.md
        └── QA.md
```

Directory skills inject only `SKILL.md` plus a `<files>` manifest. The agent reads inner files on demand via `read_skill(skill, path)` — no trust gate (skills are user-installed), path-traversal blocked.

```sh
git clone https://github.com/mithraeums/skills ~/.hakoc/skills/_tmp
cp -r ~/.hakoc/skills/_tmp/corp ~/.hakoc/skills/
rm -rf ~/.hakoc/skills/_tmp
hakoc        # "loaded 1 skill(s)"
```

Browse the catalog: [mithraeums/skills](https://github.com/mithraeums/skills).

<p align="center"><sub><b>—— VI ——</b></sub></p>

## Change Log

### v0.1.4 (Latest)<br>
- **`--pipe` mode** for hako integration — JSONL I/O over stdin/stdout. Hako spawns `hakoc --pipe` once per Rei pane and drives the agent without embedding it.
- **Mithraeum palette by default** — gold / paper / rust / dim chalk truecolor. Matches the hako default theme + site banners + icon.

See [CHANGELOG.md](CHANGELOG.md) for full history.

<p align="center"><sub><b>—— VII ——</b></sub></p>

## Roadmap

- [ ] Termios line editor
- [ ] `--update`
- [ ] directory skills + `read_skill`
- [ ] universal2, Linux arm64, FreeBSD x86_64
- [ ] editor integration in [hako](https://github.com/mithraeums/hako) (build-time `make AI=0|1`), pluggable local model backend.
- [ ] [hakoAI](https://github.com/mithraeums/hakoAI)/`koi` engine plugin, OAuth where providers add it

<p align="center"><sub><b>—— VIII ——</b></sub></p>

## Contributing
If you share the belief that simplicity empowers creativity, feel free to contribute.

### Contribution is welcome in the form of:
- Forking this repo
- Submitting a Pull Request
- Bug reports and feature requests

Please ensure your code follows the existing style.

### Thank you for your attention.
This project started out of curiosity and as a branch of [hako](https://github.com/mithraeums/hako), a C based modal text editor. If you hit any issues, feel free to open an issue on GitHub.
Pull requests, suggestions, or even thoughtful discussions are welcome.

<p align="center"><sub><a href="LICENSE">— SEE LICENSE —</a> &nbsp;·&nbsp; GPL-3.0</sub></p>

<p align="center"><sub><em>— deus sol invictus mithras —</em></sub></p>

