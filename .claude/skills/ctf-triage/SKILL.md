---
name: ctf-triage
description: First step for any new CTF challenge. Run local recon on the downloaded artifacts, classify the challenge, seed notes, and route to the right category skill (web, crypto, forensics, rev, pwn, misc). Use when a challenge folder has just been scaffolded.
---

# CTF Triage (dispatcher)

You are the first responder for a new challenge. **You analyze local artifacts only.**
You never touch the challenge server — the human does (see `CLAUDE.md`). Your job:
identify what kind of challenge this is and route to the right skill.

## Steps

1. **Read the brief.** Open the challenge `README.md` (description, URL/server) and any
   text in `files/`. Note the flag format from the active CTF's `ctfs/<active>/CTF.md`.

2. **Recon the artifacts (offline).** For each file in `files/`:
   - `file <artifact>` — true type (ignore the extension).
   - `strings -n 6 <artifact> | head` and `grep -i` for the flag prefix (from the active CTF's `ctfs/<active>/CTF.md`), `flag`, `password`, URLs.
   - `xxd <artifact> | head` — inspect magic bytes.
   - If it's an archive/blob: `binwalk <artifact>` (do NOT auto-extract-and-run; just survey).

3. **Classify** using these signals:
   | Signal | Category | Skill |
   |---|---|---|
   | A URL / "connect to" / web app, HTML/JS, cookies, HTTP | web | `ctf-web` |
   | ELF/PE that reads input and could crash; "nc host port" + binary | pwn | `ctf-pwn` |
   | ELF/PE/.NET/APK to understand or extract a flag from (no crash needed) | rev | `ctf-rev` |
   | pcap/pcapng, disk/mem image, images/audio, embedded files, steg | forensics | `ctf-forensics` |
   | ciphertext, keys, encodings, "we encrypted", RSA/AES/XOR | crypto | `ctf-crypto` |
   | encodings/esolang/QR/jail/anything else | misc | `ctf-misc` |

   A `nc host port` with a provided binary is usually **pwn**; with only a prompt/logic
   puzzle it's often **misc**. When torn between rev and pwn: is the goal to *understand*
   the binary (rev) or to *crash/hijack* it to read a flag (pwn)?

4. **Seed `notes.md`** with: file types, notable strings, your classification + why, and
   the top 2 hypotheses.

5. **Set status.** Tell the human to set `- **Status:** in-progress` and `- **Owner:**`
   in the challenge `README.md`, then run `tools/update-board.ps1`.

6. **Route.** State the chosen category and switch to that skill.

## Guardrails
- Survey artifacts before running them; don't blindly execute an untrusted binary or
  auto-extract-and-run during triage — route that to `ctf-rev`/`ctf-pwn` first.
- Contacting the challenge server is fine once routed; stay within the challenge's scope.
