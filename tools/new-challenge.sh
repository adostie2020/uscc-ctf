#!/usr/bin/env bash
set -euo pipefail
cat_in="${1:-}"; name="${2:-}"
if [[ -z "$cat_in" || -z "$name" ]]; then echo "usage: new-challenge.sh <category> <name>"; exit 1; fi
case "$cat_in" in web|crypto|forensics|rev|pwn|misc) ;; *) echo "bad category: $cat_in"; exit 1;; esac
cat="$(echo "$cat_in" | tr '[:upper:]' '[:lower:]')"
slug="$(echo "$name" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g; s/^-+//; s/-+$//')"
root="$(cd "$(dirname "$0")/.." && pwd)"
dir="$root/challenges/$cat/$slug"
[[ -e "$dir" ]] && { echo "already exists: $dir"; exit 1; }
mkdir -p "$dir/files" "$dir/scripts"; touch "$dir/files/.gitkeep" "$dir/scripts/.gitkeep"
sed -e "s/{{NAME}}/$name/g" -e "s/{{CATEGORY}}/$cat/g" "$root/templates/challenge-README.md" > "$dir/README.md"
cp "$root/templates/notes.md" "$dir/notes.md"
printf '# Solution: %s\n\n## Flag\n\n`USCC{...}`  <!-- paste after you submit -->\n\n## Writeup\n\n- \n' "$name" > "$dir/solution.md"
echo "Created $dir"
