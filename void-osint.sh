#!/data/data/com.termux/files/usr/bin/bash
# void-osint.sh — VOID PSN OSINT launcher

GRN="\033[0;32m"; YLW="\033[1;33m"; RED="\033[0;31m"; CYN="\033[0;36m"; BLU="\033[0;34m"; NC="\033[0m"
OSINT_DIR="$HOME/osint"
mkdir -p "$HOME/osint-results"

pause() { echo; read -rp "  press enter to return..." _; }
have()  { command -v "$1" >/dev/null 2>&1; }
go_have() { [ -x "$HOME/go/bin/$1" ]; }

banner() {
  clear
  echo -e "${CYN}"
  cat << 'EOF'
⠙⣦⣄                  ⢀⣶⡄                  ⣀⣴⠏
 ⠈⠻⣿⣦⣄              ⢠⣿⣿⣿⣆              ⣠⣴⣾⠟⠁
   ⠈⠻⣿⣿⣦⣄          ⢠⣿⡿⠁⣿⣿⣦⡀         ⣠⣴⣿⣿⠟⠁
     ⠈⢻⣿⣿⣿⣦⣄⡀     ⠐⣿⣿⡇ ⢸⣿⣿⠁     ⢀⣠⣴⣿⣿⣿⣟⠉
      ⠘⢿⣿⣿⣿⣿⣿⣶⣦⡄   ⣿⣿⡅ ⢀⣿⣿   ⢠⣶⣾⣿⣿⣿⣿⣿⡿⠋
        ⠙⢿⣿⣿⣿⣿⣿⣿⣦⡀ ⠸⣿⣧ ⣸⣿⠇ ⢀⣴⣿⣿⣿⣿⣿⣿⡿⠋
          ⠉⠻⣿⣿⣿⣿⣿⣿⣦⡀⠙⢿⣷⣿⠋ ⣠⣾⣿⣿⣿⣿⣿⠟⠉
           ⡀⠈⠙⠙⠿⣿⣿⣿⣷⣄⠈⠿⠃⣠⣾⣿⣿⣿⠿⠋⠋⠁⢀
           ⣿⣶⣦⣤⣀⠈⠻⣿⣿⣿⣧ ⣴⣿⣿⡿⠟⠁⣀⣤⣴⣾⣿
           ⣿⣿⣿⣿⣿⣿⣦⡈⠻⣿⣿⣿⣷⣿⣿⠟⢀⣴⣿⣿⣿⣿⣿⣿
           ⢿⣿⡟⠻⠷⣬⠙⠻⢦⠘⣿⣿⣿⠃⡴⠟⢛⣵⡾⠟⢻⣿⡿
           ⠘⣿⡇       ⠘⣿⠇       ⢸⣿⠇
            ⠘⣿        ⠉        ⣿⠏
             ⠘⡇               ⢰⠏
EOF
  echo -e "${CYN}"
  cat << 'EOF'
 __     __ ___  ___  ____    ____  ____  _   _
 \ \   / // _ \|_ _||  _ \  |  _ \/ ___|| \ | |
  \ \ / /| | | || | | | | | | |_) \___ \|  \| |
   \ V / | |_| || | | |_| | |  __/ ___) | |\  |
    \_/   \___/|___||____/  |_|   |____/|_| \_|
EOF
  echo -e "${NC}"
  echo -e "${RED}              =====================================${NC}"
  echo -e "${RED}              |          W  E  L  C  O  M  E       |${NC}"
  echo -e "${RED}              =====================================${NC}"
  echo -e "${CYN}              ====== [ Coded by VOID PSN ] ======${NC}"
  echo -e "${YLW}              [ $(date) ]${NC}"
  echo
  echo -e "${BLU}=====================================================${NC}"
  echo -e "  ${GRN}VOID PSN${NC} — OSINT ARSENAL"
  echo -e "${BLU}=====================================================${NC}"
}

menu() {
  banner
  echo -e "  ${CYN}[1]${NC}  username hunt       (multi-tool, parallel)"
  echo -e "  ${CYN}[2]${NC}  email intelligence  (multi-tool, parallel)"
  echo -e "  ${CYN}[3]${NC}  domain recon        (multi-tool, parallel)"
  echo -e "  ${CYN}[4]${NC}  instagram intel     (toutatis / instaloader)"
  echo -e "  ${CYN}[5]${NC}  full recon chain    (subs → dedupe → urls)"
  echo -e "  ${CYN}[6]${NC}  results viewer"
  echo -e "  ${CYN}[7]${NC}  tool status"
  echo -e "  ${CYN}[0]${NC}  exit"
  echo
  echo -e "${BLU}=====================================================${NC}"
}

ask() { read -rp "  $1: " REPLY; echo "$REPLY"; }

username_menu() {
  banner
  echo -e "  ${CYN}[1]${NC} multi-tool hunt (maigret + enola + blackbird + socialscan)"
  echo -e "  ${CYN}[2]${NC} sherlock only"
  echo -e "  ${CYN}[3]${NC} maigret only"
  echo -e "  ${CYN}[4]${NC} blackbird only"
  echo -e "  ${CYN}[5]${NC} enola only"
  echo -e "  ${CYN}[0]${NC} back"
  read -rp "  > " c
  case "$c" in
    1) u=$(ask "username"); [ -n "$u" ] && ~/osint-hunt.sh "$u"; pause ;;
    2) u=$(ask "username"); [ -n "$u" ] && sherlock "$u" --print-found --no-color; pause ;;
    3) u=$(ask "username"); [ -n "$u" ] && maigret "$u" --no-color --no-progressbar -fo "$HOME/osint-results/maigret-$u"; pause ;;
    4) u=$(ask "username"); [ -n "$u" ] && cd "$HOME/osint/blackbird" && python blackbird.py -u "$u" --json --no-update --no-nsfw; pause ;;
    5) u=$(ask "username"); [ -n "$u" ] && "$HOME/go/bin/enola" "$u"; pause ;;
  esac
}

email_menu() {
  banner
  echo -e "  ${CYN}[1]${NC} multi-tool hunt  (holehe + socialscan + h8mail + emailrep)"
  echo -e "  ${CYN}[2]${NC} holehe only"
  echo -e "  ${CYN}[3]${NC} socialscan only"
  echo -e "  ${CYN}[0]${NC} back"
  read -rp "  > " c
  case "$c" in
    1) e=$(ask "email"); [ -n "$e" ] && ~/osint-hunt-email.sh "$e"; pause ;;
    2) e=$(ask "email"); [ -n "$e" ] && holehe "$e" | tee "$HOME/osint-results/holehe-$(echo "$e" | tr '@.' '__').txt"; pause ;;
    3) e=$(ask "email"); [ -n "$e" ] && socialscan "$e"; pause ;;
  esac
}

domain_menu() {
  banner
  echo -e "  ${CYN}[1]${NC} multi-tool hunt  (subfinder + assetfinder + crt.sh + wayback)"
  echo -e "  ${CYN}[2]${NC} subfinder only"
  echo -e "  ${CYN}[3]${NC} assetfinder only"
  echo -e "  ${CYN}[0]${NC} back"
  read -rp "  > " c
  case "$c" in
    1) d=$(ask "domain"); [ -n "$d" ] && ~/osint-hunt-domain.sh "$d"; pause ;;
    2) d=$(ask "domain"); [ -n "$d" ] && subfinder -d "$d" -silent | tee "$HOME/osint-results/subs-$d.txt"; pause ;;
    3) d=$(ask "domain"); [ -n "$d" ] && assetfinder "$d" | tee "$HOME/osint-results/asset-$d.txt"; pause ;;
  esac
}

insta_menu() {
  banner
  echo -e "  ${CYN}[1]${NC} toutatis       (profile info)"
  echo -e "  ${CYN}[2]${NC} instaloader    (download profile)"
  echo -e "  ${CYN}[0]${NC} back"
  read -rp "  > " c
  case "$c" in
    1) u=$(ask "instagram username"); [ -n "$u" ] && toutatis -u "$u" -s; pause ;;
    2) u=$(ask "instagram username"); [ -n "$u" ] && instaloader --no-videos --no-captions "$u"; pause ;;
  esac
}

full_recon() {
  banner
  d=$(ask "target domain")
  [ -z "$d" ] && return
  out="$HOME/osint-results"
  echo -e "${CYN}[*]${NC} subfinder..."
  subfinder -d "$d" -silent > "$out/$d-subs.txt"
  echo -e "${CYN}[*]${NC} assetfinder..."
  assetfinder "$d" >> "$out/$d-subs.txt"
  sort -u "$out/$d-subs.txt" -o "$out/$d-subs-clean.txt"
  echo -e "${GRN}[✓]${NC} $(wc -l < "$out/$d-subs-clean.txt") subdomains"
  echo -e "${CYN}[*]${NC} waybackurls..."
  while read -r sub; do waybackurls "$sub"; done < "$out/$d-subs-clean.txt" | anew "$out/$d-urls.txt" >/dev/null
  echo -e "${GRN}[✓]${NC} $(wc -l < "$out/$d-urls.txt") urls"
  pause
}

results_menu() {
  banner
  if [ -d "$HOME/osint-results" ]; then
    ls -la "$HOME/osint-results" | tail -n +2
  else
    echo "  no results yet"
  fi
  pause
}

status_menu() {
  banner
  echo -e "${CYN}python tools:${NC}"
  for t in sherlock maigret holehe socialscan toutatis instaloader h8mail; do
    have "$t" && echo -e "  ${GRN}✓${NC} $t" || echo -e "  ${RED}✗${NC} $t"
  done
  if [ -f "$HOME/osint/blackbird/blackbird.py" ]; then
    echo -e "  ${GRN}✓${NC} blackbird"
  else
    echo -e "  ${RED}✗${NC} blackbird"
  fi
  echo
  echo -e "${CYN}go tools:${NC}"
  for t in subfinder assetfinder waybackurls anew enola; do
    go_have "$t" && echo -e "  ${GRN}✓${NC} $t" || echo -e "  ${RED}✗${NC} $t"
  done
  echo
  echo -e "${CYN}hunters:${NC}"
  [ -x "$HOME/osint-hunt.sh" ] && echo -e "  ${GRN}✓${NC} osint-hunt.sh (username)" || echo -e "  ${RED}✗${NC} osint-hunt.sh"
  [ -x "$HOME/osint-hunt-email.sh" ] && echo -e "  ${GRN}✓${NC} osint-hunt-email.sh" || echo -e "  ${RED}✗${NC} osint-hunt-email.sh"
  [ -x "$HOME/osint-hunt-domain.sh" ] && echo -e "  ${GRN}✓${NC} osint-hunt-domain.sh" || echo -e "  ${RED}✗${NC} osint-hunt-domain.sh"
  pause
}

while true; do
  menu
  read -rp "  select > " choice
  case "$choice" in
    1) username_menu ;;
    2) email_menu ;;
    3) domain_menu ;;
    4) insta_menu ;;
    5) full_recon ;;
    6) results_menu ;;
    7) status_menu ;;
    0) clear; exit 0 ;;
    *) ;;
  esac
done
