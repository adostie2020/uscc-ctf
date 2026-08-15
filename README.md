# CTF Workspace

A reusable workspace for jeopardy-style CTFs. Shared skills and tools live at the top
level; each event is self-contained under `ctfs/<slug>/`. Read `CLAUDE.md`, then the
active event's `ctfs/<active>/CTF.md`, first.

## First-time setup
1. Install tools (see `docs/SETUP.md`), then run `tools/verify-env.ps1`.
2. Start Ghidra + ReVa and Burp + PortSwigger MCP; confirm with `/mcp` in Claude Code.

## Adding a new CTF
```
pwsh tools/new-ctf.ps1 "<Event Name>" [-CtfHost <host>] [-FlagPrefix <PREFIX>]
# or
bash tools/new-ctf.sh "<Event Name>" [--host <host>] [--flag-prefix <PREFIX>]
```
This creates `ctfs/<slug>/{CTF.md, challenges/, artifacts/}` and writes the slug to
`ctfs/.active` so the other tools target it. Fill in `ctfs/<slug>/CTF.md` (host, status,
scope). To work several events at once, override the active one per command with
`-Ctf <slug>` (PowerShell) or `CTF=<slug>` (bash).

## Per challenge
1. Open it in CTFd. Copy the description; download the file / note the server link.
2. Scaffold it: `pwsh tools/new-challenge.ps1 <category> "<name>"`
   (or `bash tools/new-challenge.sh <category> "<name>"`).
   No PowerShell 7 on Windows? Use `powershell -NoProfile -File tools/new-challenge.ps1 <category> "<name>"`.
   Categories: web, crypto, forensics, rev, pwn, misc.
3. Paste the description into the new `README.md`; drop artifacts into `files/`.
4. Ask the agent to triage and work it — it can send the traffic itself when the event's
   `CTF.md` scope allows.
5. Record the flag in `solution.md`; run `tools/update-board.ps1` (or `.sh`).

## Layout
- `CLAUDE.md` — generic agent operating contract.
- `docs/` — setup and specs/plans (`docs/superpowers/`).
- `templates/` — scaffold templates, including `CTF.md` for new events.
- `.claude/skills/` — per-category methodology skills (shared across events).
- `tools/` — `new-ctf`, `new-challenge`, `update-board`, `crawl-challenges.py`, verify scripts.
- `ctfs/.active` — slug of the active event.
- `ctfs/<slug>/CTF.md` — per-event profile (flag format, host, status, scope).
- `ctfs/<slug>/challenges/<category>/<slug>/` — one folder per challenge.
- `ctfs/<slug>/BOARD.md` — per-event status board (generated).
- `ctfs/<slug>/artifacts/` — event-wide files (dumps, PDFs).

> The GitHub repo is named `ctf-workspace`. If your local clone still carries the old
> single-event folder name, rename it to `ctf-workspace` at your convenience — it is the
> session working directory, so do it yourself outside an active session.
