#!/usr/bin/env bash

set -e

sudo apt-get update
sudo apt-get install -y \
	ffmpeg \
	libespeak1
	pagekite \
	pigpiod \
	python3-pip \

sudo systemctl start pigpiod
sudo systemctl enable pigpiod

pip3 install --user --quiet --requirement requirements.txt

read -p "Please choose a 3-letter rover name (must be unique): " RNAME
RNAME=$(echo $RNAME | tr "[:lower:]" "[:upper:]")
sudo bash -c "echo YAK_ROVER_NAME=$RNAME >> /etc/environment"

echo
echo 'Please use `raspi-config` to set system requirements:'
echo -e "\t* Activate the I2C interface (dtparam=i2c_arm=on)"
