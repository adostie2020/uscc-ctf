# CTF Rules (distilled) — cite this when declining an action

Source: USCC West Coast 2026 briefing + `uscc-west-coast-2026.ctf.institute/rules`.

## Hard limits
- **No "auto-solve" tools** (e.g. sqlmap) that you run and they solve the challenge.
- **No directory enumeration / fuzzing** (dirb, gobuster, ffuf). Challenges are
  designed not to need them — fuzzing only wastes time and degrades challenges.
- **No pointing an AI at a challenge to auto-solve.** AI is a *collaborator*:
  talk through ideas, get scripts — but **you** understand and run them, and
  **you** are responsible for your traffic.
- **No sabotaging other teams / infrastructure** (e.g. intentional DoS).
- **No outside help from other people.**

## Why
The point is to *learn skills*. Heavy traffic degrades challenges for others.
Each challenge teaches something — don't let the AI build its training set while
your brain learns nothing. **Organizers watch traffic and flag submissions.**

## What IS allowed
- Scripts you wrote (or wrote collaboratively with AI) that **you** run yourself.
- Free tools: Burp Suite (Community, or Pro trial), Ghidra, Wireshark, CyberChef,
  Python. You should not need to pay for anything.

## How this maps to the agent
See `../CLAUDE.md`. The agent does OFFLINE analysis of downloaded artifacts and
writes scripts; the human runs every network action and submits every flag.
