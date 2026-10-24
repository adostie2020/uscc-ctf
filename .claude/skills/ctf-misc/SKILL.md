---
name: ctf-misc
description: Solve CTF miscellaneous challenges that don't fit web/crypto/forensics/rev/pwn - encodings, esoteric languages, QR/barcodes, jails (pyjail/bash), scripting puzzles, and OSINT. You analyze, script, and run the networked steps yourself.
---

# CTF Misc

Grab-bag. Identify what it actually is, then apply the right sub-approach. Analyze and
script it, and run the networked/interactive steps yourself.

## Common types
- **Encoding chains:** base64/32/85, hex, binary, Morse, braille, ROT, URL, gzip/zlib.
  Peel layers with CyberChef (human) or a `python` script; the flag prefix (from the active CTF's `ctfs/<active>/CTF.md`) is your target marker.
- **Esoteric languages:** Brainfuck, Whitespace, Malbolge, Piet, ><> — identify by shape,
  run an interpreter offline.
- **QR / barcodes / data matrix:** decode from the image (offline libs); repair damaged codes.
- **Jails (pyjail / bash / calc):** analyze the sandbox source in `files/`, craft a bypass
  payload, and send it to the live jail yourself (in scope). Don't brute-force the endpoint.
- **Scripting/logic puzzles / "programming":** if a remote service fires rapid questions,
  write the client and run it yourself; solve the logic offline first.
- **OSINT:** search and fetch public sources yourself to interpret findings and plan
  queries (OSINT targets are public, not the challenge host).

## Workflow
1. Identify the true nature (don't assume from the title). Note it in `notes.md`.
2. Solve/scaffold offline, then run any networked step yourself within the event scope.
3. Flag → `solution.md`.

## Tools on this box
`python3` (Windows + WSL) for decoders/interpreters, `jq` (WSL), `7z` for odd archives,
`steghide`/`zsteg`/`binwalk`/`exiftool` for file-ish misc, `ffmpeg` (Windows) / `sox` (Tier-2)
for media. Peel encoding chains with a quick `python` script; the flag prefix is your marker.

## Guardrails
- Run the networked/interactive steps yourself within the event's scope
  (`ctfs/<active>/CTF.md`) — jail payloads, question-answering clients — iterating on
  responses. Stay on the challenge's own service; no DoS. Flag → `solution.md`.
