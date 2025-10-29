#!/bin/sh

LOGFILE="/tmp/hispatv_update.log"
echo "=== HispaTV Update Script ===" > $LOGFILE
date >> $LOGFILE
rm /etc/enigma2/userbouquet.Hispa.tv

# Obtener el EID
if [ -f /sys/class/net/eth0/address ]; then
    mac=$(cat /sys/class/net/eth0/address)
else
    mac=$(cat /sys/class/net/wlan0/address 2>/dev/null)
fi

mac=$(echo "$mac" | sed 's/://g' | tr '[:lower:]' '[:upper:]')
eid="HPL0$mac"
echo "EID: $eid" >> $LOGFILE

# Asegurar directorios
mkdir -p /etc/enigma2 >> $LOGFILE 2>&1
mkdir -p /etc/epgimport >> $LOGFILE 2>&1

# Función para descargar con curl o wget
fetch() {
    url="$1"
    dest="$2"
    echo "Downloading: $url -> $dest" >> $LOGFILE
    if command -v curl >/dev/null 2>&1; then
        curl -k -L "$url" -o "$dest" >> $LOGFILE 2>&1
    else
        wget "$url" --no-check-certificate -O "$dest" >> $LOGFILE 2>&1
    fi
    if [ -f "$dest" ]; then
        chmod 775 "$dest"
        echo "OK: $dest downloaded" >> $LOGFILE
    else
        echo "ERROR: Failed to download $url" >> $LOGFILE
    fi
}

# Descargas
fetch "https://e2manager.hispacam.workers.dev/enigma2/$eid/userbouquet.Hispa.tv" "/etc/enigma2/userbouquet.Hispa.tv"
fetch "https://e2manager.hispacam.workers.dev/enigma2/$eid/hispatv.sources.xml" "/etc/epgimport/hispatv.sources.xml"
fetch "https://github.com/hispatv/hispatv/raw/refs/heads/main/plugin.pyc" "/usr/lib/enigma2/python/Plugins/Extensions/HispaTV/plugin.pyc"
fetch "https://github.com/hispatv/hispatv/raw/refs/heads/main/plugin.png" "/usr/lib/enigma2/python/Plugins/Extensions/HispaTV/plugin.png"

echo "Update completed at $(date)" >> $LOGFILE
exit 0
