#!/bin/bash

# Bridge WiFi with Ethernet
# Internet source is wlan0
# wpa_supplicant will be running on wlan0
#
# This is Layer 3 proxy arp solution
#
# This script is made to work with Raspbian Stretch
# but it can be used with most of the distributions
# by making few changes.
#
# Make sure you have already installed:
# 	avahi-daemon
# 	parprouted
#	dhcp-helper
#
# Just install these packages and don't touch
# any configuration file. This script will handle
# required options dynamically.
#
# Configure your wpa_supplicant prior to this script
#

eth="eth0"
wlan="wlan0"

sudo systemctl start network-online.target &> /dev/null

sudo iptables -F
sudo iptables -t nat -F

sudo sh -c "echo 1 > /proc/sys/net/ipv4/ip_forward"

echo "Killing parprouted "
sudo killall parprouted &> /dev/null
echo "Stopping dhcp-helper service"
sudo systemctl stop dhcp-helper
echo "Killing dhcp-helper"
sudo killall dhcp-helper &> /dev/null
echo "Stopping avahi-daemon service"
sudo systemctl stop avahi-daemon
echo "Killing avahi-daemon"
sudo killall avahi-daemon &> /dev/null

option=$(cat /etc/avahi/avahi-daemon.conf | grep enable-reflector=yes)

echo "Creating temp avahi conf file"
cp /etc/avahi/avahi-daemon.conf /tmp/avahi-daemon.conf

if [ $option=="" ]; then
	echo -e '\n[reflector]\nenable-reflector=yes\n' >> /tmp/avahi-daemon.conf
fi

echo "Starting parprouted ..."
sudo /usr/sbin/parprouted $eth $wlan &

echo "Starting dhcp-helper ..."
sudo /usr/sbin/dhcp-helper -r /var/run/dhcp-helper.pid -b $wlan &

echo "Flushing $eth IP addr"
sudo ip addr flush dev $eth

echo "Assigning IP to $eth from $wlan"
sudo /sbin/ip addr add $(/sbin/ip addr show $wlan | perl -wne 'm|^\s+inet (.*)/| && print $1')/32 dev $eth &

sleep 2

echo "Starting avahi-daemon ... "
avahi-daemon -f /tmp/avahi-daemon.conf &
