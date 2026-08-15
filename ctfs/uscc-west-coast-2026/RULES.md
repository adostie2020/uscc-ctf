# CTF Rules — historical (the competition has ended)

> **The USCC West Coast 2026 CTF is over (ended 2026-07-25).** The limits below
> were the **organizers' constraints for the live event**. We now work the
> still-online challenges for practice, so they no longer bind the agent — see
> `../CLAUDE.md` for the current operating contract. This file is kept for
> context on why the framework was originally built the way it was.

Source: USCC West Coast 2026 briefing + `uscc-west-coast-2026.ctf.institute/rules`.

## What the live-event rules were
- No "auto-solve" tools (e.g. sqlmap) that you run and they solve the challenge.
- No directory enumeration / fuzzing (dirb, gobuster, ffuf).
- No pointing an AI at a challenge to auto-solve — AI was a *collaborator* only:
  you talked through ideas and got scripts, but **you** ran them and owned your
  traffic.
- No sabotaging other teams / infrastructure (e.g. intentional DoS).
- No outside help from other people.

Organizers watched traffic and flag submissions, and the point was to *learn
skills* — heavy traffic degraded challenges for everyone.

## Still just good sense (post-CTF)
- Don't DoS or attack anything outside the challenge scope.
- Understand what your scripts do — the point is still to learn.
