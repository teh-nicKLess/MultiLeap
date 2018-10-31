#!/bin/bash

stop_containers() {
  ids=$(docker ps -q --filter ancestor=$docker_name)
  if [[ -n "${ids}" ]]; then
    echo "Stopping running leap docker container(s). Please wait."
    docker stop $ids
  fi
}


#################################
#################################
####                         ####
####  EXECUTION STARTS HERE  ####
####                         ####
#################################
#################################

# If there are still old leap containers running, stop them.
stop_containers

ws_starting_port=51000
docker_name="leap-docker"

# get device and bus of all connected leap motions
device_ids=($(lsusb | grep "Leap Motion Controller" | sed s/" Device "/"\/"/g | sed s/"Bus "//g | sed s/:[A-Za-z0-9[:space:]:]*$//g))

num_dev=${#device_ids[@]}
echo "Found [" $num_dev "] leap motion devices."


if (( num_dev < 1 )); then
  exit
fi


echo "Creating video devices"
declare -A video_ids
counter=1
devs="0"
for dev in "${device_ids[@]}"; do
	video_ids[$dev]=$counter
	devs=$devs","$counter
	counter=$((counter+1))
done

sudo modprobe -r v4l2loopback
sudo modprobe v4l2loopback video_nr=$devs

echo "---------------------------------------"

# run docker container for each leap
for dev in "${device_ids[@]}"; do
  echo "Starting docker for device" $dev
  echo docker run -d -e PORT=$ws_starting_port -e DEV=/dev/video${video_ids[$dev]} --device=/dev/bus/usb/$dev --device=/dev/video${video_ids[$dev]} $docker_name
  
	success=0
  
  while ((success == 0)); do
		# Run docker for current leap
		CID=$(docker run -d -e PORT=$ws_starting_port -e DEV=/dev/video${video_ids[$dev]} --device=/dev/bus/usb/$dev --device=/dev/video${video_ids[$dev]} $docker_name &)
  
		leap_ip=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' $CID)
  
		# Starting of leap tends to fail more often if not for the sleep
		# Also the python test script will throw a connection rrefused error
		echo "Waiting for initialization..."
		sleep 1
  
		# Test if docker and leap were started succesfully
		result=$(python ws_test.py $leap_ip $ws_starting_port)
		success=$?
		
		# If start was not successful, stop current docker before trying again
		if ((success == 0)); then
			echo "Initialization failed. Retrying..."
			id_last=$(docker ps -q --last 1 --filter ancestor=$docker_name)
			docker stop $id_last
		fi
		
	done
  
  echo "Started leap daemon on "$leap_ip":"$ws_starting_port" with video stream at /dev/video"${video_ids[$dev]}
  echo "---------------------------------------"
  ws_starting_port=$((ws_starting_port+1))
done


# docker should be stopped on exit
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

