#!/usr/bin/env bash

sudo apt-get install pagekite ffmpeg python3-pip pigpiod libespeak1

sudo systemctl start pigpiod
sudo systemctl enable pigpiod

pip3 install --user --requirement requirements.txt

echo 'Please use `raspi-config` to set system requirements:'
echo -e "\t* Activate the I2C interface (dtparam=i2c_arm=on)"
