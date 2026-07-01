#!/bin/bash

echo "=================================================="
echo "       Linux Security Audit Script"
echo "=================================================="
echo ""

echo "[*] System Information"
echo "--------------------------------------------------"
echo "Hostname:     $(hostname)"
echo "OS:     $(cat /etc/os-release | grep PRETTY_NAME | cut -d= -f2)"
echo "Kernel:     $(uname -r)"
echo "Current User: $(whoami)"
echo ""
echo "[*] Checking Open Ports"
echo "--------------------------------------------------"
ss -tuln
echo ""

echo "[*] Checking for Telnet and FTP Services"
echo "--------------------------------------------------"
if systemctl is-active --quiet telnet 2>/dev/null; then
	echo "[FAIL] Telnet is running - HIGH RISK"
else
	echo "[PASS] Telnet is not running"
fi

if systemctl is-active --quiet vsftpd 2>/dev/null; then
	echo "[FAIL] FTP (vsftpd) is running - MEDIUM RISK"
else
	echo "[PASS] FTP is not running"
fi
echo ""

echo "[*] Checking User Accounts"
echo "--------------------------------------------------"
echo "Users with sudo privilages:"
grep -Po '^sudo.+:\K.*$' /etc/group
echo ""

echo "Users with empty passwords:"
sudo awk -F: '($2 == "" ) {print $1}' /etc/shadow
echo ""

echo "All local users:"
cut -d: -f1 /etc/passwd
echo ""

echo "[*] Checking File Permissions"
echo "--------------------------------------------------"
echo "World-writable files in /etc (excluding symlinks):"
find /etc -type f -perm -o+w 2>/dev/null
echo ""

echo "SUID files (can run as root regardless of who executes):"
find / -type f -perm -4000 2>/dev/null
echo ""

echo "[*] Checking Failed Login Attempts"
echo "--------------------------------------------------"
echo "Last 10 failed login attempts:"
sudo grep "Failed password" /var/log/auth.log 2>/dev/null | tail -10
echo ""

echo "Top IPs with failed logins:"
sudo grep "Failed password" /var/log/auth.log 2>/dev/null | grep -oP '(\d{1,3}\.){3}\d{1,3}' | sort | uniq -c | sort -rn | head -10
echo ""

echo "[*] Checking Running Services"
echo "--------------------------------------------------"
systemctl list-units --type=service --state=running
echo ""

echo "=================================================="
echo "         Audit Complete"
echo "=================================================="

