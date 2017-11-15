#!/bin/bash

# Share Wifi with Eth device
#
#
# This script is created to work with Raspbian Stretch
# but it can be used with most of the distributions
# by making few changes. 
#
# Make sure you have already installed `dnsmasq`
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

sudo iptables -F
sudo iptables -t nat -F
sudo iptables -t nat -A POSTROUTING -o $wlan -j MASQUERADE  
sudo iptables -A FORWARD -i $wlan -o $eth -m state --state RELATED,ESTABLISHED -j ACCEPT  
sudo iptables -A FORWARD -i $eth -o $wlan -j ACCEPT 

sudo sh -c "echo 1 > /proc/sys/net/ipv4/ip_forward"

sudo ifconfig $eth $ip_address netmask $netmask

sudo ip route del 0/0 dev $eth &> /dev/null
a=`route | awk "/${wlan}/"'{print $5+1;exit}'`
sudo route add -net default gw $ip_address netmask 0.0.0.0 dev $eth metric $a

echo -e "interface=$eth \n\
bind-interfaces \n\
server=8.8.8.8 \n\
domain-needed \n\
bogus-priv \n\
dhcp-range=$dhcp_range_start,$dhcp_range_end,$dhcp_time" > /etc/dnsmasq.conf

sudo systemctl start dnsmasq
