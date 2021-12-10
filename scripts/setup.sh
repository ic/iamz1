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
  exit 1
fi

read -p "[Optional] Please choose a pin number for the camera pan servo (default=12): " YAK_ROVER_CAM_PAN_PIN
if [[ -n $YAK_ROVER_CAM_PAN_PIN ]]
then
  sudo bash -c "echo YAK_ROVER_CAM_PAN_PIN=$YAK_ROVER_CAM_PAN_PIN >> /etc/environment"
fi

read -p "[Optional] Please choose a pin number for the camera tilt servo (default=13): " YAK_ROVER_CAM_TILT_PIN
if [[ -n $YAK_ROVER_CAM_TILT_PIN ]]
then
  sudo bash -c "echo YAK_ROVER_CAM_TILT_PIN=$YAK_ROVER_CAM_TILT_PIN >> /etc/environment"
fi

read -p "[Optional] Please choose a physical pin number for the bus RX (default=7): " YAK_ROVER_BUS_RX_PIN
if [[ -n $YAK_ROVER_BUS_RX_PIN ]]
then
  sudo bash -c "echo YAK_ROVER_BUS_RX_PIN=$YAK_ROVER_BUS_RX_PIN >> /etc/environment"
fi

read -p "[Optional] Please choose a physical pin number for the bus TX (default=13): " YAK_ROVER_BUS_TX_PIN
if [[ -n $YAK_ROVER_BUS_TX_PIN ]]
then
  sudo bash -c "echo YAK_ROVER_BUS_TX_PIN=$YAK_ROVER_BUS_TX_PIN >> /etc/environment"
fi

sudo apt-get update
sudo apt-get install -y \
	ffmpeg \
	libespeak1
	libssl-dev \
        libxml2-dev \
	pagekite \
	pigpiod \
	python3-pip

sudo systemctl start pigpiod
sudo systemctl enable pigpiod

pip3 install --user --quiet --requirement requirements.txt


#
# Prepare HiWonder code dependencies.
#
HIWONDER_HOME=~/tmp/hexapod
mkdir -p $HIWONDER_HOME
git clone https://gitlab.com/__ic/hexapod.git $HIWONDER_HOME
cp -r $HIWONDER_HOME/SpiderPi ~
rm -rf $HIWONDER_HOME


#
# Generation
#

# Generate CSV versions of action groups
for f in $(ls ~/SpiderPi/ActionGroups/*.d6a)
do
  python3 convertd6a2csv.py $f
done

# Prepare .env file
if [[ ! -f .env ]]
then
  cp .env.template .env
fi


#
# Final report, well, to manual operations for completing the setup.
#
echo
echo 'Please use `raspi-config` or directly modify configuration files to set system requirements:'
echo -e "\t* Activate the I2C interface (dtparam=i2c_arm=on)"
echo -e "\t* Enable UART in /boot/config.txt (enable_uart=1)"
echo -e "\t* Enable miniUART in /boot/config.txt (dtoverlay=pi3-miniuart-bt)"
echo -e "\t* Free serial on the console in /boot/cmdline.txt (remove \`console=serial0,115200\`)"
echo 'Please complete other configuration items:'
echo -e "\t* Edit \`~/test/iamz1/.env\` to fill in necessary values"
echo -e "\t* Prepare cron:"
echo -e "\t\t@reboot sleep 10 && nohup /usr/bin/python3 /home/pi/test/iamz1/iamz1.py &"
echo -e "\t\t@reboot sleep 20 && cd /home/pi/test/iamz1 && nohup /usr/bin/python3 logrpc.py &"
echo -e "\t\t@reboot sleep 20 && cd /home/pi/test/iamz1 && nohup /usr/bin/python3 legsrpc.py &"
echo -e "\t\t@reboot sleep 20 && cd /home/pi/test/iamz1 && /usr/bin/python3 ragrpc.py"
echo -e "\t\t@reboot sleep 20 && /usr/bin/python3 /home/pi/test/iamz1/testunload.py"
#echo -e "\t\t@reboot sleep 60 && /usr/bin/python3 /home/pi/test/Rover-Twitter/wokeup.py"
echo -e "\t\t@reboot sleep 60 && cd /home/pi/test/iamz1 && nohup /usr/bin/python3 webapp/app.py"
echo -e "\t\t@reboot sleep 120 && cd /home/pi/test/iamz1 &&  /bin/bash startpagekite <put password here>"
echo -e "\t\t@reboot /usr/sbin/openvpn --config /etc/openvpn/client.conf &"
