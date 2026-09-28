# VOIDPSN-OSINT

Termux-native multi-tool OSINT arsenal. No proot, no root, no venv hell.

## tools

**username hunters** (run in parallel via `scripts/osint-hunt.sh`)
- `maigret` — 6200+ sites
- `enola` — 400+ sites, go binary, no python
- `blackbird` — 600+ sites
- `socialscan` — username/email availability
- `sherlock` — 300+ sites

**email intelligence**
- `holehe` — email → registered services

**domain / subdomain**
- `subfinder` — passive subdomain enum
- `assetfinder` — subdomain discovery
- `waybackurls` — historical urls
- `anew` — dedupe helper

**instagram**
- `toutatis` — profile intel
- `instaloader` — profile scraper

## install

```bash
git clone https://github.com/VQUANTs/VOIDPSN-OSINT.git
cd VOIDPSN-OSINT
