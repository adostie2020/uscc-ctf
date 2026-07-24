---
name: ctf-misc
description: Solve CTF miscellaneous challenges that don't fit web/crypto/forensics/rev/pwn - encodings, esoteric languages, QR/barcodes, jails (pyjail/bash), scripting puzzles, and OSINT. The agent analyzes and scripts offline; the human runs anything networked.
---

# CTF Misc

Grab-bag. Identify what it actually is, then apply the right sub-approach. Offline analysis
and scripting for you; networked interaction and searches are human handoffs.

## Common types
- **Encoding chains:** base64/32/85, hex, binary, Morse, braille, ROT, URL, gzip/zlib.
  Peel layers with CyberChef (human) or a `python` script; `USCC{` is your target marker.
- **Esoteric languages:** Brainfuck, Whitespace, Malbolge, Piet, ><> — identify by shape,
  run an interpreter offline.
- **QR / barcodes / data matrix:** decode from the image (offline libs); repair damaged codes.
- **Jails (pyjail / bash / calc):** analyze the sandbox source in `files/` and craft a
  bypass payload. The agent designs it; **the human sends it** to the live jail
  (`▶ RUN THIS YOURSELF`). Never brute-force the endpoint.
- **Scripting/logic puzzles / "programming":** if a remote service asks rapid questions,
  write a client the **human** runs (handoff); solve the logic offline.
- **OSINT:** the human performs searches and visits sites; you help interpret findings and
  plan queries. You don't fetch challenge-related URLs yourself.

## Workflow
1. Identify the true nature (don't assume from the title). Note it in `notes.md`.
2. Solve/scaffold offline; put any networked step behind a `▶ RUN THIS YOURSELF` handoff.
3. Flag → `solution.md`.

## Guardrails
- No fuzzing, no auto-solvers, no agent traffic. Human runs networked steps and submits flags.
