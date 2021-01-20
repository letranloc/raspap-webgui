#!/bin/bash

function do_routed_mode() {
  sudo systemctl disable systemd-networkd

  sudo sed -i "s/^.*#BRIDGED$/#&/" /etc/dhcpcd.conf
  sudo sed -i "s/^bridge/#&/" /etc/hostapd/hostapd.conf

  sudo ip link set down br0
  sudo ip link del dev br0
}

function do_bridged_mode() {
  sudo sed -i "s/^#\(.*#BRIDGED\)$/\1/" /etc/dhcpcd.conf
  sudo sed -i "s/^#\(bridge\)/\1/" /etc/hostapd/hostapd.conf

  sudo ip link set down eth0
  sudo ip link set up eth0

  sudo systemctl start systemd-networkd
  sudo systemctl enable systemd-networkd
}

sudo systemctl stop systemd-networkd
sudo service hostapd stop
sudo service dhcpcd stop
sudo service dnsmasq stop

if [ "$1" = "force-routed" ]
then do_routed_mode
elif [ "$1" = "force-bridged" ]
then do_bridged_mode
elif ip addr show br0 | grep 'inet ' > /dev/null
then do_routed_mode
elif ! ip addr show br0 | grep 'inet ' > /dev/null
then do_bridged_mode
fi

sudo service hostapd start
sudo service dhcpcd start
sudo service dnsmasq start
