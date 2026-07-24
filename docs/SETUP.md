# Environment Setup

All tools are free. Install what you need per your role; run `tools/verify-env.ps1`
(or `.sh`) to see what's present.

## Core (everyone)
- **Python 3** — https://www.python.org/downloads/  → then `pip install pwntools`
- **CyberChef** — https://gchq.github.io/CyberChef/ (web app; the human drives it)
- **file / strings / xxd** — Git Bash / coreutils (already present via the Bash tool)

## Reverse engineering & pwn
- **Ghidra** — https://ghidra-sre.org/  (add `support/` to PATH for `analyzeHeadless`)
- **ReVa (Reverse Engineering Assistant)** — Ghidra extension exposing an MCP server.
  Install the extension, enable it, and note the MCP endpoint it prints (used in `.mcp.json`).
- **ROPgadget / ropper** — `pip install ROPgadget ropper` (pwn gadget search)

## Web
- **Burp Suite Community** (free) — https://portswigger.net/burp/communitydownload
  Community is sufficient per the organizers. No active scanner; Intruder is rate-limited.
- **PortSwigger MCP** — load the "MCP Server" extension in Burp (Extensions tab); note its
  endpoint (used in `.mcp.json`). The agent uses READ-ONLY tools only — proxy history, site
  map, decoder (see `../CLAUDE.md`). **Fallback:** if the extension will not load in
  Community, skip `.mcp.json`'s `burp` entry and instead export Burp HTTP history
  (Proxy → HTTP history → Save items) to the challenge `files/` for the agent to read.

## Forensics
- **Wireshark** (+ **tshark** CLI) — https://www.wireshark.org/
- **binwalk** — `pip install binwalk`
- **exiftool** — https://exiftool.org/
- **foremost** — `apt/brew install foremost` (or use binwalk)
- steg: **steghide**, **zsteg**, **stegsolve** (as needed)

## After install
1. Run `tools/verify-env.ps1`. No PowerShell 7 (`pwsh`) on Windows? Run `powershell -NoProfile -File tools/verify-env.ps1` instead — the `.ps1` scripts work under both.
2. Start Ghidra+ReVa and Burp+MCP, then run `/mcp` in Claude Code to confirm both connect.
