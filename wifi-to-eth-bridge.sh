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

sudo iptables -F
sudo iptables -t nat -F

sudo sh -c "echo 1 > /proc/sys/net/ipv4/ip_forward"

sudo killall parprouted
sudo systemctl stop dhcp-helper
sudo killall dhcp-helper
sudo systemctl stop avahi-daemon
sudo killall avahi-daemon

option=$(cat /etc/avahi/avahi-daemon.conf | grep enable-reflector=yes)

cp /etc/avahi/avahi-daemon.conf /tmp/avahi-daemon.conf

if [ $option=="" ]; then
	echo -e '\n[reflector]\nenable-reflector=yes\n' >> /tmp/avahi-daemon.conf
fi

sudo /usr/sbin/parprouted $eth $wlan &

sudo /usr/sbin/dhcp-helper -r /var/run/dhcp-helper.pid -b $wlan &

sudo ip addr flush dev $eth

sudo /sbin/ip addr add $(/sbin/ip addr show $wlan | perl -wne 'm|^\s+inet (.*)/| && print $1')/32 dev $eth &

sleep 2

avahi-daemon -f /tmp/avahi-daemon.conf &
