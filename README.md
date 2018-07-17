# Raspian Recipes

This repo contains various scripts to configure for Raspberry Pi. They can also be used with other Linux distributions by making slight changes.

If you want to make your raspberry pi a router or something than you won't have to spent days to make it work. You just have to grab right recipe and put it in correct place and install few basic packages.

## How to use them

First, install `dnsmasq` because it the backbone of most of the recipes.

    sudo apt-get update && sudo apt-get install dnsmasq

List of all recipes with descriptions:

 - [wifi-to-eth-route.sh](wifi-to-eth-route.sh) — Share Raspberry WiFi with the device on Lan side.
Give WiFi access to a Non-WiFi device.

 - [eth-to-wifi-route.sh](eth-to-wifi-route.sh) — Make it WiFi Router.

 - [wifi-to-eth-bridge.sh](wifi-to-eth-bridge.sh) — A layer 3 solution. See #2 for discussion.

Download a recipe to `pi` user's home directory. For example:

    curl -O https://raw.githubusercontent.com/arpitjindal97/raspbian-recipes/master/wifi-to-eth-route.sh

Make the file executable:

    sudo chmod 755 wifi-to-eth-route.sh

If using LXDE desktop, edit `/home/pi/.config/lxsession/LXDE-pi/autostart`:

    nano /home/pi/.config/lxsession/LXDE-pi/autostart

And add the last line to start the script automatically after reboot:

    @lxpanel --profile LXDE-pi
    @pcmanfm --desktop --profile LXDE-pi
    @xscreensaver -no-splash
    @point-rpi
    sudo bash /home/pi/wifi-to-eth-route.sh

Without desktop (lite version), edit `/etc/rc.local` with root privilege:

    sudo nano /etc/rc.local

And add the following before `exit 0` to start script automatically after reboot:

    bash /home/pi/wifi-to-eth-route.sh

Be sure to give full path to the file.<br>
That's it! Reboot to see the changes.

    sudo reboot

There are few things which can't be automated and has to be done manually. Below are some tips to help you get stuff done.

# Tips

## Enable SSH

When you have written the Image file on to the SD Card. Mount the `boot` partition and create a file named `ssh`.
Eject the card. Start the Raspberry Pi. You will be able to have SSH connection to it.
After boot the `/boot/ssh` file gets deleted automatically. So, type this to start `ssh service` on every boot.

    sudo systemctl enable ssh

## WiFi Connection

Connect to RPi through SSH by providing it Ethernet.
If you don't any Lan cable lying around than plug the SD card into PC. Mount the second partition of the SD Card.

WiFi connections are stored at `/etc/wpa_supplicant/wpa_supplicant.conf`. Edit this file with `root` privilege:

    sudo nano /etc/wpa_supplicant/wpa_supplicant.conf

It should look like this after filling network details:

    country=GB
    ctrl_interface=/var/run/wpa_supplicant
    update_config=1
    network={
        ssid="Home WiFi"
        psk="password_goes_here"
    }

Configuration for eap should look like this:

    network={
            ssid="SSID_NAME"
            key_mgmt=WPA-EAP
            password="PASSWORD"
            eap=PEAP
            identity="USERNAME"
    }

Suggestions and PRs are welcome to make these recipes more useful.
