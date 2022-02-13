#!/bin/bash

# Share Eth with WiFi Hotspot
#
# This script is created to work with Raspbian Stretch
# but it can be used with most of the distributions
# by making few changes.
#
# Make sure you have already installed `dnsmasq` and `hostapd`
# Please modify the variables according to your need
# Don't forget to change the name of network interface
# Check them with `ifconfig`

ip_address="192.168.2.1"
netmask="255.255.255.0"
dhcp_range_start="192.168.2.2"
dhcp_range_end="192.168.2.100"
dhcp_time="12h"
eth="eth0"
wlan="wlan0"
ssid="Raspberry-Hotspot"
psk="raspberry"

which dnsmasq > /dev/null
if [ $? = 1 ]
then
  echo "Please install dnsmasq"
  echo " $ sudo apt-get install dnsmasq"
  exit 1
fi
which hostapd > /dev/null
if [ $? = 1 ]
then
  echo "Please install hostapd"
  echo " $ sudo apt-get install hostapd"
  exit 1
fi
echo "Dependencies installed"



sudo killall wpa_supplicant &> /dev/null
sudo rfkill unblock wlan &> /dev/null
sleep 2

sudo systemctl start network-online.target

sudo iptables -F
sudo iptables -t nat -F
sudo iptables -t nat -A POSTROUTING -o $eth -j MASQUERADE
sudo iptables -A FORWARD -i $eth -o $wlan -m state --state RELATED,ESTABLISHED -j ACCEPT
sudo iptables -A FORWARD -i $wlan -o $eth -j ACCEPT

sudo sh -c "echo 1 > /proc/sys/net/ipv4/ip_forward"

sudo ifconfig $wlan $ip_address netmask $netmask

# Remove default route
sudo ip route del 0/0 dev $wlan &> /dev/null

sudo rm -rf /etc/dnsmasq.d/* &> /dev/null

echo -e "interface=$wlan \n\
bind-interfaces \n\
server=176.103.130.130 \n\
domain-needed \n\
bogus-priv \n\
dhcp-range=$dhcp_range_start,$dhcp_range_end,$dhcp_time" > /etc/dnsmasq.d/custom-dnsmasq.conf

sudo systemctl restart dnsmasq

echo -e "interface=$wlan\n\
driver=nl80211\n\
ssid=$ssid\n\
hw_mode=g\n\
ieee80211n=1\n\
wmm_enabled=1\n\
macaddr_acl=0\n\
ht_capab=[HT40][SHORT-GI-20][DSSS_CCK-40]\n\
channel=6\n\
auth_algs=1\n\
ignore_broadcast_ssid=0\n\
wpa=2\n\
wpa_key_mgmt=WPA-PSK\n\
wpa_passphrase=$psk\n\
rsn_pairwise=CCMP" > /etc/hostapd/hostapd.conf

sudo systemctl stop hostapd
sudo hostapd /etc/hostapd/hostapd.conf &
