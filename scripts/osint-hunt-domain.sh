#!/data/data/com.termux/files/usr/bin/bash
# osint-hunt-domain.sh — parallel domain / subdomain recon

GRN="\033[0;32m"; CYN="\033[0;36m"; RED="\033[0;31m"; YLW="\033[1;33m"; NC="\033[0m"
OUT="$HOME/osint-results"
mkdir -p "$OUT"

DOMAIN="$1"
[ -z "$DOMAIN" ] && { echo -e "${RED}usage:${NC} osint-hunt-domain <domain>"; exit 1; }

TS=$(date +%Y%m%d-%H%M%S)
WORK="$OUT/domain-$DOMAIN-$TS"
mkdir -p "$WORK"

echo -e "${CYN}╔════════════════════════════════════════════╗${NC}"
echo -e "${CYN}║${NC}  VOID PSN — multi-tool domain recon       ${CYN}║${NC}"
echo -e "${CYN}║${NC}  target: ${YLW}$DOMAIN${NC}"
echo -e "${CYN}║${NC}  output: $WORK"
echo -e "${CYN}╚════════════════════════════════════════════╝${NC}"
echo

run_subfinder() {
  if command -v subfinder >/dev/null 2>&1; then
    echo -e "${CYN}[*]${NC} subfinder..."
    subfinder -d "$DOMAIN" -silent > "$WORK/subfinder.txt" 2> "$WORK/subfinder.log"
    echo -e "${GRN}[✓]${NC} subfinder: $(wc -l < "$WORK/subfinder.txt") subs"
  else
    echo -e "${YLW}[~]${NC} subfinder missing"
  fi
}

run_assetfinder() {
  if command -v assetfinder >/dev/null 2>&1; then
    echo -e "${CYN}[*]${NC} assetfinder..."
    assetfinder "$DOMAIN" > "$WORK/assetfinder.txt" 2> "$WORK/assetfinder.log"
    echo -e "${GRN}[✓]${NC} assetfinder: $(wc -l < "$WORK/assetfinder.txt") subs"
  else
    echo -e "${YLW}[~]${NC} assetfinder missing"
  fi
}

run_crt() {
  # crt.sh — certificate transparency logs, no api key
  echo -e "${CYN}[*]${NC} crt.sh..."
  curl -sS "https://crt.sh/?q=%25.$DOMAIN&output=json" 2>/dev/null \
    | python -c "
import json, sys
try:
    d = json.load(sys.stdin)
    seen = set()
    for e in d:
        for n in e.get('name_value','').split('\n'):
            n = n.strip().lstrip('*.')
            if n and n not in seen:
                seen.add(n)
                print(n)
except: pass
" > "$WORK/crt.txt" 2>/dev/null
  echo -e "${GRN}[✓]${NC} crt.sh: $(wc -l < "$WORK/crt.txt") subs"
}

run_wayback() {
  if command -v waybackurls >/dev/null 2>&1; then
    echo -e "${CYN}[*]${NC} waybackurls..."
    waybackurls "$DOMAIN" > "$WORK/wayback-raw.txt" 2> "$WORK/wayback.log"
    # extract unique subdomains from urls
    grep -oE 'https?://[^/]+' "$WORK/wayback-raw.txt" 2>/dev/null \
      | sed 's|https\?://||' \
      | grep -F ".$DOMAIN" \
      | sort -u > "$WORK/wayback-subs.txt"
    echo -e "${GRN}[✓]${NC} waybackurls: $(wc -l < "$WORK/wayback-subs.txt") subs, $(wc -l < "$WORK/wayback-raw.txt") urls"
  else
    echo -e "${YLW}[~]${NC} waybackurls missing"
  fi
}

run_dnsx() {
  # dnsx resolves the merged subs later — placeholder, just checks binary
  if [ -x "$HOME/go/bin/dnsx" ]; then
    echo -e "${CYN}[*]${NC} dnsx available for resolution"
  fi
}

run_subfinder &
run_assetfinder &
run_crt &
run_wayback &
run_dnsx &
wait

echo
echo -e "${GRN}all tools finished${NC}"
echo -e "${CYN}[*]${NC} merging subdomains..."

# merge all subs into one deduped file
MERGED="$WORK/subs.txt"
> "$MERGED"
for f in subfinder.txt assetfinder.txt crt.txt wayback-subs.txt; do
  [ -f "$WORK/$f" ] && cat "$WORK/$f" >> "$MERGED"
done

# aggressive filter:
#   - must end with .$DOMAIN or equal $DOMAIN
#   - drop obviously bogus: purely numeric labels only, and single-char labels
#   - drop lines with invalid chars
grep -E "^[A-Za-z0-9_.-]+\.${DOMAIN//./\\.}$|^${DOMAIN//./\\.}$" "$MERGED" \
  | grep -vE "^[0-9]+\.${DOMAIN//./\\.}$" \
  | grep -vE "^[0-9-]+\.${DOMAIN//./\\.}$" \
  | sort -u > "$MERGED.tmp"
mv "$MERGED.tmp" "$MERGED"

# sanity check: if count > 5000, warn — likely bogus for a normal domain
RAW=$(wc -l < "$MERGED")
if [ "$RAW" -gt 5000 ]; then
  echo -e "${YLW}[!]${NC} got $RAW subs — likely wildcard DNS noise. showing first 100 only."
  head -100 "$MERGED" > "$MERGED.trimmed"
  mv "$MERGED.trimmed" "$MERGED"
fi
# filter to actual domain matches
grep -E "\.$DOMAIN$|^$DOMAIN$" "$MERGED" | sort -u -o "$MERGED.clean"
mv "$MERGED.clean" "$MERGED"

SUBS=$(wc -l < "$MERGED")
URLS=0
[ -f "$WORK/wayback-raw.txt" ] && URLS=$(wc -l < "$WORK/wayback-raw.txt")

echo
echo -e "${GRN}╔════════════════════════════════════════════╗${NC}"
echo -e "${GRN}║${NC}  ${YLW}$SUBS unique subdomains${NC} for $DOMAIN"
echo -e "${GRN}║${NC}  ${YLW}$URLS historical urls${NC}"
echo -e "${GRN}║${NC}  $MERGED"
echo -e "${GRN}╚════════════════════════════════════════════╝${NC}"
echo

# optional: live check if httpx available
if [ -x "$HOME/go/bin/httpx" ]; then
  echo -e "${CYN}[*]${NC} probing for live hosts with httpx (background)..."
  "$HOME/go/bin/httpx" -silent -l "$MERGED" -o "$WORK/live.txt" >/dev/null 2>&1 &
  HXPID=$!
  sleep 20
  kill $HXPID 2>/dev/null
  if [ -f "$WORK/live.txt" ]; then
    LIVE=$(wc -l < "$WORK/live.txt")
    echo -e "${GRN}[✓]${NC} $LIVE live hosts → $WORK/live.txt"
  fi
else
  echo -e "${YLW}[~]${NC} httpx not installed — skipping live check"
fi

echo
echo -e "${CYN}[*]${NC} first 30 subdomains:"
head -30 "$MERGED"
echo
echo -e "${CYN}[*]${NC} full log dir: $WORK"
