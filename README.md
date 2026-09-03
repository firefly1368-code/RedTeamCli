# 🐱 Red Team Toolkit CLI

<div align="center">

```
 ██████╗ ███████╗██████╗     ████████╗███████╗ █████╗ ███╗   ███╗
 ██╔══██╗██╔════╝██╔══██╗    ╚══██╔══╝██╔════╝██╔══██╗████╗ ████║
 ██████╔╝█████╗  ██║  ██║       ██║   █████╗  ███████║██╔████╔██║
 ██╔══██╗██╔══╝  ██║  ██║       ██║   ██╔══╝  ██╔══██║██║╚██╔╝██║
 ██║  ██║███████╗██████╔╝       ██║   ███████╗██║  ██║██║ ╚═╝ ██║
 ╚═╝  ╚═╝╚══════╝╚═════╝        ╚═╝   ╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝
```

**Bash-based Red Team Toolkit — buat yang malas ngetik**

![Shell](https://img.shields.io/badge/Shell-Bash-4EAA25?style=flat-square&logo=gnu-bash&logoColor=white)
![License](https://img.shields.io/badge/License-Educational%20Only-red?style=flat-square)
![Linux](https://img.shields.io/badge/OS-All%20Major%20Linux-0078D6?style=flat-square&logo=linux&logoColor=white)
![Version](https://img.shields.io/badge/Version-2.1-orange?style=flat-square)
![Author](https://img.shields.io/badge/Author-firefly1368--code-blueviolet?style=flat-square&logo=github)

</div>

---

> ⚠️ **DISCLAIMER:** Toolkit ini dibuat **HANYA untuk keperluan authorized penetration testing, CTF, dan edukasi keamanan siber**. Penggunaan pada sistem tanpa izin adalah **ILEGAL** dan melanggar hukum. Penulis tidak bertanggung jawab atas penyalahgunaan.

---

## 📋 Daftar Isi

- [Tentang](#-tentang)
- [Fitur](#-fitur)
- [Kompatibilitas](#-kompatibilitas)
- [Struktur File](#-struktur-file)
- [Instalasi & Penggunaan](#-instalasi--penggunaan)
- [Compatibility Check](#-compatibility-check)
- [Fase-fase Toolkit](#-fase-fase-toolkit)
- [Contoh Output](#-contoh-output)
- [Roadmap](#-roadmap)
- [Kontribusi](#-kontribusi)

---

## 🔍 Tentang

Red Team Toolkit CLI adalah Bash script interaktif yang mengumpulkan tools dan teknik red team ke dalam satu antarmuka menu berbasis terminal. Dibuat buat ngebantu pentest workflow dari fase recon sampai reporting tanpa harus ingat semua perintah panjang.

**Kenapa toolkit ini beda:**
- Deteksi OS & package manager otomatis — satu script jalan di semua distro Linux
- Compatibility screen yang tampilkan status tiap tool (ready / installable / manual)
- Auto-install disesuaikan per distro (apt / dnf / pacman / zypper / apk)
- Semua output di-log otomatis dengan timestamp

---

## ✨ Fitur

- **6 Fase Pentest** — Recon → Vuln Scan → Exploit → Maintain Access → Post Exploit → Report
- **40+ Tools terintegrasi** — nmap, sqlmap, hydra, msfconsole, gobuster, ffuf, dan lainnya
- **OS Detection otomatis** — detect distro, family, arch, dan package manager
- **Compatibility Check** — klasifikasi tiap tool: ✔ Available / ◆ Installable / ⚠ Manual / ✘ N/A
- **Distro-aware installer** — package name mapping beda per distro (misal `dig` → `dnsutils` di apt, `bind-utils` di dnf)
- **Fallback graceful** — tool tidak ada? script fallback ke alternatif, bukan crash
- **Auto logging** — semua output disimpan ke `~/.redteam_logs/` dengan timestamp
- **Report generator** — generate draft Markdown report siap edit
- **Colored terminal UI** — menu navigasi dengan warna dan ASCII art

---

## 🐧 Kompatibilitas

| Distro Family | Distro | Package Manager | Status |
|---|---|---|---|
| **Debian** | Kali Linux, Parrot OS, Ubuntu, Debian, Mint, Pop!_OS, Zorin | `apt` | ✅ Full |
| **RHEL** | CentOS Stream, Rocky, AlmaLinux, RHEL, Oracle Linux | `dnf` / `yum` | ✅ Full |
| **Fedora** | Fedora | `dnf` | ✅ Full |
| **Arch** | Arch Linux, Manjaro, EndeavourOS, Garuda, Artix | `pacman` | ✅ Full |
| **openSUSE** | openSUSE Leap, Tumbleweed, SLES | `zypper` | ✅ Full |
| **Alpine** | Alpine Linux | `apk` | ✅ Full |
| **Void** | Void Linux | `xbps-install` | ✅ Full |
| **Gentoo** | Gentoo | `emerge` | ✅ Partial |

> Script berjalan dengan `#!/usr/bin/env bash` — membutuhkan **Bash 4.0+** (untuk `declare -A`)

---

## 📁 Struktur File

```
red-team-toolkit/
├── red_team.cli.sh     # Script utama — menu interaktif & semua fase
└── compat.sh           # Modul kompatibilitas — OS detection, tool checker, installer
```

> **Penting:** Kedua file harus berada di **folder yang sama**. `red_team.cli.sh` akan otomatis `source` `compat.sh` dari direktori yang sama.

---

## 🚀 Instalasi & Penggunaan

### Clone repo

```bash
git clone https://github.com/firefly1368-code/red-team-toolkit.git
cd red-team-toolkit
```

### Beri permission

```bash
chmod +x red_team.cli.sh compat.sh
```

### Jalankan

```bash
./red_team.cli.sh
```

> Saat pertama kali dijalankan di distro baru, **Compatibility Check** akan otomatis tampil untuk mendeteksi OS dan status tools.

### Jalankan langsung tanpa clone (one-liner)

```bash
bash <(curl -s https://raw.githubusercontent.com/firefly1368-code/red-team-toolkit/main/red_team.cli.sh)
```

---

## 🔧 Compatibility Check

Fitur utama toolkit ini. Tampil otomatis di startup dan bisa dipanggil kapan saja via menu **`[c]`**.

```
╔══════════════════════════════════════════════════╗
║  RED TEAM TOOLKIT - COMPATIBILITY CHECK          ║
╚══════════════════════════════════════════════════╝

System
──────────────────────────────────────────────────
  OS            : CentOS Stream 9
  Family        : RHEL
  Architecture  : x86_64
  Package Mgr   : dnf

AVAILABLE (terinstall, siap pakai)
──────────────────────────────────────────────────
  ✔ nmap
  ✔ curl
  ✔ wget
  ✔ python3
  ✔ git

INSTALLABLE (via dnf)
──────────────────────────────────────────────────
  ◆ tcpdump          (dnf: tcpdump)
  ◆ hydra            (dnf: hydra)
  ◆ john             (dnf: john)

AVAILABLE / MANUAL INSTALL (repo khusus / git / pip)
──────────────────────────────────────────────────
  ⚠ gobuster
  ⚠ ffuf
  ⚠ sqlmap
  ⚠ metasploit

NOT AVAILABLE (tidak kompatibel / perlu build manual)
──────────────────────────────────────────────────
  ✘ apt-specific package

──────────────────────────────────────────────────
  Total: 42 tools | Ready: 12 | Installable: 15 | Manual: 10 | N/A: 5

  [1] Install compatible tools    [2] Check tool status
  [3] Show unsupported tools      [4] Continue to toolkit
  [b] Back
```

### Opsi di Compatibility Screen

| Opsi | Fungsi |
|---|---|
| `[1]` | Auto-install semua tools yang compatible dengan distro saat ini |
| `[2]` | Tampilkan detail status + nama package tiap tool |
| `[3]` | Tampilkan tools yang tidak tersedia di distro ini |
| `[4]` | Lanjut ke toolkit |
| `[c]` | Buka Compatibility Check dari main menu kapan saja |

---

## 📌 Fase-fase Toolkit

### Fase 1 — Reconnaissance
Passive dan active reconnaissance. WHOIS, DNS enumeration, subdomain discovery, port scan (nmap + masscan), SMB/SNMP/LDAP/RPC enum, banner grabbing, web tech detection.

### Fase 2 — Vulnerability Scanning
Web: Nikto, gobuster, ffuf, dirb, sqlmap, wpscan, joomscan, sslscan.
Network: nmap vuln scripts, SMB vuln (EternalBlue), searchsploit, OpenVAS.

### Fase 3 — Exploitation
Metasploit (launch, autopwn, payload gen, listener), Hydra brute force (SSH/FTP/HTTP/RDP/SMB/VNC), SQLmap exploitation, XSS payload generator, LFI tester, ARP spoofing, Responder, reverse shell generator, CrackMapExec.

### Fase 4 — Maintaining Access
Backdoor listener, cron persistence (demo), SSH key implant (demo), socat bind shell, SSH tunneling, SOCKS5 proxy, Meterpreter persistence, web shell templates, ProxyChains config.

### Fase 5 — Post Exploitation & Covering Tracks
LinPEAS/WinPEAS, SUID/SGID finder, sudo check, crontab audit, John/Hashcat hash cracking, hash identifier, credential dump, bash history clear, log wiping (simulasi), timestomping, steghide.

### Fase 6 — Reporting
Generate draft report Markdown dengan template executive summary, scope, findings table (Critical/High/Medium/Low), attack timeline, rekomendasi, dan raw log reference.

---

## 📂 Output & Logs

Semua hasil scan dan eksekusi otomatis disimpan:

```
~/.redteam_logs/
├── session_YYYYMMDD_HHMMSS.log     # Log session lengkap
├── recon_HHMMSS_whois.txt          # Output per tool
├── vuln_HHMMSS_nikto.txt
├── exploit_HHMMSS_hydra_ssh.txt
└── scope.txt                       # Target & scope

~/redteam_reports/
└── redteam_report_YYYYMMDD_HHMMSS.md   # Draft report
```

---

## 🗺️ Roadmap

- [ ] WSL2 detection & support penuh
- [ ] Docker-based isolated environment
- [ ] Config file (`~/.redteam.conf`) untuk custom wordlist path
- [ ] Plugin system untuk tambah fase custom
- [ ] Report export ke PDF via `pandoc`
- [ ] Integrasi dengan Notion/Obsidian untuk note-taking

---

## 🤝 Kontribusi

Pull request welcome. Untuk perubahan besar, buka issue dulu.

```bash
git checkout -b feature/nama-fitur
git commit -m "feat: tambah fitur X"
git push origin feature/nama-fitur
```

---

## 👤 Author

**Riski Akbar**
- GitHub: [@firefly1368-code](https://github.com/firefly1368-code)
- TJKT — SMK Wikrama Bogor
- CTF Player | Ethical Hacker | Full-stack Dev

---

## 📜 License

Script ini dibuat untuk **keperluan edukasi dan authorized testing**. Tidak ada lisensi open-source formal — gunakan dengan tanggung jawab.

**Dilarang keras digunakan untuk:**
- Akses unauthorized ke sistem orang lain
- Aktivitas ilegal dalam bentuk apapun
- Distribusi ulang untuk tujuan malicious

---

<div align="center">
<sub>Made with ☕ dan banyak <code>nmap</code> — firefly1368-code</sub>
</div>
