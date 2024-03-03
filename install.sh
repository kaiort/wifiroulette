#!/bin/bash

# Prüfen, ob das Skript mit Root-Rechten ausgeführt wird
if [ "$(id -u)" -ne 0 ]; then
    echo "Dieses Skript muss mit Root-Rechten ausgeführt werden. Bitte fügen Sie sudo hinzu."
    exit 1
fi

# Standard-SSID für den Access Point
ssid="wifiroulette"

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

# Wechselskript in den Autostart einbinden
skript_pfad="$(dirname "$(readlink -f "$0")")/wechsler.sh"
sed -i "/^exit 0/i ( cd $(dirname "$skript_pfad") && sudo bash wechsler.sh ) &" /etc/rc.local

# Netzwerkmanager deaktivieren
systemctl stop NetworkManager
systemctl disable NetworkManager

# Hostapd und Dnsmasq starten
systemctl unmask hostapd
systemctl enable hostapd
systemctl start hostapd
systemctl enable dnsmasq
systemctl start dnsmasq

echo "Access Point wurde erfolgreich eingerichtet und wird bei jedem Start des Computers gestartet."
