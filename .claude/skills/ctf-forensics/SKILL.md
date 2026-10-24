---
name: ctf-forensics
description: Solve CTF forensics challenges by analyzing provided files offline - pcaps, disk/memory images, media files, embedded data, and steganography. Use for any "here is a file, find the flag" forensics task. Works on saved artifacts you're given or capture.
---

# CTF Forensics

You analyze **saved artifacts** in `files/` — pcaps, images, dumps. Forensics is inherently
offline work on files you already have; if you need a fresh capture, grab it and then
analyze the resulting file.

## Triage every file first
- `file`, `xxd | head` (magic bytes — trust these over extensions), `strings -n 6 | grep -i <prefix>` (flag prefix from the active CTF's `ctfs/<active>/CTF.md`).
- `binwalk <f>` to survey embedded content; `binwalk --dd` / `foremost` to carve **into a
  scratch dir** (never execute carved binaries).
- `exiftool <f>` for metadata (GPS, comments, author, thumbnails).

## By artifact type
- **Images (PNG/JPG/GIF/BMP):** metadata (`exiftool`), appended data after EOF, LSB steg
  (`zsteg` for PNG/BMP), `steghide` (JPG/WAV, try empty + guessed passphrase), color-plane
  analysis (stegsolve — human GUI), truncated dimensions, polyglot files.
- **Audio:** spectrogram (Sonic Visualiser/Audacity — human GUI; you interpret screenshots),
  DTMF, Morse, LSB.
- **PCAP/PCAPNG:** `tshark -r <f>` — protocol hierarchy, `-Y` display filters, follow TCP/HTTP
  streams, export objects (`--export-objects http,<dir>`), extract credentials/files, decode
  odd protocols. Reassemble transferred files and inspect them. (Human opens Wireshark GUI if
  helpful; you drive `tshark` on the saved file.)
- **Disk images:** partition/filesystem layout, deleted files, `strings`, mount read-only
  (human), `binwalk`, known-file carving.
- **Memory dumps:** volatility3 (`pslist`, `cmdline`, `filescan`, `dumpfiles`, `netscan`).
- **Office/PDF:** macros (`olevba`), embedded objects, `pdf-parser`, incremental-update history.
- **Archives:** nested archives, zip password (crack offline if intended), zip-slip, comments.

## Workflow
1. Triage → hypothesis of where the flag hides. Record in `notes.md`.
2. Write extraction/analysis commands into `scripts/` (run offline ones yourself; carve into
   a scratch dir, don't execute output).
3. Recover the flag → `solution.md`.

## Tools on this box
Installed now (run from WSL, e.g. `wsl zsteg /mnt/c/Users/adost/uscc-ctf/.../img.png`):
`binwalk`, `exiftool`, `steghide`, `zsteg`, `pngcheck`, `7z`, `strings`/`xxd`/`file`, plus
`ffmpeg` on the Windows side.
Install on demand (Tier-2 — say the word): `stegseek` (steghide brute-force), `foremost` +
`sleuthkit` (mmls/fls/icat) + `testdisk` for disk images, `tesseract` (OCR), `sox` (audio),
`imagemagick`, and `volatility3` for memory dumps (RAM-heavy — run one at a time).

## Guardrails
- Analyze provided files only; live capture isn't part of jeopardy forensics. Don't execute
  carved/embedded binaries — analyze them statically (route to `ctf-rev` if needed).
- Recovered flag → `solution.md` (don't auto-submit).
