FROM ubuntu:16.04
COPY Leap-2.3.1+33747-x64.deb /Leap-2.3.1+33747-x64.deb
RUN apt-get -y update && apt-get install -y libgl1-mesa-glx libglu1-mesa libxi6 libdbus-1-3
RUN dpkg -i Leap-2.3.1+33747-x64.deb 
CMD leapd --websockets_allow_remote=True --ws_port=$PORT

