#!/usr/bin/env bash
have(){ command -v "$1" >/dev/null 2>&1; }
row(){ if have "$2"; then echo "[ OK ] $1"; else echo "[MISS] $1  ->  $3"; fi; }
row "Python" python "https://www.python.org/downloads/"
python -c "import pwn" 2>/dev/null && echo "[ OK ] pwntools" || echo "[MISS] pwntools  ->  pip install pwntools"
row "Ghidra (analyzeHeadless)" analyzeHeadless "https://ghidra-sre.org/ (add support/ to PATH)"
row "ROPgadget" ROPgadget "pip install ROPgadget"
row "binwalk" binwalk "pip install binwalk"
row "exiftool" exiftool "https://exiftool.org/"
row "tshark" tshark "https://www.wireshark.org/"
row "foremost" foremost "apt/brew install foremost"
row "file" file "coreutils"
echo ""
echo "GUI/extension tools (Burp+PortSwigger MCP, Ghidra+ReVa): verify via /mcp in Claude Code."
