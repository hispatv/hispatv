echo "Checking for EPGImport plugin..."

EPGIMPORT_DIR="/etc/epgimport"

if [ -d "$EPGIMPORT_DIR" ]; then
    echo "EPGImport is installed."
else
    echo "EPGImport is NOT installed. Istalling Dorik's EPGImport mod."
    wget --no-check-certificate "https://github.com/hispatv/hispatv/blob/main/enigma2-plugin-EPGImport-mod.ipk" -O /tmp/enigma2-plugin-EPGImport-mod.ipk
    opkg install --force-reinstall --force-overwrite /tmp/enigma2-plugin-EPGImport-mod.ipk
fi

echo "Installing HispaTV Plugin..."

# Línea que queremos insertar
LINE='#SERVICE 1:7:1:0:0:0:0:0:0:0:FROM BOUQUET "userbouquet.Hispa.tv" ORDER BY bouquet'
FILE="/etc/enigma2/bouquets.tv"

# Comprobar si la línea ya existe
if ! grep -Fxq "$LINE" "$FILE"; then
    echo "$LINE" >> "$FILE"
fi

# Crear directorio del plugin
mkdir -p /usr/lib/enigma2/python/Plugins/Extensions/HispaTV

# Descargar archivos
wget --no-check-certificate "https://github.com/hispatv/hispatv/raw/refs/heads/main/plugin.pyc" -O /usr/lib/enigma2/python/Plugins/Extensions/HispaTV/plugin.pyc
wget --no-check-certificate "https://raw.githubusercontent.com/hispatv/hispatv/refs/heads/main/update.sh" -O /usr/lib/enigma2/python/Plugins/Extensions/HispaTV/update.sh
wget --no-check-certificate "https://github.com/hispatv/hispatv/raw/refs/heads/main/plugin.png" -O /usr/lib/enigma2/python/Plugins/Extensions/HispaTV/plugin.png

# Cambiar permisos
chmod 775 /usr/lib/enigma2/python/Plugins/Extensions/HispaTV/plugin.pyc
chmod 775 /usr/lib/enigma2/python/Plugins/Extensions/HispaTV/update.sh

echo "Installation completed. Rebooting the system..."
reboot
