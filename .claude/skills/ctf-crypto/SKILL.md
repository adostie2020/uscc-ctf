---
name: ctf-crypto
description: Solve CTF cryptography challenges by identifying the scheme and writing offline decryption/attack scripts. Use for classical ciphers, encodings, XOR, RSA, AES modes, hashing, and other crypto puzzles. Analysis and scripts run locally on provided ciphertext.
---

# CTF Crypto

You identify the scheme and write **offline** scripts that run on the provided
ciphertext/keys in `files/`. If a challenge exposes a network oracle, the **human**
interacts with it — you write the client script as a `▶ RUN THIS YOURSELF` handoff.

## First question: ancient or modern?
- **Classical / encoding** (no keys, human-readable structure): Caesar/ROT, Vigenère,
  substitution, Atbash, rail fence, base16/32/64/85, Morse, hex, URL, XOR-with-short-key.
  Tools: CyberChef (human), `python`, frequency analysis. Try `USCC{` as known plaintext.
- **Modern** (named primitive + key material): RSA, AES, ECC, DH, hashes.

## Modern playbook
- **RSA:** inspect `n, e, c`. Attacks by weakness:
  - small `e` + no padding → e-th root; `e=1`; small message.
  - `n` factorable (small, or via factordb / Fermat when p≈q) → recover `d`.
  - shared modulus, common modulus, Håstad broadcast, Wiener (small `d`), partial-key.
  - Use `pycryptodome`, `sympy`, `gmpy2`.
- **AES:** identify mode. ECB → detect repeated 16-byte blocks (cut-and-paste, ECB oracle
  patterns you script). CBC → bit-flipping, padding-oracle (if the oracle is remote, the
  human runs your client script). CTR/nonce reuse → keystream reuse.
- **XOR:** single-byte (brute 0–255, score by frequency), repeating-key (find keysize via
  Hamming distance, then per-column single-byte), crib-dragging with `USCC{`.
- **Hashes:** identify; crack offline with a wordlist if intended; length-extension
  (`hashpump`) for MAC bypass.

## Workflow
1. Identify inputs in `files/` (ciphertext, `n/e/c`, key, params) and the exact goal.
2. Name the scheme + the specific weakness. Record it in `notes.md`.
3. Write a self-contained solver into `scripts/solve.py` (offline). Run it yourself if it
   only touches local files; if it needs the remote oracle, mark it `▶ RUN THIS YOURSELF`.
4. Recover plaintext → confirm `USCC{...}` → put the flag in `solution.md` for the human.

## Guardrails
- Offline math/scripts on provided data are fine. Any oracle interaction over the network
  is a human handoff. No brute-forcing a remote endpoint.
