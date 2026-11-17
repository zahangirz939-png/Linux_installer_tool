#!/data/data/com.termux/files/usr/bin/bash

clear

BLUE='\033[1;34m'
CYAN='\033[1;36m'
GREEN='\033[1;32m'
RED='\033[1;31m'
WHITE='\033[1;37m'
RESET='\033[0m'

while true; do
clear

echo -e "${BLUE}"
echo "╔════════════════════════════════════════════╗"
echo "║                                            ║"
echo "║         LINUX TOOLS CPU SUPPORTED          ║"
echo "║               For aarch64                  ║"
echo "║                                            ║"
echo "║                 VERSION 1.0                ║"
echo "║                                            ║"
echo "╚════════════════════════════════════════════╝"
echo -e "${RESET}"

echo -e "${CYAN}  [1]${WHITE} VNC Linux Installer Download"
echo -e "${CYAN}  [2]${WHITE} VNC Linux Installation Start"
echo -e "${CYAN}  [3]${WHITE} Important Pkg install"
echo -e "${CYAN}  [4]${WHITE} Linux Starting"
echo -e "${RED}  [5]${WHITE} Linux Stop"
echo -e "${RED}  [0]${WHITE} Exit"

echo
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
read -p "  Select Option: " choice

case "$choice" in

1)
    clear
    echo -e "${GREEN}VNC Linux Installer download...${RESET}"
    aria2c -x 16 -s 16 -k 1M https://archive.org/download/vnc-cpu-supported-aarch-64/VNC_CPU_Supported_aarch64.gz
    echo
    read -p "Press Enter to continue..."
    ;;

2)
    clear
    echo -e "${GREEN}Installation starting...${RESET}"
    if [ ! -f ~/VNC_CPU_Supported_aarch64.gz ]; then
        echo -e "${RED}File not found! First press 1 to Download${RESET}"
    else
        tar -xzpf ~/VNC_CPU_Supported_aarch64.gz -C /data/data/com.termux/files
        echo -e "${GREEN}Restore Done! Restart Termux${RESET}"
    fi
    echo
    read -p "Press Enter to continue..."
    ;;

3)
    clear
    echo -e "${CYAN}Important Install Package List${RESET}"
    pkg install aria2 -y; pkg install tar -y
    echo
    read -p "Press Enter to continue..."
    ;;

4)
    clear
    echo -e "${GREEN}Linux starting...${RESET}"
    vncserver :1
    echo
    read -p "Press Enter to continue..."
    ;;

5)
    clear
    echo -e "${RED}Linux stop...${RESET}"
    vncserver -kill :1
    echo
    read -p "Press Enter to continue..."
    ;;

0)
    clear
    echo -e "${GREEN}Thank you!${RESET}"
    exit 0
    ;;

*)
    echo -e "${RED}Invalid Option!${RESET}"
    sleep 2
    ;;

esac

done