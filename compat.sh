#!/usr/bin/env bash
# ============================================================
#  RED TEAM TOOLKIT — COMPATIBILITY MODULE
#  Author  : Riski Akbar - firefly1368-code
#  Version : 1.0
#  Desc    : OS detection, tool availability, distro-aware install
# ============================================================

# ── Warna (fallback jika belum di-set parent) ─────────────
RED='\033[0;31m';   LRED='\033[1;31m'
GRN='\033[0;32m';   LGRN='\033[1;32m'
YLW='\033[0;33m';   LYLW='\033[1;33m'
BLU='\033[0;34m';   LBLU='\033[1;34m'
CYN='\033[0;36m';   LCYN='\033[1;36m'
MAG='\033[0;35m';   LMAG='\033[1;35m'
WHT='\033[1;37m';   GRY='\033[0;37m'
NC='\033[0m';       BOLD='\033[1m'
DIM='\033[2m'

# ── Deteksi OS & Package Manager ──────────────────────────
detect_os() {
    OS_NAME=""
    OS_FAMILY=""
    OS_ARCH=""
    PKG_MANAGER=""
    PKG_INSTALL=""
    PKG_UPDATE=""

    OS_ARCH=$(uname -m)

    # Baca /etc/os-release jika ada
    if [[ -f /etc/os-release ]]; then
        source /etc/os-release
        OS_NAME="${PRETTY_NAME:-$NAME}"
        OS_ID="${ID:-unknown}"
        OS_ID_LIKE="${ID_LIKE:-}"
    elif [[ -f /etc/redhat-release ]]; then
        OS_NAME=$(cat /etc/redhat-release)
        OS_ID="rhel"
    elif [[ -f /etc/debian_version ]]; then
        OS_NAME="Debian $(cat /etc/debian_version)"
        OS_ID="debian"
    else
        OS_NAME=$(uname -s)
        OS_ID="unknown"
    fi

    # Deteksi keluarga distro & package manager
    case "$OS_ID" in
        kali|parrot|ubuntu|debian|linuxmint|pop|elementary|mx|zorin)
            OS_FAMILY="Debian"
            PKG_MANAGER="apt"
            PKG_UPDATE="apt-get update -qq"
            PKG_INSTALL="apt-get install -y"
            ;;
        centos|rhel|almalinux|rocky|ol|scientific)
            OS_FAMILY="RHEL"
            # CentOS 8+ / RHEL 8+ pakai dnf
            if command -v dnf &>/dev/null; then
                PKG_MANAGER="dnf"
                PKG_INSTALL="dnf install -y"
                PKG_UPDATE="dnf check-update -q || true"
            else
                PKG_MANAGER="yum"
                PKG_INSTALL="yum install -y"
                PKG_UPDATE="yum check-update -q || true"
            fi
            ;;
        fedora)
            OS_FAMILY="Fedora"
            PKG_MANAGER="dnf"
            PKG_INSTALL="dnf install -y"
            PKG_UPDATE="dnf check-update -q || true"
            ;;
        arch|manjaro|endeavouros|garuda|artix)
            OS_FAMILY="Arch"
            PKG_MANAGER="pacman"
            PKG_INSTALL="pacman -S --noconfirm"
            PKG_UPDATE="pacman -Sy --noconfirm"
            ;;
        opensuse*|sles|sled)
            OS_FAMILY="openSUSE"
            PKG_MANAGER="zypper"
            PKG_INSTALL="zypper install -y"
            PKG_UPDATE="zypper refresh"
            ;;
        alpine)
            OS_FAMILY="Alpine"
            PKG_MANAGER="apk"
            PKG_INSTALL="apk add"
            PKG_UPDATE="apk update"
            ;;
        void)
            OS_FAMILY="Void"
            PKG_MANAGER="xbps-install"
            PKG_INSTALL="xbps-install -y"
            PKG_UPDATE="xbps-install -Su"
            ;;
        gentoo)
            OS_FAMILY="Gentoo"
            PKG_MANAGER="emerge"
            PKG_INSTALL="emerge"
            PKG_UPDATE="emerge --sync"
            ;;
        *)
            # Fallback: deteksi dari ID_LIKE atau command
            if echo "$OS_ID_LIKE" | grep -qiE "debian|ubuntu"; then
                OS_FAMILY="Debian"
                PKG_MANAGER="apt"
                PKG_INSTALL="apt-get install -y"
                PKG_UPDATE="apt-get update -qq"
            elif echo "$OS_ID_LIKE" | grep -qiE "rhel|fedora|centos"; then
                OS_FAMILY="RHEL"
                PKG_MANAGER=$(command -v dnf &>/dev/null && echo dnf || echo yum)
                PKG_INSTALL="$PKG_MANAGER install -y"
                PKG_UPDATE="$PKG_MANAGER check-update -q || true"
            elif command -v apt-get &>/dev/null; then
                OS_FAMILY="Debian"
                PKG_MANAGER="apt"
                PKG_INSTALL="apt-get install -y"
                PKG_UPDATE="apt-get update -qq"
            elif command -v pacman &>/dev/null; then
                OS_FAMILY="Arch"
                PKG_MANAGER="pacman"
                PKG_INSTALL="pacman -S --noconfirm"
                PKG_UPDATE="pacman -Sy --noconfirm"
            else
                OS_FAMILY="Unknown"
                PKG_MANAGER="N/A"
                PKG_INSTALL="echo 'Manual install required:'"
                PKG_UPDATE="echo 'Manual update required:'"
            fi
            ;;
    esac
}

# ── Definisi Tools per Kategori ───────────────────────────
# Format: "binary_name|display_name|category"
# category: core | security | password | framework | special

declare -A TOOL_PACKAGES_APT=(
    [nmap]="nmap"
    [curl]="curl"
    [wget]="wget"
    [tcpdump]="tcpdump"
    [openssl]="openssl"
    [socat]="socat"
    [python3]="python3"
    [git]="git"
    [dig]="dnsutils"
    [nslookup]="dnsutils"
    [whois]="whois"
    [nc]="netcat-openbsd"
    [masscan]="masscan"
    [nikto]="nikto"
    [gobuster]="gobuster"
    [ffuf]="ffuf"
    [dirb]="dirb"
    [wfuzz]="wfuzz"
    [sqlmap]="sqlmap"
    [hydra]="hydra"
    [john]="john"
    [hashcat]="hashcat"
    [medusa]="medusa"
    [ncrack]="ncrack"
    [enum4linux]="enum4linux"
    [smbclient]="smbclient"
    [rpcclient]="samba-common-bin"
    [crackmapexec]="crackmapexec"
    [responder]="responder"
    [wireshark]="wireshark"
    [tshark]="tshark"
    [sslscan]="sslscan"
    [whatweb]="whatweb"
    [dnsenum]="dnsenum"
    [dnsrecon]="dnsrecon"
    [fierce]="fierce"
    [theHarvester]="theharvester"
    [ldapsearch]="ldap-utils"
    [snmpwalk]="snmp"
    [onesixtyone]="onesixtyone"
    [searchsploit]="exploitdb"
    [proxychains4]="proxychains4"
    [arpspoof]="dsniff"
    [steghide]="steghide"
    [wpscan]="wpscan"
    [msfconsole]="metasploit-framework"
    [msfvenom]="metasploit-framework"
)

declare -A TOOL_PACKAGES_DNF=(
    [nmap]="nmap"
    [curl]="curl"
    [wget]="wget"
    [tcpdump]="tcpdump"
    [openssl]="openssl"
    [socat]="socat"
    [python3]="python3"
    [git]="git"
    [dig]="bind-utils"
    [nslookup]="bind-utils"
    [whois]="whois"
    [nc]="nmap-ncat"
    [masscan]="masscan"
    [nikto]="nikto"
    [gobuster]="gobuster"          # EPEL/manual
    [sqlmap]="sqlmap"              # EPEL
    [hydra]="hydra"                # EPEL
    [john]="john"                  # EPEL
    [hashcat]="hashcat"
    [smbclient]="samba-client"
    [enum4linux]="enum4linux"      # manual
    [ldapsearch]="openldap-clients"
    [snmpwalk]="net-snmp-utils"
    [onesixtyone]="onesixtyone"    # manual
    [sslscan]="sslscan"            # manual
    [proxychains4]="proxychains-ng"
    [arpspoof]="dsniff"
    [wireshark]="wireshark"
    [tshark]="wireshark-cli"
    [wpscan]="rubygem-wpscan"      # manual
    [msfconsole]="metasploit"      # manual/rpm
    [msfvenom]="metasploit"
    [dnsenum]="dnsenum"
    [theHarvester]="theharvester"  # pip/manual
    [searchsploit]=""              # manual
    [responder]=""                 # manual/git
    [ffuf]=""                      # manual binary
    [crackmapexec]=""              # pip
    [dnsrecon]="python3-dnsrecon"  # manual
)

declare -A TOOL_PACKAGES_PACMAN=(
    [nmap]="nmap"
    [curl]="curl"
    [wget]="wget"
    [tcpdump]="tcpdump"
    [openssl]="openssl"
    [socat]="socat"
    [python3]="python"
    [git]="git"
    [dig]="bind"
    [nslookup]="bind"
    [whois]="whois"
    [nc]="openbsd-netcat"
    [masscan]="masscan"
    [nikto]="nikto"
    [gobuster]="gobuster"
    [sqlmap]="sqlmap"
    [hydra]="hydra"
    [john]="john"
    [hashcat]="hashcat"
    [smbclient]="samba"
    [enum4linux]="enum4linux"      # AUR
    [wireshark]="wireshark-qt"
    [tshark]="wireshark-cli"
    [sslscan]="sslscan"            # AUR
    [proxychains4]="proxychains-ng"
    [arpspoof]="dsniff"
    [ffuf]="ffuf"                  # AUR
    [crackmapexec]="crackmapexec"  # AUR
    [wpscan]="ruby-wpscan"         # AUR
    [msfconsole]="metasploit"      # AUR
    [msfvenom]="metasploit"
    [responder]="responder"        # AUR
    [theHarvester]="theharvester"
    [dnsenum]="dnsenum"
    [dnsrecon]="dnsrecon"
    [searchsploit]="exploitdb"     # AUR
)

# ── Tool Lists per Kategori ───────────────────────────────

# Tools yang tersedia di semua distro via native pkg manager
TOOLS_CORE=(nmap curl wget tcpdump openssl socat python3 git dig nslookup whois nc)

# Security tools — tersedia di kebanyakan distro (mungkin butuh EPEL/AUR)
TOOLS_SECURITY=(
    masscan nikto gobuster ffuf dirb wfuzz
    sqlmap hydra john hashcat medusa ncrack
    dnsenum dnsrecon fierce theHarvester
    smbclient enum4linux rpcclient crackmapexec
    ldapsearch snmpwalk onesixtyone
    responder wireshark tshark sslscan whatweb
    arpspoof proxychains4 searchsploit wpscan
)

# Tools yang butuh install manual / repo khusus / git clone
TOOLS_MANUAL_INSTALL=(
    gobuster ffuf sqlmap hydra john hashcat
    metasploit crackmapexec wpscan responder
    impacket dirb enum4linux dnsrecon theHarvester
)

# Metasploit
TOOLS_FRAMEWORK=(msfconsole msfvenom)

# Tools yang APT-specific / tidak ada di non-Debian
TOOLS_APT_SPECIFIC=(apt dpkg)

# ── Klasifikasi Satu Tool ─────────────────────────────────
# Returns: "available" | "manual" | "unavailable" | "apt_only"
classify_tool() {
    local tool="$1"

    # Cek apakah binary tersedia
    if command -v "$tool" &>/dev/null; then
        echo "available"
        return
    fi

    # Cek apakah tool ini APT-specific
    local apt_only
    for t in "${TOOLS_APT_SPECIFIC[@]}"; do
        [[ "$t" == "$tool" ]] && apt_only=1 && break
    done
    if [[ -n "$apt_only" && "$PKG_MANAGER" != "apt" ]]; then
        echo "apt_only"
        return
    fi

    # Cek apakah tool memiliki package di pkg manager saat ini
    local has_pkg=0
    case "$PKG_MANAGER" in
        apt)
            [[ -n "${TOOL_PACKAGES_APT[$tool]}" ]] && has_pkg=1
            ;;
        dnf|yum)
            [[ -n "${TOOL_PACKAGES_DNF[$tool]}" ]] && has_pkg=1
            ;;
        pacman)
            [[ -n "${TOOL_PACKAGES_PACMAN[$tool]}" ]] && has_pkg=1
            ;;
        *)
            has_pkg=0
            ;;
    esac

    # Cek apakah masuk kategori manual install
    local is_manual=0
    for t in "${TOOLS_MANUAL_INSTALL[@]}"; do
        [[ "$t" == "$tool" ]] && is_manual=1 && break
    done

    if [[ $has_pkg -eq 1 ]]; then
        [[ $is_manual -eq 1 ]] && echo "manual" || echo "installable"
    else
        echo "unavailable"
    fi
}

# ── Get Package Name untuk Distro Saat Ini ───────────────
get_pkg_name() {
    local tool="$1"
    case "$PKG_MANAGER" in
        apt)        echo "${TOOL_PACKAGES_APT[$tool]:-$tool}" ;;
        dnf|yum)    echo "${TOOL_PACKAGES_DNF[$tool]:-$tool}" ;;
        pacman)     echo "${TOOL_PACKAGES_PACMAN[$tool]:-$tool}" ;;
        *)          echo "$tool" ;;
    esac
}

# ── Tampilkan Compatibility Screen ───────────────────────
show_compat_screen() {
    clear
    local W=50

    # ── Header ──────────────────────────────────────────
    echo ""
    echo -e "${BOLD}${LRED}╔$(printf '═%.0s' $(seq 1 $((W-2))))╗${NC}"
    printf "${BOLD}${LRED}║${NC}${WHT}%-$((W-2))s${BOLD}${LRED}║${NC}\n" "  RED TEAM TOOLKIT - COMPATIBILITY CHECK"
    echo -e "${BOLD}${LRED}╚$(printf '═%.0s' $(seq 1 $((W-2))))╝${NC}"
    echo ""

    # ── System Info ─────────────────────────────────────
    echo -e "${BOLD}${LCYN}System${NC}"
    echo -e "${GRY}$(printf '─%.0s' $(seq 1 $W))${NC}"
    printf "  ${WHT}%-14s${NC}: ${LYLW}%s${NC}\n" "OS" "$OS_NAME"
    printf "  ${WHT}%-14s${NC}: ${LYLW}%s${NC}\n" "Family" "$OS_FAMILY"
    printf "  ${WHT}%-14s${NC}: ${LYLW}%s${NC}\n" "Architecture" "$OS_ARCH"
    printf "  ${WHT}%-14s${NC}: ${LYLW}%s${NC}\n" "Package Mgr" "$PKG_MANAGER"
    echo ""

    # ── Collect tool statuses ────────────────────────────
    local -a avail_tools=()
    local -a installable_tools=()
    local -a manual_tools=()
    local -a unavail_tools=()

    # Core tools
    for t in "${TOOLS_CORE[@]}"; do
        local status; status=$(classify_tool "$t")
        case "$status" in
            available)    avail_tools+=("$t") ;;
            installable)  installable_tools+=("$t") ;;
            manual)       manual_tools+=("$t") ;;
            apt_only)     unavail_tools+=("$t (apt only)") ;;
            *)            unavail_tools+=("$t") ;;
        esac
    done

    # Security tools
    for t in "${TOOLS_SECURITY[@]}"; do
        local status; status=$(classify_tool "$t")
        case "$status" in
            available)    avail_tools+=("$t") ;;
            installable)  installable_tools+=("$t") ;;
            manual)       manual_tools+=("$t") ;;
            apt_only)     unavail_tools+=("$t (apt only)") ;;
            *)            unavail_tools+=("$t") ;;
        esac
    done

    # Metasploit
    for t in "${TOOLS_FRAMEWORK[@]}"; do
        local status; status=$(classify_tool "$t")
        case "$status" in
            available)    avail_tools+=("$t") ;;
            *)            manual_tools+=("$t") ;;
        esac
    done

    # ── Print AVAILABLE ──────────────────────────────────
    echo -e "${BOLD}${LGRN}AVAILABLE${NC} ${DIM}(terinstall, siap pakai)${NC}"
    echo -e "${GRY}$(printf '─%.0s' $(seq 1 $W))${NC}"
    if [[ ${#avail_tools[@]} -eq 0 ]]; then
        echo -e "  ${GRY}(tidak ada tools yang terinstall)${NC}"
    else
        for t in "${avail_tools[@]}"; do
            echo -e "  ${LGRN}✔${NC} $t"
        done
    fi
    echo ""

    # ── Print INSTALLABLE ────────────────────────────────
    if [[ ${#installable_tools[@]} -gt 0 ]]; then
        echo -e "${BOLD}${LBLU}INSTALLABLE${NC} ${DIM}(tersedia via $PKG_MANAGER)${NC}"
        echo -e "${GRY}$(printf '─%.0s' $(seq 1 $W))${NC}"
        for t in "${installable_tools[@]}"; do
            local pkg; pkg=$(get_pkg_name "$t")
            echo -e "  ${LBLU}◆${NC} $t ${DIM}($PKG_MANAGER: $pkg)${NC}"
        done
        echo ""
    fi

    # ── Print AVAILABLE / MANUAL ─────────────────────────
    if [[ ${#manual_tools[@]} -gt 0 ]]; then
        echo -e "${BOLD}${LYLW}AVAILABLE / MANUAL INSTALL${NC} ${DIM}(repo khusus / git / pip)${NC}"
        echo -e "${GRY}$(printf '─%.0s' $(seq 1 $W))${NC}"
        for t in "${manual_tools[@]}"; do
            echo -e "  ${LYLW}⚠${NC} $t"
        done
        echo ""
    fi

    # ── Print NOT AVAILABLE ──────────────────────────────
    if [[ ${#unavail_tools[@]} -gt 0 ]]; then
        echo -e "${BOLD}${LRED}NOT AVAILABLE${NC} ${DIM}(tidak kompatibel / perlu build manual)${NC}"
        echo -e "${GRY}$(printf '─%.0s' $(seq 1 $W))${NC}"
        for t in "${unavail_tools[@]}"; do
            echo -e "  ${LRED}✘${NC} $t"
        done
        echo ""
    fi

    # ── Stats ────────────────────────────────────────────
    local total=$(( ${#avail_tools[@]} + ${#installable_tools[@]} + ${#manual_tools[@]} + ${#unavail_tools[@]} ))
    echo -e "${GRY}$(printf '─%.0s' $(seq 1 $W))${NC}"
    echo -e "  ${DIM}Total: $total tools | ${LGRN}${#avail_tools[@]} ready${NC}${DIM} | ${LBLU}${#installable_tools[@]} installable${NC}${DIM} | ${LYLW}${#manual_tools[@]} manual${NC}${DIM} | ${LRED}${#unavail_tools[@]} N/A${NC}"
    echo ""

    # ── Actions ─────────────────────────────────────────
    echo -e "${BOLD}  [1]${NC} Install compatible tools    ${BOLD}[2]${NC} Check tool status"
    echo -e "${BOLD}  [3]${NC} Show unsupported tools      ${BOLD}[4]${NC} Continue to toolkit"
    echo -e "${BOLD}  [b]${NC} Back"
    echo ""
    read -rp " Pilih: " compat_choice

    case "$compat_choice" in
        1) compat_install_tools ;;
        2) compat_check_detail ;;
        3) compat_show_unsupported ;;
        4) return 0 ;;
        b|B) return 1 ;;
    esac
}

# ── Install Compatible Tools ──────────────────────────────
compat_install_tools() {
    echo ""
    echo -e "${BOLD}${LCYN}[ INSTALL COMPATIBLE TOOLS — $OS_FAMILY / $PKG_MANAGER ]${NC}"
    echo -e "${GRY}$(printf '─%.0s' $(seq 1 50))${NC}"

    # Build package list berdasarkan distro
    local pkgs=()

    case "$PKG_MANAGER" in
        apt)
            pkgs=(
                nmap masscan nikto gobuster ffuf dirb wfuzz
                sqlmap hydra john hashcat medusa ncrack
                netcat-openbsd socat curl wget whois
                dnsutils dnsenum dnsrecon fierce theharvester
                smbclient enum4linux samba-common-bin
                wireshark tshark tcpdump
                sslscan git python3-pip
                exploitdb proxychains4 dsniff
                ldap-utils snmp onesixtyone whatweb
            )
            ;;
        dnf|yum)
            pkgs=(
                nmap masscan nikto
                hydra john hashcat nmap-ncat socat
                curl wget whois bind-utils dnsenum
                samba-client openldap-clients
                net-snmp-utils wireshark wireshark-cli tcpdump
                git python3 python3-pip proxychains-ng
                hashcat openssl
            )
            echo -e "${LYLW}[!] Mengaktifkan EPEL repo untuk tools tambahan...${NC}"
            sudo $PKG_MANAGER install -y epel-release 2>/dev/null || true
            ;;
        pacman)
            pkgs=(
                nmap masscan nikto gobuster ffuf sqlmap
                hydra john hashcat medusa ncrack
                openbsd-netcat socat curl wget whois bind
                samba wireshark-cli tcpdump
                git python proxychains-ng dsniff
                openssl sslscan dnsenum
            )
            ;;
        zypper)
            pkgs=(
                nmap socat curl wget openssl git python3
                tcpdump whois bind-utils hydra john hashcat
                samba-client wireshark
            )
            ;;
        apk)
            pkgs=(
                nmap socat curl wget openssl git python3
                tcpdump bind-tools hydra john
            )
            ;;
        *)
            echo -e "${LRED}[-] Package manager '$PKG_MANAGER' tidak didukung auto-install.${NC}"
            echo -e "${LYLW}[!] Install manual tools berikut:${NC}"
            echo "    nmap curl wget socat openssl python3 git tcpdump"
            read -rp " Tekan [Enter] untuk lanjut..." _
            return
            ;;
    esac

    echo -e "${LBLU}[*] Mengupdate package list...${NC}"
    sudo bash -c "$PKG_UPDATE" 2>/dev/null

    echo -e "${LBLU}[*] Menginstall ${#pkgs[@]} packages...${NC}"
    sudo $PKG_INSTALL "${pkgs[@]}" 2>/dev/null

    # Install via pip (universal)
    echo -e "${LBLU}[*] Menginstall Python tools via pip...${NC}"
    pip3 install impacket crackmapexec 2>/dev/null || \
        pip3 install --break-system-packages impacket 2>/dev/null || true

    # Install tools manual yang sering dibutuhkan
    echo ""
    echo -e "${LYLW}[!] Tools berikut butuh install manual:${NC}"

    case "$PKG_MANAGER" in
        apt)
            # Metasploit - apt-based
            if ! command -v msfconsole &>/dev/null; then
                echo -e "  ${LYLW}⚠ Metasploit:${NC} curl https://raw.githubusercontent.com/rapid7/metasploit-omnibus/master/config/templates/metasploit-framework-wrappers/msfupdate.erb > /tmp/msfinstall && chmod +x /tmp/msfinstall && sudo /tmp/msfinstall"
            fi
            # wpscan
            if ! command -v wpscan &>/dev/null; then
                echo -e "  ${LYLW}⚠ WPScan:${NC} sudo gem install wpscan"
            fi
            ;;
        dnf|yum)
            echo -e "  ${LYLW}⚠ gobuster:${NC}  go install github.com/OJ/gobuster/v3@latest"
            echo -e "  ${LYLW}⚠ ffuf:${NC}       go install github.com/ffuf/ffuf/v2@latest"
            echo -e "  ${LYLW}⚠ sqlmap:${NC}     pip3 install sqlmap"
            echo -e "  ${LYLW}⚠ enum4linux:${NC} git clone https://github.com/CiscoCXSecurity/enum4linux.git"
            echo -e "  ${LYLW}⚠ Metasploit:${NC} https://docs.metasploit.com/docs/using-metasploit/getting-started/nightly-installers.html"
            echo -e "  ${LYLW}⚠ responder:${NC}  git clone https://github.com/lgandx/Responder.git"
            echo -e "  ${LYLW}⚠ searchsploit:${NC} git clone https://gitlab.com/exploit-database/exploitdb.git"
            ;;
        pacman)
            echo -e "  ${LYLW}⚠ AUR tools:${NC} yay -S metasploit wpscan responder enum4linux ffuf"
            echo -e "  ${DIM}  (perlu yay atau paru AUR helper)${NC}"
            ;;
    esac

    echo ""
    echo -e "${LGRN}[+] Install selesai! Jalankan [2] Check tool status untuk verifikasi.${NC}"
    read -rp " Tekan [Enter] untuk lanjut..." _
    show_compat_screen
}

# ── Detail Check per Tool ─────────────────────────────────
compat_check_detail() {
    clear
    echo ""
    echo -e "${BOLD}${WHT}[ DETAIL TOOL STATUS — $OS_FAMILY ]${NC}"
    echo -e "${GRY}$(printf '─%.0s' $(seq 1 60))${NC}"
    printf "  ${BOLD}%-20s %-12s %-25s${NC}\n" "TOOL" "STATUS" "PACKAGE / NOTE"
    echo -e "${GRY}$(printf '─%.0s' $(seq 1 60))${NC}"

    local all_tools=("${TOOLS_CORE[@]}" "${TOOLS_SECURITY[@]}" "${TOOLS_FRAMEWORK[@]}")

    for t in "${all_tools[@]}"; do
        local status; status=$(classify_tool "$t")
        local pkg; pkg=$(get_pkg_name "$t")
        local status_str="" color=""

        case "$status" in
            available)    status_str="✔ ready"    color="$LGRN" ;;
            installable)  status_str="◆ installable" color="$LBLU" ;;
            manual)       status_str="⚠ manual"   color="$LYLW" ;;
            apt_only)     status_str="✘ apt only" color="$LRED" ;;
            unavailable)  status_str="✘ N/A"      color="$LRED" ;;
        esac

        printf "  ${color}%-20s %-16s${NC}${DIM}%s${NC}\n" \
            "$t" "$status_str" "${pkg:-manual/git}"
    done

    echo ""
    read -rp " Tekan [Enter] untuk kembali..." _
    show_compat_screen
}

# ── Show Unsupported Tools ────────────────────────────────
compat_show_unsupported() {
    clear
    echo ""
    echo -e "${BOLD}${LRED}[ TOOLS TIDAK DIDUKUNG — $OS_FAMILY / $PKG_MANAGER ]${NC}"
    echo -e "${GRY}$(printf '─%.0s' $(seq 1 55))${NC}"
    echo ""

    local all_tools=("${TOOLS_CORE[@]}" "${TOOLS_SECURITY[@]}" "${TOOLS_FRAMEWORK[@]}")
    local found=0

    for t in "${all_tools[@]}"; do
        local status; status=$(classify_tool "$t")
        if [[ "$status" == "unavailable" || "$status" == "apt_only" ]]; then
            found=1
            echo -e "  ${LRED}✘${NC} ${WHT}$t${NC}"
            case "$t" in
                apt|dpkg)
                    echo -e "     ${DIM}→ APT-specific, tidak ada di $PKG_FAMILY${NC}" ;;
                *)
                    echo -e "     ${DIM}→ Tidak ada di $PKG_MANAGER repo, install manual${NC}" ;;
            esac
        fi
    done

    [[ $found -eq 0 ]] && echo -e "  ${LGRN}Semua tools kompatibel dengan $OS_FAMILY!${NC}"

    echo ""
    read -rp " Tekan [Enter] untuk kembali..." _
    show_compat_screen
}

# ── Entry Point ───────────────────────────────────────────
run_compat_check() {
    detect_os
    show_compat_screen
}
