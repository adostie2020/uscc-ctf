#!/usr/bin/env bash
set -euo pipefail
name=""; host="TBD"; prefix="FLAG"
usage() { echo 'usage: new-ctf.sh "<Event Name>" [--host <h>] [--flag-prefix <P>]'; }
while [[ $# -gt 0 ]]; do
  case "$1" in
    --host) host="${2:-}"; shift 2;;
    --flag-prefix) prefix="${2:-}"; shift 2;;
    -h|--help) usage; exit 0;;
    *) if [[ -z "$name" ]]; then name="$1"; shift; else echo "unexpected arg: $1"; usage; exit 1; fi;;
  esac
done
[[ -n "$name" ]] || { usage; exit 1; }
slug="$(echo "$name" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g; s/^-+//; s/-+$//')"
[[ -n "$slug" ]] || { echo "name has no usable characters"; exit 1; }
root="$(cd "$(dirname "$0")/.." && pwd)"
dir="$root/ctfs/$slug"
[[ -e "$dir" ]] && { echo "CTF already exists: $dir"; exit 1; }
mkdir -p "$dir/challenges" "$dir/artifacts"
touch "$dir/challenges/.gitkeep" "$dir/artifacts/.gitkeep"
tpl="$(cat "$root/templates/CTF.md")"
tpl="${tpl//'{{NAME}}'/"$name"}"
tpl="${tpl//'{{SLUG}}'/"$slug"}"
tpl="${tpl//'{{FLAG_PREFIX}}'/"$prefix"}"
tpl="${tpl//'{{HOST}}'/"$host"}"
printf '%s' "$tpl" > "$dir/CTF.md"
printf '%s\n' "$slug" > "$root/ctfs/.active"
echo "Created $dir and set active CTF -> $slug"
echo 'Next: tools/new-challenge.sh <category> "<name>"'
