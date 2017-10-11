#!/bin/bash

echo "installing some dependencies"
sudo apt-get install -y docker.io python-websocket

echo "building docker image"
sudo docker build -t leap-docker ./leapdockerbuild

