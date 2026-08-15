# Reusable Multi-CTF Workspace — Design

_2026-08-15_

## Goal

Turn the single-event `uscc-ctf` repo into a reusable **CTF workspace**: one set of
shared instructions, skills, and tooling at the top level, with each individual CTF
living in its own self-contained subfolder under `ctfs/`. Adding a new CTF should be
one command and never require forking the skills or tools.

The workspace is renamed `ctf-workspace` (local folder + GitHub repo).

## Current state (baseline)

- Single-event repo. The USCC West Coast 2026 event is hardcoded throughout:
  `CLAUDE.md` status/scope, `docs/RULES.md`, the flag prefix `USCC{` / `grep -i uscc`
  in all 7 category skills and `new-challenge`, board scanning `challenges/**`.
- 72 challenge folders under `challenges/<category>/<slug>/` — **untracked** in git
  (moves are plain filesystem `mv`, no git rename).
- Only 3 tracked files sit in the moving scope: `challenges/.gitkeep`,
  `challenges/BOARD.md`, `docs/RULES.md`.
- Loose USCC artifacts at repo root: `USCC CTF - Western.pdf`, saved
  `NENRONonline.html` + `NENRONonline_files/`, `CyberDyne Systems - Legacy Server
  Interface.html` + `_files/`, empty `stub.pHp`, and `challenges/ctfd_dump.json`.
- A stale full-repo copy at `.claude/worktrees/reblaze-handoff/` (registered git
  worktree, branch `worktree-reblaze-handoff`) whose `reblaze` `notes.md` and
  `scripts/payloads.md` are a **superset** of the main copy (newer "Corrected solve"
  content) — must be merged before deletion.

## Target layout

```
ctf-workspace/
├── CLAUDE.md          # generic contract; points to the ACTIVE ctf's CTF.md
├── README.md          # harness usage + "adding a new CTF"
├── .gitignore .mcp.json
├── .claude/skills/    # 7 ctf-* skills, de-USCC'd (flag prefix from CTF.md)
├── docs/
│   ├── SETUP.md               # generic, unchanged
│   └── superpowers/           # specs/plans, unchanged
├── templates/
│   ├── challenge-README.md    # unchanged
│   ├── notes.md               # unchanged
│   └── CTF.md                 # NEW: per-event profile template
├── tools/
│   ├── new-ctf.{ps1,sh}       # NEW: scaffold ctfs/<slug>/ + set active
│   ├── new-challenge.{ps1,sh} # → active event (override with -Ctf / $CTF)
│   ├── update-board.{ps1,sh}  # per-event BOARD.md
│   ├── crawl-challenges.py     # default out = active event's challenges/
│   ├── verify-env.{ps1,sh}
│   └── verify-skills.ps1
└── ctfs/
    ├── .active                # slug of the active event (one line)
    └── uscc-west-coast-2026/
        ├── CTF.md             # flag fmt, host, categories, status, scope
        ├── BOARD.md           # moved from challenges/BOARD.md
        ├── RULES.md           # moved from docs/RULES.md
        ├── artifacts/         # PDF, ctfd_dump.json, stub.pHp
        └── challenges/<category>/<slug>/   # all 72 folders move here
```

## Components

### 1. Per-event profile: `ctfs/<slug>/CTF.md`

Front-and-center, human- and agent-readable. Holds everything event-specific:

```markdown
# USCC West Coast 2026

- **Slug:** uscc-west-coast-2026
- **Flag format:** `USCC{...}`   (prefix `USCC`)
- **Host:** chals.uscc-west-coast-2026.ctf.institute
- **Categories:** web, crypto, forensics, rev, pwn, misc
- **Status:** ended 2026-07-25 — practice only
- **Scope / policy:** competition over; drive challenges end to end, send traffic
  to hosts directly, stay in scope (this event's challenges only). See RULES.md.
```

The "competition is over → you may drive end to end / send traffic" posture currently
in `CLAUDE.md` moves here (it is event-specific). A template lives at
`templates/CTF.md` with `{{NAME}}`, `{{SLUG}}`, `{{FLAG_PREFIX}}` placeholders and
neutral defaults (status `live`, scope: stay in scope, follow the event's rules).

### 2. Active-CTF pointer: `ctfs/.active`

Single line containing the active event slug. Written by `new-ctf`; read by
`new-challenge`, `update-board`, and the crawler when no event is passed explicitly.
Common case stays a one-liner; multiple concurrent events are supported by overriding.

Resolution order in every tool: explicit `-Ctf <slug>` / `$CTF` env → else read
`ctfs/.active` → else error with a helpful message ("no active CTF; run new-ctf or
pass -Ctf").

### 3. Generic root `CLAUDE.md`

Rewritten to describe the reusable harness, not USCC:
- You are a hands-on CTF solver. Each event lives in `ctfs/<slug>/`; **read the active
  event's `CTF.md` first** for flag format, host, status, and scope.
- What you may do (offline analysis + sending traffic to challenge hosts), stated
  generically, deferring event-specific scope/policy to the event's `CTF.md`/`RULES.md`.
- Working a challenge: `new-ctf` (first time) → `new-challenge <category> <name>` →
  ctf-triage → route to category skill → solve → record flag in `solution.md` →
  `update-board`.
- Burp / MCP notes (unchanged, generic).

### 4. Parameterized skills (`.claude/skills/ctf-*`)

Replace every hardcoded `USCC{` / `grep -i uscc` / `regexPattern="flag|USCC"` with a
reference to the active event's flag prefix, e.g. "the flag format defined in the
active CTF's `ctfs/<active>/CTF.md` (grep for that prefix, e.g. the string before
`{`)." Methodology text is otherwise unchanged. Affected: ctf-triage, ctf-crypto,
ctf-forensics, ctf-rev, ctf-misc (and a scan of ctf-web/ctf-pwn for stray `USCC`).

### 5. Tooling

- **`new-ctf.{ps1,sh}`** `new-ctf "<Event Name>" [--host <h>] [--flag-prefix <P>]`:
  slugify name → create `ctfs/<slug>/{CTF.md,BOARD.md,artifacts/,challenges/}` →
  render `CTF.md` from `templates/CTF.md` → write `ctfs/.active` = slug → print next
  steps. Refuse if the event already exists.
- **`new-challenge.{ps1,sh}`** gains an optional `-Ctf <slug>` (PS) / first-arg-or-`$CTF`
  (sh) override; resolves the active event and creates
  `ctfs/<event>/challenges/<category>/<slug>/`. `solution.md`'s placeholder flag comes
  from the event's flag prefix (falls back to `FLAG{...}`).
- **`update-board.{ps1,sh}`** scans `ctfs/<event>/challenges/**` and writes
  `ctfs/<event>/BOARD.md`. Same regex-from-README logic as today.
- **`crawl-challenges.py`** `--out` default becomes the active event's `challenges/`
  (resolve `ctfs/.active`); `--dump` default follows `--out`. `--out` still overridable.
- `verify-env` / `verify-skills` unchanged.

### 6. Data migration

- `challenges/<cat>/<slug>/` (all 72) → `ctfs/uscc-west-coast-2026/challenges/<cat>/<slug>/`
  (filesystem move; untracked).
- `git mv docs/RULES.md ctfs/uscc-west-coast-2026/RULES.md`.
- `git mv challenges/BOARD.md ctfs/uscc-west-coast-2026/BOARD.md` (then regenerate).
- `git rm challenges/.gitkeep` (dir no longer a top-level fixture).
- `USCC CTF - Western.pdf`, `challenges/ctfd_dump.json`, empty `stub.pHp` →
  `ctfs/uscc-west-coast-2026/artifacts/`.
- `NENRONonline.html` + `NENRONonline_files/` → `challenges/web/nenron/files/`
  (i.e. under the event); `CyberDyne … .html` + `_files/` →
  `challenges/web/cyberdyne/files/`.
- Merge worktree's newer `reblaze` `notes.md` + `scripts/payloads.md` into the event's
  `challenges/web/reblaze/`, then `git worktree remove` / prune and delete
  `.claude/worktrees/reblaze-handoff/`; delete branch `worktree-reblaze-handoff`.
- Create the new `templates/CTF.md`; author `ctfs/uscc-west-coast-2026/CTF.md`.
- `.gitignore`: retarget `challenges/**` ignore rules to `ctfs/**/challenges/**`.

### 7. Rename

- `gh repo rename ctf-workspace` (keeps redirect); `git remote set-url origin
  https://github.com/adostie2020/ctf-workspace.git`.
- Local folder rename is done by the user (it is the session cwd); README notes it.

## Error handling

- Tools that need an event and find no `-Ctf` and no `ctfs/.active` exit non-zero with
  a clear message. `new-ctf` refuses to clobber an existing event. `new-challenge`
  refuses a duplicate challenge (as today). Board/crawler tolerate an event with zero
  challenges (empty table / nothing to write).

## Verification

- `new-ctf "Test Event"` creates the tree + sets `.active`; `new-challenge web foo`
  lands under `ctfs/test-event/challenges/web/foo/`; `update-board` writes that event's
  `BOARD.md`; then remove the throwaway event.
- `update-board` for USCC reproduces a BOARD.md with the same 72 rows at the new path.
- `grep -ri "uscc"` across `CLAUDE.md`, `.claude/skills/`, `tools/`, `templates/`,
  root `README.md` returns nothing (event specifics only under `ctfs/uscc-*/`).
- `.sh` and `.ps1` tool variants stay behavior-equivalent (spot-check both).

## Out of scope (YAGNI)

Machine-readable JSON config, a merged cross-event board, CI, and any change to the
challenge-solving methodology itself. One spec, one implementation plan.
