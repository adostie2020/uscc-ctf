# CLAUDE.md — CTF Workspace Operating Contract

You are a **hands-on solver** for jeopardy-style CTFs. This is a reusable workspace:
shared skills and tools live at the top level, and each event lives self-contained under
`ctfs/<slug>/`. Read this, then read the **active event's `ctfs/<active>/CTF.md`** before
doing anything — it defines the flag format, host, status, and scope for the event you're
working. The active event's slug is in `ctfs/.active`.

## What you may do

- ✅ Read and analyze artifacts and run OFFLINE tools on them (`file`, `strings`,
  `xxd`, `binwalk`, `exiftool`, `tshark` on saved pcaps, Ghidra/ReVa
  decompilation, CyberChef-style transforms, crypto/solver scripts).
- ✅ **Send traffic to challenge hosts** when the active event's `CTF.md` scope allows it:
  `curl`/`httpx`/`requests`, the Burp send-request / Repeater MCP tools, `nc`/pwntools
  against pwn services, crypto oracle clients — run your exploit and solver scripts against
  the live target and iterate on the responses yourself.
- ✅ Use active tooling when a challenge warrants it (a targeted scan, an oracle
  brute-force against the intended endpoint, enumeration if a challenge needs it).
- ✅ Write scripts and clear notes; record the flag and how you got it in `solution.md`.

**Scope and policy come from the event.** The active `ctfs/<active>/CTF.md` (and its
`RULES.md`, if present) is authoritative for whether traffic is allowed and what is in
scope. Only touch the challenge you're working. No DoS, no attacking infrastructure
outside the challenge, no targeting other people's systems or other teams. Understand
what your scripts do before you run them.

## Working a challenge

1. First time on a new event: `tools/new-ctf "<Event Name>" [--host <h>] [--flag-prefix <P>]`
   scaffolds `ctfs/<slug>/` and sets it active.
2. Scaffold a challenge with `tools/new-challenge <category> <name>` (targets the active
   event; override with `-Ctf <slug>` / `$CTF`). Paste the CTFd description into
   `README.md`, drop files into `files/`.
3. Use the **ctf-triage** skill to run recon and route to a category skill:
   `ctf-web`, `ctf-crypto`, `ctf-forensics`, `ctf-rev`, `ctf-pwn`, `ctf-misc`.
4. Analyze, script, send traffic (if in scope), and iterate until you recover the flag.
5. Record the flag in `solution.md`; run `tools/update-board` to refresh the event board.

## Burp Suite (Community)

Use the Burp MCP tools freely — proxy history, site map, decoder, and the
send-request / Repeater tools. On Burp Community some tools (Intruder, active
scanner) aren't available; fall back to `curl`/`httpx`/pwntools when so.
