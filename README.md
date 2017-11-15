# Raspbian Recipes

This repo contains various scripts to configure for Raspberry Pi. 
They can also be used with other Linux distributions by making slight changes.

If you want to make your raspberry pi a router or something than you won't have to spent days to make it work. 
You just have to grab right recipe and put it in correct place and install few basic packages. 

## How to use them

First of all, make sure you have install `dnsmasq` because it the backbone of most of the recipes.

    sudo apt-get update && sudo apt-get install dnsmasq
    
List of all recipes with decriptions

 - [wifi-to-eth-route.sh](wifi-to-eth-route.sh)  -   Share Raspberry WiFi with the device on Lan side.
Give WiFi access to a Non-WiFi device.

 - [eth-to-wifi-route.sh](eth-to-wifi-route.sh)  -   Make it WiFi Router. (Will be available soon)


Download them on to Raspberry. Please them at `/home/pi/`. 

Open up `/home/pi/.config/lxsession/LXDE-pi/autostart` file

    nano /home/pi/.config/lxsession/LXDE-pi/autostart
    
 Add the last line :
 
    @lxpanel --profile LXDE-pi
    @pcmanfm --desktop --profile LXDE-pi
    @xscreensaver -no-splash
    @point-rpi
    sudo bash /home/pi/wifi-to-eth-route.sh

Make sure you give full path to the file.
And you're done. Now reboot to see the changes

    sudo reboot

There are few things which can't be automated and has to be done manually. 
Below are some tutorials to help you get things done

# Tips

## Enable SSH

When you have written the Image file on to the SD Card. Mount the `boot` partition and create a file named `ssh`.
Eject the card. Start the Raspberry Pi. You will be able to have SSH connection to it.
After boot the `/boot/ssh` file gets deleted automatically. So, type this to start `ssh service` on every boot.

    sudo systemctl enable ssh
    
## WiFi Connection

Connect to RPi through SSH by providing it Ethernet. 
If you don't any Lan cable lying around than plug the SD card into PC. Mount the second partition of the SD Card.

WiFi connections are stored at `/etc/wpa_supplicant/wpa_supplicant.conf`. Edit this file with `root` priviliege 

    sudo nano /etc/wpa_supplicant/wpa_supplicant.conf
    
It should look like this after filling network details

    country=GB
    ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
    update_config=1
    network={
        ssid="Home WiFi"
        psk="password_goes_here"
    }
    
Any Suggestions and PRs are welcomed to make these recepies more useful.
