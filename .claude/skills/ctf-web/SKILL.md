---
name: ctf-web
description: Analyze CTF web challenges and craft requests/payloads for the human to send. Use for HTTP/web app challenges - IDOR, auth bypass, SQLi, XSS, SSTI, LFI/path traversal, deserialization, JWT, logic flaws. The agent analyzes; the human sends all traffic.
---

# CTF Web

You analyze web challenges and **write requests/payloads the human sends**. You do NOT
send traffic, fuzz, or enumerate directories (banned — see `docs/RULES.md`). Challenges
are designed to not need fuzzing; look for the intended flaw.

## How you interact with the target
- The **human** browses the app through **Burp Suite Community**. You read what they
  captured via the **read-only Burp MCP** (proxy history, site map, decoder). If the MCP
  is unavailable in Community, the human exports HTTP history into `files/` and you read
  the saved file. (Scanner issues are Pro-only — not available.)
- You craft exact requests/payloads and hand them off:

      ## ▶ RUN THIS YOURSELF
      Send this in Burp Repeater to <endpoint>; paste the response back.
      <the raw request>

## Methodology
1. **Map the app from what the human captured.** Endpoints, params, cookies, headers,
   tech stack (response headers, `Wappalyzer`/`BuiltWith` — human runs these), `robots.txt`,
   `view-source`, comments, JS files, `/sitemap`. No directory brute-forcing.
2. **Read the client.** DevTools, JS logic, hidden fields, client-side checks, source maps.
3. **Test inputs deliberately** (one intended vuln, not a scanner). Common classes:
   - **IDOR / access control:** change ids/roles; predictable object refs.
   - **Auth / session:** weak JWT (`alg=none`, weak secret → crack offline with the human),
     guessable tokens, cookie tampering, password reset logic.
   - **SQLi:** manual payloads (`' OR 1=1-- -`, UNION, boolean/time-based). No sqlmap.
   - **XSS:** reflected/stored/DOM; needed when a bot/admin views your input.
   - **SSTI:** `{{7*7}}`, `${7*7}` → identify engine → RCE/file read.
   - **LFI / path traversal:** `../`, PHP wrappers, `/proc/self/environ`.
   - **SSRF, open redirect, deserialization, mass assignment, race conditions.**
4. **Analyze responses** the human pastes back; refine the next single request.
5. **Exploit chain:** write a Python `requests`/`httpx` script into `scripts/` as a
   `▶ RUN THIS YOURSELF` handoff. The human runs it and pastes output.

## Offline work you may do yourself
- Decode/inspect JWTs, cookies, base64/hex, JS deobfuscation, hash cracking on a captured
  hash, building payloads, static review of any downloaded source in `files/`.

## Guardrails
- Never send requests, run active scans, or use Intruder — those MCP tools are denied.
- Never fuzz directories/params. Record findings in `notes.md`; flag goes to `solution.md`.
