
#!/data/data/com.termux/files/usr/bin/bash

URL="https://github.com/zahangirz939-png/VNC-for-termux-CPU-supported-aarch64/releases/download/4.0/VNC_CPU_Supported_aarch64.gz"

DIR="$HOME/LinuxInstaller"
FILE="$DIR/VNC_CPU_Supported_aarch64.gz"
TARGET="/data/data/com.termux/files"

mkdir -p "$DIR"

# Check dependencies
for cmd in dialog curl pv tar stat awk; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "Missing command: $cmd"
        exit 1
    fi
done

menu() {
    dialog --clear \
        --no-cancel \
        --backtitle "TERMUX LINUX TOOL" \
        --title " LINUX INSTALLER " \
        --menu "Choose an option:" 15 60 5 \
        1 "Install Linux Installer" \
        2 "Start Installation Linux" \
        0 "Exit" \
        2>&1 >/dev/tty
}

download_file() {
    local total status pid size percent

    # Get file size from server
    total=$(curl -fsIL "$URL" 2>/dev/null |
        tr -d '\r' |
        awk 'tolower($1)=="content-length:" {v=$2} END {print v}')

    if [[ ! "$total" =~ ^[0-9]+$ ]] || (( total <= 0 )); then
        dialog --msgbox \
            "Server did not provide a valid file size. Download cancelled." \
            7 55
        return
    fi

    rm -f "$FILE"

    # Start download in background
    curl -fL --silent --show-error \
        "$URL" -o "$FILE" \
        2>"$DIR/download-error.log" &
    pid=$!

    # Live progress gauge
    (
        while kill -0 "$pid" 2>/dev/null; do
            size=0

            if [[ -f "$FILE" ]]; then
                size=$(stat -c %s "$FILE" 2>/dev/null || echo 0)
            fi

            percent=$((size * 100 / total))

            if (( percent > 99 )); then
                percent=99
            fi

            echo "$percent"
            echo "XXX"
            echo "Downloading Linux Installer..."
            echo "$((size / 1048576)) MB / $((total / 1048576)) MB"
            echo "XXX"

            sleep 0.5
        done

        wait "$pid"
        status=$?

        if (( status == 0 )); then
            echo 100
            echo "XXX"
            echo "Download completed!"
            echo "XXX"
        fi
    ) | dialog --gauge "Starting download..." 9 65 0

    wait "$pid"
    status=$?

    if (( status == 0 )) && [[ -s "$FILE" ]] &&
        (( $(stat -c %s "$FILE") == total )); then

        dialog --msgbox \
            "Download completed successfully!" 7 50
    else
        rm -f "$FILE"
        dialog --msgbox \
            "Download failed or incomplete!\nCheck download-error.log" \
            8 55
    fi
}

restore_file() {
    local size pid status

    if [[ ! -f "$FILE" ]]; then
        dialog --msgbox \
            "Installer file not found! Download first." 7 50
        return
    fi

    # Validate archive
    if ! tar -tzf "$FILE" >/dev/null 2>&1; then
        dialog --msgbox \
            "Invalid TAR.GZ archive!" 7 50
        return
    fi

    # Only allow recognized Termux backup structure
    if ! tar -tzf "$FILE" |
        grep -Eq '^(home|usr)/'; then

        dialog --msgbox \
            "This is not a recognized Termux home/usr backup.\nRestore cancelled." \
            8 55
        return
    fi

    dialog --yesno \
        "Restore files into Termux?\n\nExisting files may be overwritten." \
        9 60

    [[ $? -ne 0 ]] && return

    size=$(stat -c %s "$FILE")

    if (( size <= 0 )); then
        dialog --msgbox "Backup file is empty!" 6 40
        return
    fi

    # Start restore pipeline
    pv -n -s "$size" "$FILE" 2>"$DIR/restore-progress.log" |
        tar -xzpf - -C "$TARGET" \
        2>"$DIR/restore-error.log" &

    pid=$!

    # Progress gauge
    (
        while kill -0 "$pid" 2>/dev/null; do
            local p

            p=$(tail -n 1 "$DIR/restore-progress.log" 2>/dev/null)
            p=${p:-0}
            p=${p%.*}

            [[ "$p" =~ ^[0-9]+$ ]] || p=0
            (( p > 99 )) && p=99

            echo "$p"
            echo "XXX"
            echo "Restoring Termux Backup..."
            echo "Please wait..."
            echo "XXX"

            sleep 0.3
        done
    ) | dialog --gauge "Restoring..." 9 60 0

    wait "$pid"
    status=$?

    if (( status == 0 )); then
        dialog --msgbox \
            "Restore completed successfully!\nRestart Termux to apply changes." \
            8 55
    else
        dialog --msgbox \
            "Restore failed!\nCheck restore-error.log" \
            8 50
    fi
}

# Main menu
while true; do
    CHOICE=$(menu) || break

    case "$CHOICE" in
        1)
            download_file
            ;;
        2)
            restore_file
            ;;
        0)
            break
            ;;
    esac
done

clear
