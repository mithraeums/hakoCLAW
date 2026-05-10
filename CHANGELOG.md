# Changelog

All notable changes to hakoCLAW. Format: [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
This project follows semver (`v0.1.x` is pre-1.0; expect breaking changes between minor versions).

## [v0.1.2] — 2026-05-10

### Added
- **Termios raw line editor.** Cursor keys (← → Home End), readline-style chords (^A ^E ^U ^K ^W ^L), backspace/delete at cursor, ^C cancel, ^D EOF on empty.
- **Persistent input history** at `~/.hakoc/input_history` (last 500 entries, dedup-adjacent). ↑/↓ navigates.
- **Multi-row aware redraw.** Long inputs that wrap past terminal width no longer desync cursor; full linenoise-style row tracking + buffered single `write()`, hidden cursor during redraw.
- **`hakoc --update` self-updater.** Hits GH Releases API, downloads matching platform asset, verifies sha256 sidecar (mandatory, refuses on missing/mismatch), atomically replaces the binary via `rename(2)`. `--update-force` re-downloads even if same version.
- **macOS universal2 binary** (`make UNIVERSAL=1` adds `-arch arm64 -arch x86_64`). Single fat asset works on Apple Silicon and Intel.
- **Linux arm64 release** built on `ubuntu-24.04-arm` GitHub runner.
- **FreeBSD x86_64 release** built via `vmactions/freebsd-vm@v1`. Non-blocking — release publishes even if FreeBSD job fails.
- **install.sh sha256 verify** with `sha256sum` / `shasum` / `sha256` fallback chain; macOS quarantine xattr stripped post-install.
- **`LICENSE`** (GPL-3.0).
- **`CHANGELOG.md`** (this file).
- **`^R` reverse-incremental history search** in line editor. Esc/Enter exits, repeat `^R` cycles older matches.
- **Bracketed paste mode** (`\x1b[?2004h`) — multi-line pastes batch-insert without firing Enter on every newline.
- **Directory skills + `read_skill` tool.** Skill loader handles directories (load `SKILL.md` as dispatcher + inject a `<files>` manifest); `read_skill(skill, path)` reads files relative to a skill's root, path-traversal blocked, no trust gate. Enables corp-style dispatchers and any folder-of-markdown skill to run native.

### Changed
- README rewritten: quickstart up top, line editor table, platform matrix, `--update` section, philosophy paragraph.
- Asset name: `hakoCLAW-macos.tar.gz` → `hakoCLAW-macos-universal.tar.gz`.

### Fixed
- Cursor stuck at right edge / garbage chars when typing past terminal width.

## [v0.1.1] — 2026-05-08

### Added
- **`/login <provider>`** — opens browser to provider console, hides paste, persists key to `~/.hakoc/state` mode 0600.
- **Trust gate** on first run: `[y/N]` prompt with cwd shown. Untrusted = all tools refused (read_file, list_dir, write_file, run_shell). `/trust` to grant later.
- **Startup session menu** — pick new / resume / continue.
- **Provider expansion:** Gemini (Google AI Studio), Cerebras, custom, koi (placeholder for hakoAI engine, currently aliases ollama). Console URLs for `/login` browser-open.
- **Env vars** for every provider's API key (`ANTHROPIC_API_KEY`, `OPENAI_API_KEY`, `GOOGLE_API_KEY`/`GEMINI_API_KEY`, `GROQ_API_KEY`, `CEREBRAS_API_KEY`, `DEEPSEEK_API_KEY`, `MISTRAL_API_KEY`, `TOGETHER_API_KEY`, `FIREWORKS_API_KEY`, `OPENROUTER_API_KEY`, `XAI_API_KEY`) + `CLAW_API_KEY` always-wins.
- **`--debug`** flag dumps raw API responses to stderr per turn.
- **Icon:** `icon/hakoCLAW.svg` + `icon/build-icons.sh` (rsvg-convert / imagemagick).

### Changed
- Renamed everything: source `claw.c` → `hakoCLAW.c`, binary `claw` → `hakoc`, state dir `~/.claw/` → `~/.hakoc/`, project dir `<cwd>/.claw/` → `<cwd>/.hakoc/`, config `~/.clawrc` → `~/.hakocrc`.
- `read_file` and `list_dir` now also require trust (was: only `write_file` / `run_shell`).
- `aiExtractResponse` rewritten — handles tool-use-only responses, walks Anthropic `content[]` array, cleanly extracts `{"error":{"message":"..."}}` for any provider.
- Better config errors: `"missing api key for X. Run /login X, or set X_API_KEY env var"` + current model + endpoint.

### Fixed
- Duplicate user echo in REPL (terminal echoes input already; store-only path used).
- Empty-response error includes first 180 bytes of raw response for diagnosis.

## [v0.1.0] — 2026-05-08

### Added
- Initial standalone release. Lifted entire AI subsystem from `hako.c` (~2340 LOC).
- Provider resolution: Anthropic native, Ollama native, OpenAI function-calling + 7 aliases (deepseek/mistral/together/fireworks/openrouter/xai/grok).
- Tools: `read_file`, `list_dir`, `write_file` (with `ai_autowrite` staging), `run_shell` (10s timeout).
- HTTP layer (libcurl via popen + SSE parser).
- Tool loop: `hkFnToolExecAll` — Anthropic content-array + fn-calling with 6-iteration cap.
- Pthread worker for AI requests; `data->lock` mutex.
- Session/state save+load with 7-day resume rule.
- History JSONL log + tail loader rebuilding API stack.
- Skills loader (`~/.hakoc/skills/*.md` injected into system prompt).
- Slash commands: `/sessions /resume /session /usage /provider /model /help /clear /history /skills /tools /trust /quit`.
- ANSI-colored REPL with role bars, dim system, yellow tools, red errors.
- 8 spinner animations × 12 thinking labels, pthread-driven, joined cleanly before output. `--anim` pin / `anim_style=` config.
- Mascot from hako (default ghost), `--mascot <path>` for custom.
- Cross-OS Makefile (macOS / Linux / Windows-MinGW).
- `install.sh` curl one-liner.
- 3-OS release workflow gated on `v0.1*` tags + `v[1-9]*`.
