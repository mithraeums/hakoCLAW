<p align="center">
  <img src="icon/hakoCLAW.svg" alt="hakoCLAW" width="160"/>
</p>

<p align="center">
  <strong>hakoCLAW</strong>
</p>

<p align="center">
  <em>A standalone terminal AI agent in a single C file. Quiet, model-agnostic, skill-driven.</em>
</p>

<p align="center">
  <sub><b>v0.1.2</b> · <b>GPL-3.0</b> · <b>C99</b> · <b>~3.5k LOC</b> · <b>13+ providers</b> · <b>5 platforms</b></sub>
</p>

<br>

```
  ▄█████▄    hakoCLAW v0.1.2
 ██ ███ ██   provider: gemini
 █████████   model: gemini-2.5-flash
 ▀█▀▀█▀▀█▀   trust: granted
```

## Quickstart

```sh
# install (macOS · Linux · FreeBSD · WSL)
curl -fsSL https://mithraeums.github.io/install.sh | sh

# point it at a free-tier provider
hakoc
> /login gemini       # opens browser to console, prompts for key
> /model gemini-2.5-flash
> what's in this directory?
```

That's it. No card, no quota dance, no telemetry — your keys land in `~/.hakoc/state` (mode 0600) and the binary talks straight to the provider you chose.

## Overview

- **One file, one binary.** `hakoCLAW.c` (~2700 LOC). Builds with `gcc -lpthread`. Curl on PATH for HTTP. Nothing else linked.
- **Model-agnostic.** 13+ providers wired natively or via OpenAI-compatible function-calling. Local Ollama works offline. `koi` slot reserved for [hakoAI](../hakoAI) weights.
- **Tool loop.** `read_file`, `list_dir`, `write_file` (with staging), `run_shell` (10s timeout). Schemas auto-generated for both Anthropic and function-calling formats.
- **Trust gate.** Untrusted dir = no tool access at all. `/trust` once per project; the model sees the refusal and asks you to grant.
- **Persistent sessions + skills.** Per-cwd session id, 7-day resume rule, append-only JSONL history, startup menu picks new vs resume vs continue. Skills are markdown — flat files or directory dispatchers (corp-style) — injected at startup and pullable on demand via the `read_skill` tool. Notes you keep on disk for the agent to find.
- **Real terminal UX.** Termios raw line editor: cursor keys, history (↑/↓), Home/End, kill-word, kill-line. Streaming SSE for Anthropic; spinner+label rotation while waiting.
- **Self-update.** `hakoc --update` pulls the latest GitHub release, verifies sha256, atomically replaces the binary. No reinstall, no rebuild.
- **Mascot + 8 spinners.** Ghost mascot from hako, `--mascot <path>` for custom ASCII. `/braille /dots /bar /pulse /bounce /ghost /arrows /blocks`.

## Install

### Curl one-liner

```sh
curl -fsSL https://mithraeums.github.io/install.sh | sh
```

Detects OS/arch, downloads the matching release tarball, verifies the sha256 sidecar, drops `hakoc` into `/usr/local/bin` (or `~/.local/bin` if not root). Strips the macOS quarantine xattr automatically. Override with `REPO=<owner>/<repo>`, `PREFIX=<dir>`, or `VERIFY=0` env vars.

### Platforms

| OS | Arch | Asset |
|---|---|---|
| macOS | universal2 (arm64 + x86_64) | `hakoCLAW-macos-universal.tar.gz` |
| Linux | x86_64 | `hakoCLAW-linux-x86_64.tar.gz` |
| Linux | arm64 | `hakoCLAW-linux-arm64.tar.gz` |
| FreeBSD | x86_64 | `hakoCLAW-freebsd-x86_64.tar.gz` |
| Windows | x86_64 (MinGW) | `hakoCLAW-windows-x86_64.zip` |

iSh on iOS runs the linux x86_64 build directly — no separate target needed.

### Self-update

```sh
hakoc --update         # check + replace if newer
hakoc --update-force   # re-download even if same version
```

Atomic via `rename(2)`. sha256 mandatory; refuses to install if the sidecar is missing or doesn't match.

## Build from source

```sh
gcc hakoCLAW.c -o hakoc -lpthread

# or the Makefile (icon embed on Windows, attach on macOS, no-op on Linux)
make

# macOS universal2 (arm64 + x86_64 fat binary)
make UNIVERSAL=1
```

ASan + UBSan:
```sh
make asan && ./hakoc_asan
```

> **Deps:** libc + pthread + `curl(1)` on PATH. No third-party libraries linked.

### Executable icon

`icon/build-icons.sh` rasterizes `icon/hakoCLAW.svg` into `.icns`, `.ico`, `.png`, and the macOS `.iconset/`. Needs `librsvg` or `imagemagick`. See `icon/README.md`.

## Run

Interactive REPL:
```sh
hakoc
```

One-shot:
```sh
hakoc -p "summarize README.md"
```

Custom mascot + pinned anim + debug response dump:
```sh
hakoc --mascot ~/my_ghost.txt --anim ghost --debug
```

## Providers

| Provider | id | Free tier? | Native? |
|---|---|---|---|
| Anthropic | `anthropic` / `claude` | — | yes (SSE) |
| OpenAI | `openai` / `gpt` | — | function-calling |
| Ollama (local) | `ollama` / `local` | ∞ | yes |
| Gemini | `gemini` / `google` | ✓ generous | OpenAI-compat |
| Groq | `groq` | ✓ fastest | OpenAI-compat |
| Cerebras | `cerebras` | ✓ | OpenAI-compat |
| OpenRouter | `openrouter` | `:free` models | OpenAI-compat |
| Mistral | `mistral` | rate-limited | OpenAI-compat |
| DeepSeek · Together · Fireworks · xAI · Grok · custom | varies | — | OpenAI-compat |
| `koi` (hakoAI) | `koi` | — | aliases ollama (placeholder) |

Quickest path with no card: `hakoc` → `/login gemini` → `/model gemini-2.5-flash`.
Does **not** bypass paid subscriptions (Claude Pro, ChatGPT Plus) — those are first-party-client-only.

## Auth

Key resolution order:
1. `CLAW_API_KEY` env var (always wins)
2. `<PROVIDER>_API_KEY` env var (`GOOGLE_API_KEY`, `ANTHROPIC_API_KEY`, `OPENAI_API_KEY`, `GROQ_API_KEY`, `CEREBRAS_API_KEY`, `DEEPSEEK_API_KEY`, `MISTRAL_API_KEY`, `TOGETHER_API_KEY`, `FIREWORKS_API_KEY`, `OPENROUTER_API_KEY`, `XAI_API_KEY`)
3. `~/.hakoc/state` (written by `/login`, mode 0600)
4. `~/.hakocrc` (`ai_api_key=...`)

`/login <provider>` opens the provider console in your browser, prompts for the key with input hidden, persists to `~/.hakoc/state`.

## Trust

First run in a directory shows:
```
  Trust this directory for tool access?
  cwd: /path/to/project
  (untrusted = no read_file, list_dir, write_file, run_shell)
  grant trust? [y/N]
```

Untrusted = **all** tools refused. The model sees the trust error in tool output and asks you to grant. `/trust` to grant later, `/trust revoke` to drop.

## Line editor

Termios raw mode when stdin is a tty. Falls back to `getline` otherwise.

| Key | Action |
|---|---|
| ← / → | move cursor |
| ↑ / ↓ | history prev/next |
| Home / End | line start/end |
| `^A` / `^E` | line start/end |
| `^U` | kill to start |
| `^K` | kill to end |
| `^W` | kill word back |
| `^L` | clear screen |
| `^R` | reverse-incremental history search |
| Backspace / `^H` | delete back |
| Delete | delete forward |
| `^C` | cancel current line |
| `^D` (empty line) | EOF / exit |

Input history persists at `~/.hakoc/input_history` (last 500 entries, dedup-adjacent). Bracketed paste mode is enabled in raw mode — multi-line pastes batch-insert as a single edit instead of firing Enter on every newline.

## Skills

Skills are markdown that gets injected into the agent's system prompt at startup. Drop a file or a folder into `~/.hakoc/skills/`:

```
~/.hakoc/skills/
├── style.md                  # flat skill — whole file injected
└── corp/                     # directory skill — SKILL.md is the dispatcher
    ├── SKILL.md              # injected at startup with a manifest of inner files
    ├── README.md
    └── .claude/agents/
        ├── CEO.md
        ├── DEV.md
        └── QA.md
```

Flat (`style.md`) injects whole. Directory skills inject only `SKILL.md` plus a `<files>` manifest of every `.md` under the dir (depth ≤ 4). The agent reads inner files on demand via the `read_skill` tool — no trust gate (skills are user-installed by definition), path-traversal blocked.

This is what makes [corp](https://github.com/zblauser/CORP) (multi-agent dispatcher: CEO/DEV/DESIGN/QA/ARCH) run native in claw — `SKILL.md` orients the model, then `read_skill(skill="corp", path=".claude/agents/DEV.md")` pulls the specialist on demand. The same pattern works for any skill that ships as a folder of markdown.

```sh
# install corp into claw
git clone https://github.com/zblauser/CORP ~/.hakoc/skills/corp
hakoc          # "loaded 1 skill(s)"
> /skills      # confirm corp is in the manifest
```

The `read_skill` tool is exposed to the model alongside `read_file` / `list_dir` / `write_file` / `run_shell`. The system prompt tells it which skills are available and what files each contains.

## Slash commands

```
/help            /clear
/login [<prov>]  /provider <name>   /model <id>
/history [local|global]
/skills [reload]    /skill install <url>    /skill uninstall <name>
/tools on|off       /trust [revoke]         /usage
/sessions           /resume <id>            /session [new]
/quit
```

## Animations

Eight thinking-spinner styles, rotated per turn. Pin one with `--anim <name>` or `anim_style=<name>` in `.hakocrc`:

| name    | preview |
|---------|---------|
| braille | `⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏` |
| dots    | `.   ..  ... ` |
| bar     | `▏▎▍▌▋▊▉█` |
| pulse   | `⠂⠆⠇⠧⠷⠿` |
| bounce  | `◐◓◑◒` |
| ghost   | `ᗜˬᗜ ᗜ◡ᗜ ᗜ‿ᗜ` |
| arrows  | `←↖↑↗→↘↓↙` |
| blocks  | `▖▘▝▗` |

12 rotating labels: thinking, pondering, considering, computing, reasoning, reading, plotting, musing, weaving, chewing on it, consulting the oracle, sharpening the claws.

## State

| Path | Purpose |
|---|---|
| `~/.hakoc/state` | provider, model, api key (mode 0600), session defaults |
| `~/.hakoc/history` | append-only JSONL chat log |
| `~/.hakoc/skills/*.md` | system-prompt skills (loaded at launch) |
| `~/.hakoc/input_history` | line editor history (last 500 entries) |
| `<cwd>/.hakoc/state` | per-project session_id, turn count, timestamps |
| `<cwd>/.hakoc/trust` | sentinel: tools allowed in this cwd |
| `~/.hakocrc` | user config (provider, model, mascot_path, anim_style, ...) |

## Security

- `read_file` / `list_dir`: scoped to cwd, path-traversal blocked, **gated by trust**.
- `write_file` / `run_shell`: gated by trust. With `ai_autowrite=0`, `write_file` stages to `<path>.hakoc-pending` for review.
- `run_shell` runs under `timeout 10 sh -c` — 10s wall clock cap, no interactive stdin.
- API keys at `~/.hakoc/state` mode 0600.
- `--update` refuses to install if the sha256 sidecar is missing or doesn't match.

## Roadmap

- **v0.1.2** (current) — termios line editor, `--update` self-updater, directory skills + `read_skill`, universal2 macOS, Linux arm64, FreeBSD x86_64.
- **v0.2** — editor integration (build-time `make AI=0|1` in hako), pluggable local model backend.
- **v0.3+** — hakoAI/koi engine plugin, `/login` OAuth where providers add it.

See [CHANGELOG.md](CHANGELOG.md) for details.

## License

GPL-3.0.

<sub><em>— deus sol invictus mithras —</em></sub>
