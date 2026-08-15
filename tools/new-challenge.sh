#!/usr/bin/env bash
set -euo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"

# resolve active CTF: $CTF -> ctfs/.active
ctf="${CTF:-}"
if [[ -z "$ctf" && -f "$root/ctfs/.active" ]]; then
  ctf="$(head -n1 "$root/ctfs/.active" | tr -d '\r\n')"
fi
[[ -n "$ctf" ]] || { echo "no active CTF: run tools/new-ctf.sh or set \$CTF=<slug>"; exit 1; }
ctfdir="$root/ctfs/$ctf"
[[ -d "$ctfdir" ]] || { echo "CTF not found: $ctfdir"; exit 1; }

cat_in="${1:-}"; name="${2:-}"
if [[ -z "$cat_in" || -z "$name" ]]; then echo "usage: [CTF=<slug>] new-challenge.sh <category> <name>"; exit 1; fi
cat="$(echo "$cat_in" | tr '[:upper:]' '[:lower:]')"
case "$cat" in web|crypto|forensics|rev|pwn|misc) ;; *) echo "bad category: $cat_in"; exit 1;; esac
slug="$(echo "$name" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g; s/^-+//; s/-+$//')"
dir="$ctfdir/challenges/$cat/$slug"
[[ -e "$dir" ]] && { echo "already exists: $dir"; exit 1; }

# flag prefix from CTF.md (default FLAG)
prefix="FLAG"
line="$(grep -m1 -iE '\*\*Flag format:\*\*' "$ctfdir/CTF.md" 2>/dev/null || true)"
if [[ -n "$line" ]]; then
  p="$(printf '%s' "$line" | sed -nE 's/[^`]*`([^`]*)`.*/\1/p')"
  p="${p%%\{*}"; p="${p// /}"
  [[ -n "$p" ]] && prefix="$p"
fi

mkdir -p "$dir/files" "$dir/scripts"; touch "$dir/files/.gitkeep" "$dir/scripts/.gitkeep"
IFS= read -r -d '' tpl < "$root/templates/challenge-README.md" || true
tpl="${tpl//'{{NAME}}'/"$name"}"
tpl="${tpl//'{{CATEGORY}}'/"$cat"}"
printf '%s' "$tpl" > "$dir/README.md"
cp "$root/templates/notes.md" "$dir/notes.md"
printf '# Solution: %s\n\n## Flag\n\n`%s{...}`  <!-- paste after you submit -->\n\n## Writeup\n\n- \n' "$name" "$prefix" > "$dir/solution.md"
echo "Created $dir"
