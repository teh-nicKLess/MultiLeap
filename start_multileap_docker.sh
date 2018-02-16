#!/bin/bash

# get device and bus of all connected leap motions
device_ids=($(lsusb | grep "Leap Motion Controller" | sed s/" Device "/"\/"/g | sed s/"Bus "//g | sed s/:[A-Za-z0-9[:space:]:]*$//g))
num_dev=${#device_ids[@]}
ws_starting_port=51000
docker_name="leap-docker"

stop_containers() {
  ids=$(docker ps -q --filter ancestor=$docker_name)
  if [[ -n "${ids}" ]]; then
    echo "stopping running leap docker container(s). Please wait."
    docker stop $ids
  fi
}

echo "found " $num_dev " leap motion devices."

if (( num_dev < 1 )); then
  exit
fi

echo "creating video devices"
declare -A videoIDs
cnt=1
devs="0"
for dev in "${device_ids[@]}"
do
videoIDs[$dev]=$cnt
devs=$devs","$cnt
cnt=$((cnt+1))
done

sudo modprobe -r v4l2loopback
sudo modprobe v4l2loopback video_nr=$devs

echo video_nr=$devs

# run docker container for each leap
for dev in "${device_ids[@]}"
do
  echo "starting docker for device" $dev
  echo docker run -d -e PORT=$ws_starting_port -e DEV=/dev/video${videoIDs[$dev]} --device=/dev/bus/usb/$dev --device=/dev/video${videoIDs[$dev]} $docker_name
  CID=$(docker run -d -e PORT=$ws_starting_port -e DEV=/dev/video${videoIDs[$dev]} --device=/dev/bus/usb/$dev --device=/dev/video${videoIDs[$dev]} $docker_name &)
  IP=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' $CID)	
  echo "started leap daemon on "$IP":"$ws_starting_port" with video stream at /dev/video"${videoIDs[$dev]}
  ws_starting_port=$((ws_starting_port+1))
done

# docker should be stoped on exit
trap ctrl_c SIGINT
function ctrl_c() {
  stop_containers
  exit
}

# just stay alive
while :
do
  sleep 1
done

