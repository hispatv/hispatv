echo "Installing HispaTV Plugin..."
echo '#SERVICE 1:7:1:0:0:0:0:0:0:0:FROM BOUQUET "userbouquet.Hispa.tv" ORDER BY bouquet' >> /etc/enigma2/bouquets.tv
mkdir /usr/lib/enigma2/python/Plugins/Extensions/HispaTV
wget --no-check-certificate "https://github.com/hispatv/hispatv/raw/refs/heads/main/plugin.pyc" -O /usr/lib/enigma2/python/Plugins/Extensions/HispaTV/plugin.pyc
wget --no-check-certificate "https://raw.githubusercontent.com/hispatv/hispatv/refs/heads/main/update.sh" -O /usr/lib/enigma2/python/Plugins/Extensions/HispaTV/update.sh
wget --no-check-certificate "https://github.com/hispatv/hispatv/raw/refs/heads/main/plugin.png" -O /usr/lib/enigma2/python/Plugins/Extensions/HispaTV/plugin.png
chmod 775 /usr/lib/enigma2/python/Plugins/Extensions/HispaTV/plugin.pyc
chmod 775 /usr/lib/enigma2/python/Plugins/Extensions/HispaTV/update.sh
echo "Installation completed. Rebooting the system..."
reboot