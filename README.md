# CTF — Team Workspace

Shared workspace for a CTF. An AI agent helps us analyze
challenges and write scripts; **we** run all challenge traffic and submit all
flags. Read `docs/RULES.md` and `CLAUDE.md` first.

## First-time setup
1. Install tools (see `docs/SETUP.md`), then run `tools/verify-env.ps1`.
2. Start Ghidra + ReVa and Burp + PortSwigger MCP; confirm with `/mcp` in Claude Code.
3. Open it in CTFd. Run a pipeline to crawl all challenges.

## Per challenge
1. Scaffold it:  `pwsh tools/new-challenge.ps1 <category> "<name>"`
   (or `bash tools/new-challenge.sh <category> "<name>"`).
   No PowerShell 7 on Windows? Use `powershell -NoProfile -File tools/new-challenge.ps1 <category> "<name>"` instead.
   Categories: web, crypto, forensics, rev, pwn, misc.
2. Paste the description into the new `README.md`; drop artifacts into `files/`.
3. Ask the agent to triage it. Run any `▶ RUN THIS YOURSELF` script it writes.
4. Submit the flag yourself; record it in `solution.md`; run `tools/update-board.ps1`.

## Layout
- `CLAUDE.md` — agent operating contract (guardrails).
- `docs/` — rules, setup.
- `.claude/skills/` — per-category methodology skills.
- `challenges/<category>/<slug>/` — one folder per challenge.
- `challenges/BOARD.md` — team status board (generated).
- `tools/` — scaffold, board, and environment scripts.
