---
name: ctf-rev
description: Solve CTF reverse-engineering challenges by statically analyzing a binary to recover a flag or defeat a check. Use for crackmes, keygens, license/flag checks, obfuscated logic, and "understand this program" tasks (as opposed to memory-corruption pwn). Uses Ghidra/ReVa on the local binary.
---

# CTF Reverse Engineering

You statically analyze the binary in `files/` to recover the flag or the input that
satisfies a check. Sibling to `ctf-pwn` (which is about crashing/hijacking); here the goal
is to **understand**. All analysis is offline via **Ghidra/ReVa** (`reva` MCP) and CLI.

## Recon
- `file`, `checksec` (or note NX/PIE/canary/RELRO), `strings -n 6 | grep -i <prefix>` (flag prefix from `ctfs/<active>/CTF.md`),
  packer check (UPX? `upx -d` a copy), architecture, language (C/C++/Go/Rust/.NET/Python).
- Load into Ghidra via ReVa: `get-current-program`, `get-memory-blocks`, `get-functions`,
  `get-symbols includeExternal=true`, `get-strings regexPattern="flag|<PREFIX>"` (flag prefix from `ctfs/<active>/CTF.md`).

## Analyze
1. Find `main`/entry: `get-decompilation functionNameOrAddress="main"`.
2. Locate the **check**: where input is compared to a target (strcmp/memcmp, a loop over
   chars, a hash/checksum, a state machine/VM).
3. Recover the algorithm. Common patterns:
   - Flag XORed/added with a constant or key → invert it.
   - Char-by-char comparison against a table → read the table.
   - Transformation then compare to embedded bytes → run the inverse.
   - Hash/checksum equality → find preimage (small space) or intended input.
   - Bytecode/VM interpreter → recover the opcode table, then the program.
4. Clarify as you go with ReVa: `rename-variables`, `change-variable-datatypes`,
   `set-decompilation-comment`, `set-bookmark`, `find-cross-references`.

## Produce the answer
- Write the recovery/keygen in `scripts/solve.py` (pure computation) and run it to print
  the flag/key.
- If the flag only appears by **running** the input against a remote service, run your
  client against it yourself.
- Dynamic confirmation (gdb/ltrace/running the binary) is fair game — do it in a scratch
  dir, mindful that the binary is untrusted.

## Guardrails
- Static analysis and offline computation only for the agent. Executing the target binary
  or hitting a remote service is a human handoff. Recovered flag → `solution.md`.
