#!/bin/bash

# get device and bus of all connected leap motions
device_ids=($(lsusb | grep "Leap Motion Controller" | sed s/" Device "/"\/"/g | sed s/"Bus "//g | sed s/:[A-Za-z0-9[:space:]:]*$//g))
num_dev=${#device_ids[@]}
ws_starting_port=51000

echo "found " $num_dev " leap motion devices."

if (( num_dev < 1 )); then
  exit
fi

echo "killing running daemons (host)"
sudo killall -9 leapd

ids=$(sudo docker ps -a -q)
if [[ -z "${ids// }" ]]; then
  echo "stopping all docker containers"
  sudo docker stop $ids
fi

# run docker container for each leap
for dev in "${device_ids[@]}"
do
  echo "starting docker for device" $dev
  CID=$(sudo docker run -d -e PORT=$ws_starting_port --device=/dev/bus/usb/$dev leap-docker &)
  IP=$(sudo docker inspect --format '{{ .NetworkSettings.IPAddress }}' $CID)	
  echo "started leap daemon on " $IP " at port " $ws_starting_port
  ws_starting_port=$((ws_starting_port+1))
done

# docker should be stoped on exit
trap ctrl_c SIGINT
function ctrl_c() {
  echo "stopping all docker containers, please wait..."
  sudo docker stop $(sudo docker ps -a -q)
  exit
}

# just stay alive
while :
do
  sleep 1
done

