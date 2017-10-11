
## Setup

add user to group docker:

    sudo usermod -aG docker $USER

install packages:

    docker.io
    python-websocket

build docker image:

    docker build -t leap-docker ./leapdockerbuild

or run setup.h

## Start

run start_multileap_docker.sh


## Connect

To test the connection run test_connection.py <host> <port>
