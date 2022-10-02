FROM ubuntu

WORKDIR /tmp/stormsh
COPY . .
RUN apt update && apt install -y coreutils awk make install
RUN make install
WORKDIR /root

ENTRYPOINT /bin/bash

# This Docker file using just for tests of the project
# there is nothing to implemental.