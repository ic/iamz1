#!/usr/bin/env bash

set -e

already_set=$(cat /etc/environment | grep YAK_ROVER_NAME)
if [[ -z $already_set ]]
then
  read -p "Please choose a 3-letter rover name (must be unique): " RNAME
  RNAME=$(echo $RNAME | tr "[:lower:]" "[:upper:]")
  sudo bash -c "echo YAK_ROVER_NAME=$RNAME >> /etc/environment"
else
  echo "YAK_ROVER_NAME already set in /etc/environment. Unsure whether safe to continue, aborting."
  #exit 1
fi

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

echo
echo 'Please use `raspi-config` or directly modify configuration files to set system requirements:'
echo -e "\t* Activate the I2C interface (dtparam=i2c_arm=on)"
echo -e "\t* Enable UART in /boot/config.txt (enable_uart=1)"
echo -e "\t* Enable miniUART in /boot/config.txt (dtoverlay=pi3-miniuart-bt)"
echo -e "\t* Free serial on the console in /boot/cmdline.txt (remove \`console=serial0,115200\`)"
echo 'Please complete other configuration items:'
echo -e "\t* Copy \`~/test/iamz1/.env.template\` to \`~/test/iamz1/.env\`, and fill in necessary values"
echo -e "\t* Prepare cron:"
echo -e "\t\t@reboot sleep 10 && nohup /usr/bin/python3 /home/pi/test/iamz1/iamz1.py &"
echo -e "\t\t@reboot sleep 20 && cd /home/pi/test/iamz1 && nohup /usr/bin/python3 logrpc.py &"
echo -e "\t\t@reboot sleep 20 && cd /home/pi/test/iamz1 && nohup /usr/bin/python3 legsrpc.py &"
echo -e "\t\t@reboot sleep 20 && cd /home/pi/test/iamz1 && /usr/bin/python3 ragrpc.py"
echo -e "\t\t@reboot sleep 20 && /usr/bin/python3 /home/pi/test/iamz1/testunload.py"
echo -e "\t\t@reboot sleep 60 && /usr/bin/python3 /home/pi/test/Rover-Twitter/wokeup.py"
echo -e "\t\t@reboot sleep 60 && cd /home/pi/test/iamz1 && nohup /usr/bin/python3 webapp/app.py"
echo -e "\t\t@reboot sleep 120 && cd /home/pi/test/iamz1 &&  /bin/bash startpagekite <put password here>"
echo -e "\t\t@reboot /usr/sbin/openvpn --config /etc/openvpn/client.conf &"
