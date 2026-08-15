#!/usr/bin/env python3
"""Crawl a CTFd site and save every challenge locally for later work.

Reads the active event from ctfs/.active (or use --out/--base to target another).
Authenticates to the CTFd JSON API, walks /api/v1/challenges, pulls full details
for each one, downloads all attached files, and writes everything into the event's
usual challenges/<category>/<slug>/ layout so the category skills can pick them up.

Auth (pick one):
  --token / $CTFD_TOKEN         CTFd access token -> "Authorization: Token ..."
  --user/--password (or $CTFD_USER/$CTFD_PASSWORD)  username/email + password
  --cookie / $CTFD_SESSION      value of an existing `session=...` cookie

Base URL resolution: --base > $CTFD_BASE > the active event's CTF.md `Host` field.
Output root resolution: --out > the active event's ctfs/<slug>/challenges.

By default it NEVER overwrites existing files (so solved challenges stay intact);
pass --force to refresh README/meta.
"""
from __future__ import annotations

import argparse
import json
import os
import re
import sys
import time
from pathlib import Path
from urllib.parse import urljoin, urlparse, unquote

try:
    import requests
except ImportError:
    sys.exit("This script needs `requests`:  python -m pip install requests")

UA = "ctf-workspace-crawler/1.0 (+practice)"


def repo_root() -> Path:
    return Path(__file__).resolve().parent.parent


def active_slug() -> "str | None":
    f = repo_root() / "ctfs" / ".active"
    if f.exists():
        s = f.read_text(encoding="utf-8").strip()
        return s or None
    return None


def ctf_field(slug: str, label: str) -> "str | None":
    """Read a `- **<label>:** value` line from ctfs/<slug>/CTF.md (backticks optional)."""
    ctf = repo_root() / "ctfs" / slug / "CTF.md"
    if not ctf.exists():
        return None
    pat = re.compile(r"\*\*" + re.escape(label) + r":\*\*\s*`?([^`\n]+?)`?\s*$")
    for line in ctf.read_text(encoding="utf-8").splitlines():
        m = pat.search(line)
        if m:
            return m.group(1).strip()
    return None

# Windows consoles default to cp1252, which chokes on emoji in challenge names.
for _stream in (sys.stdout, sys.stderr):
    try:
        _stream.reconfigure(encoding="utf-8", errors="replace")
    except (AttributeError, ValueError):
        pass


def log(msg: str) -> None:
    print(msg, flush=True)


def slugify(name: str) -> str:
    """Filesystem-safe, matches the lowercase-hyphen style used in the repo.

    Returns "" for names with no word characters (e.g. emoji-only titles) so
    callers can substitute a stable, unique fallback (the challenge id).
    """
    s = (name or "").strip().lower()
    s = re.sub(r"[^\w\s-]", "", s)      # drop punctuation/emoji
    s = re.sub(r"[\s_]+", "-", s)       # spaces/underscores -> hyphen
    s = re.sub(r"-+", "-", s).strip("-")
    return s


def safe_filename(name: str) -> str:
    name = unquote(name).split("?")[0]
    name = os.path.basename(name)
    name = re.sub(r'[<>:"/\\|?*\x00-\x1f]', "_", name)
    return name or "file"


class CTFdClient:
    def __init__(self, base: str, timeout: int = 30):
        self.base = base.rstrip("/")
        self.timeout = timeout
        self.s = requests.Session()
        self.s.headers["User-Agent"] = UA

    def _url(self, path: str) -> str:
        return urljoin(self.base + "/", path.lstrip("/"))

    def _nonce(self, path: str) -> str:
        """Scrape the CSRF nonce CTFd embeds in `window.init` / a hidden field."""
        r = self.s.get(self._url(path), timeout=self.timeout)
        r.raise_for_status()
        m = re.search(r"'csrfNonce'\s*:\s*\"([0-9a-f]+)\"", r.text) or re.search(
            r'name="nonce"[^>]*value="([0-9a-f]+)"', r.text
        )
        if not m:
            raise RuntimeError("could not find CSRF nonce on " + path)
        return m.group(1)

    # --- auth ---------------------------------------------------------------
    def auth_token(self, token: str) -> None:
        self.s.headers["Authorization"] = f"Token {token}"

    def auth_cookie(self, session_cookie: str) -> None:
        host = urlparse(self.base).hostname
        self.s.cookies.set("session", session_cookie, domain=host)

    def auth_login(self, name: str, password: str) -> None:
        nonce = self._nonce("/login")
        r = self.s.post(
            self._url("/login"),
            data={"name": name, "password": password, "nonce": nonce, "_submit": "Submit"},
            timeout=self.timeout,
            allow_redirects=True,
        )
        r.raise_for_status()
        if "/login" in r.url or "incorrect" in r.text.lower() or "your username or password" in r.text.lower():
            raise RuntimeError("login failed — check --user/--password")

    def verify(self) -> None:
        """Fail early with a clear message if we're not actually authenticated."""
        r = self.s.get(self._url("/api/v1/challenges"), timeout=self.timeout,
                       headers={"Accept": "application/json"}, allow_redirects=False)
        if r.status_code in (301, 302) or "login" in r.headers.get("Location", ""):
            raise RuntimeError("not authenticated (API redirected to /login). Provide valid creds/token.")
        if r.status_code == 403:
            raise RuntimeError("403 from API — token/session lacks access, or challenges are hidden.")
        r.raise_for_status()

    # --- api ----------------------------------------------------------------
    def _get_json(self, path: str) -> dict:
        r = self.s.get(self._url(path), timeout=self.timeout,
                       headers={"Accept": "application/json"})
        r.raise_for_status()
        return r.json()

    def list_challenges(self) -> list[dict]:
        data = self._get_json("/api/v1/challenges")
        if not data.get("success"):
            raise RuntimeError(f"/api/v1/challenges returned success=false: {data}")
        return data.get("data", [])

    def challenge_detail(self, cid: int) -> dict:
        data = self._get_json(f"/api/v1/challenges/{cid}")
        return data.get("data", {})

    def download(self, file_ref: str, dest: Path) -> bool:
        url = file_ref if file_ref.startswith("http") else self._url(file_ref)
        with self.s.get(url, stream=True, timeout=self.timeout) as r:
            if r.status_code != 200:
                log(f"      ! file HTTP {r.status_code}: {url}")
                return False
            dest.parent.mkdir(parents=True, exist_ok=True)
            with open(dest, "wb") as fh:
                for chunk in r.iter_content(65536):
                    fh.write(chunk)
        return True


def render_readme(d: dict, base: str) -> str:
    tags = [t.get("value", t) if isinstance(t, dict) else t for t in d.get("tags", [])]
    conn = d.get("connection_info")
    lines = [
        f"# {d.get('name', 'Unknown')}",
        "",
        f"- **Category:** {d.get('category', '?')}",
        f"- **Points:** {d.get('value', '?')}",
        f"- **Solves:** {d.get('solves', '?')}",
        f"- **State:** {d.get('state', '?')}",
    ]
    if tags:
        lines.append(f"- **Tags:** {', '.join(str(t) for t in tags)}")
    if conn:
        lines.append(f"- **Connection info:** `{conn}`")
    lines += ["", "## Description", "", (d.get("description") or "").strip() or "_(none)_", ""]

    files = d.get("files") or []
    if files:
        lines.append("## Files")
        lines.append("")
        for f in files:
            lines.append(f"- `files/{safe_filename(f)}`  (from {f.split('?')[0]})")
        lines.append("")

    hints = d.get("hints") or []
    if hints:
        lines.append("## Hints")
        lines.append("")
        for h in hints:
            cost = h.get("cost", 0) if isinstance(h, dict) else 0
            content = h.get("content") if isinstance(h, dict) else None
            if content:
                lines.append(f"- (cost {cost}) {content}")
            else:
                lines.append(f"- locked hint (cost {cost}, id {h.get('id') if isinstance(h, dict) else h})")
        lines.append("")

    lines.append(f"_Snapshot from {base} — id {d.get('id')}._")
    return "\n".join(lines) + "\n"


def write_challenge(client: CTFdClient, d: dict, out_root: Path, base: str,
                    force: bool, do_files: bool, used: set[tuple[str, str]]) -> str:
    cid = d.get("id")
    category = slugify(d.get("category")) or "misc"
    slug = slugify(d.get("name")) or f"challenge-{cid}"
    # Guarantee a unique folder even if two names slugify identically.
    if (category, slug) in used:
        slug = f"{slug}-{cid}"
    used.add((category, slug))
    folder = out_root / category / slug
    folder.mkdir(parents=True, exist_ok=True)

    # raw metadata is always refreshed (it's a crawl artifact, not hand-edited)
    (folder / "meta.json").write_text(json.dumps(d, indent=2, ensure_ascii=False), encoding="utf-8")

    readme = folder / "README.md"
    existed = readme.exists()
    if force or not existed:
        readme.write_text(render_readme(d, base), encoding="utf-8")
        status = "updated" if existed else "wrote"
    else:
        status = "kept"

    if do_files:
        for ref in d.get("files") or []:
            dest = folder / "files" / safe_filename(ref)
            if dest.exists() and not force:
                continue
            if client.download(ref, dest):
                log(f"      + files/{dest.name}")

    return status


def main() -> int:
    ap = argparse.ArgumentParser(description="Crawl a CTFd site and save all challenges.")
    slug = active_slug()
    default_base = os.environ.get("CTFD_BASE")
    if not default_base and slug:
        host = ctf_field(slug, "Host")
        if host and host != "TBD":
            default_base = host if "://" in host else "https://" + host
    ap.add_argument("--base", default=default_base,
                    help="CTFd base URL (default: $CTFD_BASE or the active CTF.md Host)")
    ap.add_argument("--out", default=None,
                    help="output root, uses <category>/<slug> underneath "
                         "(default: the active event's ctfs/<slug>/challenges)")
    ap.add_argument("--token", default=os.environ.get("CTFD_TOKEN"), help="CTFd access token")
    ap.add_argument("--user", default=os.environ.get("CTFD_USER"), help="username or email")
    ap.add_argument("--password", default=os.environ.get("CTFD_PASSWORD"), help="password")
    ap.add_argument("--cookie", default=os.environ.get("CTFD_SESSION"), help="existing session cookie value")
    ap.add_argument("--delay", type=float, default=0.4, help="seconds between requests (politeness)")
    ap.add_argument("--force", action="store_true", help="overwrite existing README/files")
    ap.add_argument("--no-files", action="store_true", help="skip downloading attachments")
    ap.add_argument("--list-only", action="store_true", help="only dump JSON, don't create folders")
    ap.add_argument("--dump", default=None, help="path for the full JSON dump (default <out>/ctfd_dump.json)")
    args = ap.parse_args()

    if not args.base:
        ap.error("no CTFd base URL: pass --base, set $CTFD_BASE, or add a Host to the active CTF.md")
    if args.out:
        out_root = Path(args.out)
    elif slug:
        out_root = repo_root() / "ctfs" / slug / "challenges"
    else:
        ap.error("no --out and no active CTF (ctfs/.active); pass --out or run tools/new-ctf")

    client = CTFdClient(args.base)
    if args.token:
        client.auth_token(args.token); how = "token"
    elif args.cookie:
        client.auth_cookie(args.cookie); how = "session cookie"
    elif args.user and args.password:
        client.auth_login(args.user, args.password); how = f"login ({args.user})"
    else:
        ap.error("no credentials: pass --token, --cookie, or --user/--password "
                 "(or set CTFD_TOKEN / CTFD_SESSION / CTFD_USER+CTFD_PASSWORD)")

    log(f"[*] {args.base} — authenticating via {how}")
    try:
        client.verify()
    except Exception as e:
        log(f"[!] auth check failed: {e}")
        return 2
    log("[*] authenticated OK")

    log("[*] fetching challenge list ...")
    listing = client.list_challenges()
    log(f"[*] {len(listing)} challenges listed")

    out_root.mkdir(parents=True, exist_ok=True)

    full = []
    counts = {"wrote": 0, "updated": 0, "kept": 0}
    used: set[tuple[str, str]] = set()
    for i, item in enumerate(sorted(listing, key=lambda c: (c.get("category", ""), c.get("value", 0))), 1):
        cid = item.get("id")
        name = item.get("name", "?")
        cat = item.get("category", "?")
        log(f"  [{i}/{len(listing)}] {cat} / {name} (id {cid})")
        try:
            detail = client.challenge_detail(cid)
        except Exception as e:
            log(f"      ! detail fetch failed: {e}; using list entry")
            detail = item
        full.append(detail)

        if not args.list_only:
            status = write_challenge(client, detail, out_root, args.base,
                                     args.force, not args.no_files, used)
            counts[status] = counts.get(status, 0) + 1
        time.sleep(args.delay)

    dump_path = Path(args.dump) if args.dump else out_root / "ctfd_dump.json"
    dump_path.parent.mkdir(parents=True, exist_ok=True)
    dump_path.write_text(json.dumps(full, indent=2, ensure_ascii=False), encoding="utf-8")
    log(f"[*] full JSON dump -> {dump_path}")

    if not args.list_only:
        log(f"[*] done — new: {counts['wrote']}, refreshed: {counts['updated']}, "
            f"left intact: {counts['kept']}")
        log(f"[*] folders under {out_root}/<category>/<slug>/ (README.md, meta.json, files/)")
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except KeyboardInterrupt:
        sys.exit(130)
