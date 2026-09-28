#!/data/data/com.termux/files/usr/bin/bash
# osint-hunt.sh — multi-tool username hunt (final)

GRN="\033[0;32m"; CYN="\033[0;36m"; RED="\033[0;31m"; YLW="\033[1;33m"; NC="\033[0m"
OUT="$HOME/osint-results"
mkdir -p "$OUT"

USERNAME="$1"
[ -z "$USERNAME" ] && { echo -e "${RED}usage:${NC} osint-hunt <username>"; exit 1; }

TS=$(date +%Y%m%d-%H%M%S)
WORK="$OUT/hunt-$USERNAME-$TS"
mkdir -p "$WORK"

echo -e "${CYN}╔════════════════════════════════════════════╗${NC}"
echo -e "${CYN}║${NC}  VOID PSN — multi-tool username hunt      ${CYN}║${NC}"
echo -e "${CYN}║${NC}  target: ${YLW}$USERNAME${NC}"
echo -e "${CYN}║${NC}  output: $WORK"
echo -e "${CYN}╚════════════════════════════════════════════╝${NC}"
echo

run_maigret() {
  if command -v maigret >/dev/null 2>&1; then
    echo -e "${CYN}[*]${NC} maigret..."
    maigret "$USERNAME" -fo "$WORK/maigret" --no-color --no-progressbar \
      --no-recursion -H --no-extracting \
      > "$WORK/maigret.log" 2>&1
    echo -e "${GRN}[✓]${NC} maigret done"
  else
    echo -e "${YLW}[~]${NC} maigret not installed — skipping"
  fi
}

run_enola() {
  if [ -x "$HOME/go/bin/enola" ]; then
    echo -e "${CYN}[*]${NC} enola..."
    "$HOME/go/bin/enola" "$USERNAME" > "$WORK/enola.log" 2>&1
    echo -e "${GRN}[✓]${NC} enola done"
  else
    echo -e "${YLW}[~]${NC} enola not installed — skipping"
  fi
}

run_blackbird() {
  if [ -f "$HOME/osint/blackbird/blackbird.py" ]; then
    echo -e "${CYN}[*]${NC} blackbird..."
    cd "$HOME/osint/blackbird"
    python blackbird.py -u "$USERNAME" --json --no-update --no-nsfw \
      > "$WORK/blackbird.log" 2>&1
    # blackbird --json prints to stdout, so grep it out of the log
    python -c "
import re, json, sys
raw = open('$WORK/blackbird.log').read()
# find the json block (starts with { or [)
m = re.search(r'(\{.*\}|\[.*\])', raw, re.S)
if m:
    try:
        d = json.loads(m.group(1))
        items = d.values() if isinstance(d, dict) else d
        out = []
        for v in items:
            if isinstance(v, dict) and v.get('found') is True:
                t = v.get('title') or v.get('site') or v.get('name')
                if t: out.append(t)
        open('$WORK/blackbird.json','w').write(json.dumps(out))
    except: pass
" 2>/dev/null
    echo -e "${GRN}[✓]${NC} blackbird done"
  else
    echo -e "${YLW}[~]${NC} blackbird not found — skipping"
  fi
}

run_socialscan() {
  if command -v socialscan >/dev/null 2>&1; then
    echo -e "${CYN}[*]${NC} socialscan..."
    socialscan "$USERNAME" > "$WORK/socialscan.log" 2>&1
    echo -e "${GRN}[✓]${NC} socialscan done"
  else
    echo -e "${YLW}[~]${NC} socialscan not installed — skipping"
  fi
}

run_maigret &
run_enola &
run_blackbird &
run_socialscan &
wait

echo
echo -e "${GRN}all tools finished${NC}"
echo -e "${CYN}[*]${NC} merging results..."

MERGED="$WORK/MERGED.txt"
> "$MERGED"

# ---------- maigret: parse HTML report for "Found" entries ----------
if [ -d "$WORK/maigret" ]; then
  find "$WORK/maigret" -name "*.html" -exec grep -oE 'title="[^"]+"' {} \; 2>/dev/null \
    | sed 's/title="//; s/"$//' | grep -v "^https\?" >> "$MERGED"
fi

# ---------- enola: "[+] SiteName: url" ----------
if [ -f "$WORK/enola.log" ]; then
  grep "^\[+\]" "$WORK/enola.log" 2>/dev/null \
    | sed 's/^\[+\] //; s/:.*//' >> "$MERGED"
fi

# ---------- blackbird: already extracted to blackbird.json (list) ----------
if [ -f "$WORK/blackbird.json" ]; then
  python -c "
import json
try:
    items = json.load(open('$WORK/blackbird.json'))
    for i in items: print(i)
except: pass
" >> "$MERGED" 2>/dev/null
fi

# ---------- socialscan: lines with target and 'taken' or 'not available' ----------
if [ -f "$WORK/socialscan.log" ]; then
  grep -iE "^\S+\s+(taken|not avail)" "$WORK/socialscan.log" 2>/dev/null \
    | awk '{print $1}' | grep -v "^Available," >> "$MERGED"
fi

# clean: drop empties, drop "Available," junk, dedupe
grep -v '^$' "$MERGED" | grep -v '^Available,' | sort -u -o "$MERGED"

COUNT=$(wc -l < "$MERGED")
echo
echo -e "${GRN}╔════════════════════════════════════════════╗${NC}"
echo -e "${GRN}║${NC}  ${YLW}$COUNT unique sites${NC} found for $USERNAME"
echo -e "${GRN}║${NC}  $MERGED"
echo -e "${GRN}╚════════════════════════════════════════════╝${NC}"
echo
echo -e "${CYN}[*]${NC} first 50 results:"
head -50 "$MERGED"
echo
echo -e "${CYN}[*]${NC} full log dir: $WORK"
