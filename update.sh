rm /etc/enigma2/userbouquet.Hispa.tv

mac=$(cat /sys/class/net/eth0/address)
mac=$(echo "$mac" | sed 's/://g' | tr '[:lower:]' '[:upper:]')
eid="HPL0$mac"

wget --no-check-certificate "https://e2manager.hispacam.workers.dev/enigma2/${eid}/userbouquet.Hispa.tv" -O /etc/enigma2/userbouquet.Hispa.tv
chmod 775 /etc/enigma2/userbouquet.Hispa.tv

wget --no-check-certificate "https://e2manager.hispacam.workers.dev/enigma2/${eid}/hispatv.sources.xml" -O /etc/epgimport/hispatv.sources.xml
chmod 775 /etc/epgimport/hispatv.sources.xml

wget --no-check-certificate "https://github.com/hispatv/hispatv/raw/refs/heads/main/plugin.pyc" -O /usr/lib/enigma2/python/Plugins/Extensions/HispaTV/plugin.pyc
wget --no-check-certificate "https://github.com/hispatv/hispatv/raw/refs/heads/main/plugin.png" -O /usr/lib/enigma2/python/Plugins/Extensions/HispaTV/plugin.png
chmod 775 /usr/lib/enigma2/python/Plugins/Extensions/HispaTV/plugin.pyc