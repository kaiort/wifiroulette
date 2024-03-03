#!/bin/bash

# Pfad zum aktuellen Verzeichnis
verzeichnis="$(dirname "$(readlink -f "$0")")"

# Prüfen, ob das Skript mit Root-Rechten ausgeführt wird
if [ "$(id -u)" -ne 0 ]; then
    echo "Dieses Skript muss mit Root-Rechten ausgeführt werden. Bitte fügen Sie sudo hinzu."
    exit 1
fi

# Standard-SSID für den Access Point
ssid="MeinAP"

# Pakete installieren
apt-get update
apt-get install -y hostapd dnsmasq

# Hostapd-Konfigurationsdatei erstellen
cat > /etc/hostapd/hostapd.conf <<EOF
interface=wlan0
driver=nl80211
ssid=$ssid
hw_mode=g
channel=6
wmm_enabled=0
macaddr_acl=0
auth_algs=1
ignore_broadcast_ssid=0
EOF

# Dnsmasq-Konfigurationsdatei erstellen
cat > /etc/dnsmasq.conf <<EOF
interface=wlan0
dhcp-range=192.168.4.2,192.168.4.20,255.255.255.0,24h
EOF

# Netzwerkkonfiguration bearbeiten
cat >> /etc/network/interfaces <<EOF

allow-hotplug wlan0
iface wlan0 inet static
    address 192.168.4.1
    netmask 255.255.255.0
EOF

# Wechselskript kopieren
cp wechsler.sh /usr/local/bin/wechsler.sh
chmod +x /usr/local/bin/wechsler.sh

# Systemd Service Unit erstellen
cat > /etc/systemd/system/wechsler.service <<EOF
[Unit]
Description=Wechsler Skript
After=network.target

[Service]
ExecStart=/usr/local/bin/wechsler.sh $verzeichnis/ssid_list.txt
Type=simple
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Systemd Konfiguration neu laden und Service aktivieren
systemctl daemon-reload
systemctl enable wechsler.service

# Hostapd und Dnsmasq starten
systemctl unmask hostapd
systemctl enable hostapd
systemctl start hostapd
systemctl enable dnsmasq
systemctl start dnsmasq

echo "Access Point wurde erfolgreich eingerichtet und wird bei jedem Start des Computers gestartet."
