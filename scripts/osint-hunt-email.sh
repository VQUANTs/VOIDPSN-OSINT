#!/data/data/com.termux/files/usr/bin/bash
# osint-hunt-email.sh — parallel email intelligence

GRN="\033[0;32m"; CYN="\033[0;36m"; RED="\033[0;31m"; YLW="\033[1;33m"; NC="\033[0m"
OUT="$HOME/osint-results"
mkdir -p "$OUT"

EMAIL="$1"
[ -z "$EMAIL" ] && { echo -e "${RED}usage:${NC} osint-hunt-email <email>"; exit 1; }

TS=$(date +%Y%m%d-%H%M%S)
WORK="$OUT/email-$EMAIL-$TS"
mkdir -p "$WORK"

echo -e "${CYN}╔════════════════════════════════════════════╗${NC}"
echo -e "${CYN}║${NC}  VOID PSN — multi-tool email hunt         ${CYN}║${NC}"
echo -e "${CYN}║${NC}  target: ${YLW}$EMAIL${NC}"
echo -e "${CYN}║${NC}  output: $WORK"
echo -e "${CYN}╚════════════════════════════════════════════╝${NC}"
echo

run_holehe() {
  if command -v holehe >/dev/null 2>&1; then
    echo -e "${CYN}[*]${NC} holehe..."
    holehe "$EMAIL" --no-color > "$WORK/holehe.log" 2>&1
    echo -e "${GRN}[✓]${NC} holehe done"
  fi
}

run_socialscan() {
  if command -v socialscan >/dev/null 2>&1; then
    echo -e "${CYN}[*]${NC} socialscan..."
    socialscan "$EMAIL" > "$WORK/socialscan.log" 2>&1
    echo -e "${GRN}[✓]${NC} socialscan done"
  fi
}

run_h8mail() {
  if command -v h8mail >/dev/null 2>&1; then
    echo -e "${CYN}[*]${NC} h8mail..."
    h8mail -t "$EMAIL" > "$WORK/h8mail.log" 2>&1
    echo -e "${GRN}[✓]${NC} h8mail done"
  fi
}

run_emailrep() {
  if command -v emailrep >/dev/null 2>&1; then
    echo -e "${CYN}[*]${NC} emailrep..."
    emailrep "$EMAIL" > "$WORK/emailrep.log" 2>&1
    echo -e "${GRN}[✓]${NC} emailrep done"
  fi
}

run_holehe &
run_socialscan &
run_h8mail &
run_emailrep &
wait

echo
echo -e "${GRN}all tools finished${NC}"
echo -e "${CYN}[*]${NC} merging results..."

MERGED="$WORK/MERGED.txt"
> "$MERGED"

# ---------- holehe ----------
if [ -f "$WORK/holehe.log" ]; then
  grep "^\[+\]" "$WORK/holehe.log" 2>/dev/null \
    | sed 's/^\[+\] //' \
    | grep -vE "^(Available,|Email used,|\[-\]|\[x\]|Email not)" \
    | awk '{print $1}' >> "$MERGED"
fi

# ---------- socialscan ----------
if [ -f "$WORK/socialscan.log" ]; then
  grep -iE "taken|not avail" "$WORK/socialscan.log" 2>/dev/null \
    | awk '{print $1}' \
    | grep -vE "^(Available,|Email|\[)" >> "$MERGED"
fi

# ---------- h8mail: breach intel to separate file ----------
if [ -f "$WORK/h8mail.log" ]; then
  grep -iE "breach|found|pwned|password" "$WORK/h8mail.log" 2>/dev/null \
    | grep -vE "^\[~\]|^\[>\] h8mail" >> "$MERGED.breaches"
fi

# ---------- emailrep ----------
if [ -f "$WORK/emailrep.log" ]; then
  grep -iE "reputation|breach|profiles|suspicious|blacklisted" "$WORK/emailrep.log" 2>/dev/null \
    >> "$MERGED.reputation"
fi

grep -v '^$' "$MERGED" | grep -v '^Available,$' | sort -u -o "$MERGED"
COUNT=$(wc -l < "$MERGED")

echo
echo -e "${GRN}╔════════════════════════════════════════════╗${NC}"
echo -e "${GRN}║${NC}  ${YLW}$COUNT services${NC} registered for $EMAIL"
echo -e "${GRN}║${NC}  $MERGED"
echo -e "${GRN}╚════════════════════════════════════════════╝${NC}"
echo
echo -e "${CYN}[*]${NC} registered services:"
cat "$MERGED"
echo
if [ -f "$MERGED.breaches" ] && [ -s "$MERGED.breaches" ]; then
  echo -e "${RED}[!]${NC} breach intel:"
  cat "$MERGED.breaches"
  echo
fi
if [ -f "$MERGED.reputation" ] && [ -s "$MERGED.reputation" ]; then
  echo -e "${CYN}[*]${NC} reputation:"
  cat "$MERGED.reputation"
  echo
fi
echo -e "${CYN}[*]${NC} full log dir: $WORK"
