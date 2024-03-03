#!/bin/bash

# Pfad zur Datei mit den SSID-Namen
ssid_file="ssid_list.txt"

# Überprüfen, ob die Datei existiert
if [ ! -f "$ssid_file" ]; then
    echo "Die Datei mit den SSID-Namen ($ssid_file) existiert nicht."
    exit 1
fi

# Endlose Schleife
while true; do
    # Schleife zum Lesen der SSID-Namen aus der Datei
    while read -r ssid_name || [[ -n "$ssid_name" ]]; do
        # Konfigurationsdatei für Hostapd erstellen
        cat > /etc/hostapd/hostapd.conf <<EOF
interface=wlan0
driver=nl80211
ssid=$ssid_name
hw_mode=g
channel=6
wmm_enabled=0
macaddr_acl=0
auth_algs=1
ignore_broadcast_ssid=0
EOF

        # Hostapd-Dienst neu starten
        sudo systemctl restart hostapd

        # Warte 60 Sekunden
        sleep 10
    done < "$ssid_file"
done
