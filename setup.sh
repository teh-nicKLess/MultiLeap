#!/bin/bash

echo "installing some dependencies"
sudo apt-get install -y docker.io python-websocket v4l2loopback-utils cmake

echo "creating image exposer"
cd exposeImages && mkdir build && cd build && cmake .. && make && cd ../..

echo "building docker image"
cp exposeImages/build/exposeImages leapdockerbuild
docker build -t leap-docker ./leapdockerbuild

