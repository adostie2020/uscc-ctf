---
name: ctf-web
description: Analyze CTF web challenges and send the requests/payloads yourself. Use for HTTP/web app challenges - IDOR, auth bypass, SQLi, XSS, SSTI, LFI/path traversal, deserialization, JWT, logic flaws.
---

# CTF Web

You analyze web challenges and **send the requests/payloads yourself**. Look for the
intended flaw first — most of these challenges don't need blind fuzzing — but use active
tooling when it helps.

## How you interact with the target
Within the event's scope (`ctfs/<active>/CTF.md`), **you send the requests yourself** and
iterate on the responses:
- `curl` / `httpx` / Python `requests` from the shell, and the **Burp send-request /
  Repeater MCP** tools when the `burp` server is connected (CLAUDE.md allows these freely;
  if the MCP is down this session, fall back to `curl`/`requests`).
- The human may still browse through Burp Community for a quick look; read their captured
  history via the Burp MCP (proxy history, site map, decoder) or from an export in `files/`.
- Stay on the challenge's own origin; no DoS, no unrelated hosts.

## Methodology
1. **Map the app from what the human captured.** Endpoints, params, cookies, headers,
   tech stack (response headers), `robots.txt`, `view-source`, comments, JS files,
   `/sitemap`. Targeted enumeration only if the challenge calls for it — not broad fuzzing.
2. **Read the client.** DevTools, JS logic, hidden fields, client-side checks, source maps.
3. **Test inputs deliberately** (one intended vuln, not a scanner). Common classes:
   - **IDOR / access control:** change ids/roles; predictable object refs.
   - **Auth / session:** weak JWT (`alg=none`, weak secret → crack offline with the human),
     guessable tokens, cookie tampering, password reset logic.
   - **SQLi:** prefer manual payloads (`' OR 1=1-- -`, UNION, boolean/time-based).
   - **XSS:** reflected/stored/DOM; needed when a bot/admin views your input.
   - **SSTI:** `{{7*7}}`, `${7*7}` → identify engine → RCE/file read.
   - **LFI / path traversal:** `../`, PHP wrappers, `/proc/self/environ`.
   - **SSRF, open redirect, deserialization, mass assignment, race conditions.**
4. **Analyze responses** the human pastes back; refine the next single request.
5. **Exploit chain:** write a Python `requests`/`httpx` script into `scripts/` and run it
   yourself against the target, iterating until the flag drops.

## Offline work you may do yourself
- Decode/inspect JWTs, cookies, base64/hex, JS deobfuscation, hash cracking on a captured
  hash, building payloads, static review of any downloaded source in `files/`.

## Tools on this box
`curl`, `wget`, Python `requests` (Windows + WSL), `jq` for JSON (WSL), `nmap`/`ncat` for a
targeted service check. Offline: decode JWTs/cookies/base64, JS deobfuscation, hash cracking
on a captured hash. Burp Community has no active scanner/Intruder — drive requests manually
via the Repeater MCP or `curl`.

## Guardrails
- Send requests within the event's scope (`ctfs/<active>/CTF.md`) and iterate on responses.
  No broad directory/param fuzzing, no active scanners/Intruder (unavailable anyway), no
  DoS, no unrelated hosts. Record findings in `notes.md`; flag → `solution.md` (don't
  auto-submit).
