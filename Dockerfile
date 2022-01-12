# vim:set ft=dockerfile:
FROM debian:10

# Source Dockerfile:
# https://github.com/docker-library/postgres/blob/master/9.4/Dockerfile

RUN apt-get update && apt-get install -y gnupg2 gnupg gnupg1

# explicitly set user/group IDs
RUN groupadd -r freeswitch --gid=999 && useradd -r -g freeswitch --uid=999 freeswitch

# grab gosu for easy step-down from root
#RUN gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4  7D2BAF1CF37B13E2069D6956105BD0E739499BDB

#RUN gpg --keyserver keyserver.ubuntu.com --recv-key 409B6B1796C275462A1703113804BB82D39DC0E3
RUN gpg --keyserver keyserver.ubuntu.com --recv-key 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB


#RUN gpg --keyserver hkp://pgp.mit.edu --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB


COPY gosu-amd64 /usr/local/bin/gosu
COPY gosu-amd64.asc /usr/local/bin/gosu.asc 

RUN apt-get update && apt-get install -y  wget   && apt-get install -y lsb-base lsb-release   && rm -rf /var/lib/apt/lists/* 

#&& gpg --verify /usr/local/bin/gosu.asc \
    
#&& rm /usr/local/bin/gosu.asc \
#&& chmod +x /usr/local/bin/gosu
    
#&& apt-get purge -y --auto-remove ca-certificates wget

# make the "en_US.UTF-8" locale so freeswitch will be utf-8 enabled by default
RUN apt-get update && apt-get install -y locales && rm -rf /var/lib/apt/lists/* \
    && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.utf8

# https://files.freeswitch.org/repo/deb/freeswitch-1.*/dists/jessie/main/binary-amd64/Packages

ENV FS_MAJOR debian-unstable

RUN sed -i "s/jessie main/jessie main contrib non-free/" /etc/apt/sources.list

# https://freeswitch.org/confluence/display/FREESWITCH/Debian+8+Jessie#Debian8Jessie-InstallingfromDebianpackages

RUN apt-get update && apt-get install -y curl \
    && curl https://files.freeswitch.org/repo/deb/debian/freeswitch_archive_g0.pub | apt-key add - \
    && echo "deb http://files.freeswitch.org/repo/deb/debian-unstable/ `lsb_release -sc` main" > /etc/apt/sources.list.d/freeswitch.list \
    &&   echo "deb-src http://files.freeswitch.org/repo/deb/debian-unstable/ `lsb_release -sc` main" >> /etc/apt/sources.list.d/freeswitch.list \
    #&& echo "deb http://files.freeswitch.org/repo/deb/$FS_MAJOR/ jessie main" > /etc/apt/sources.list.d/freeswitch.list \
    && apt-get purge -y --auto-remove curl

RUN apt-get update && apt-get install -y freeswitch-all \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Clean up
RUN apt-get autoremove

COPY docker-entrypoint.sh /
# Add anything else here

## Ports
# Open the container up to the world.
### 8021 fs_cli, 5060 5061 5080 5081 sip and sips, 64535-65535 rtp
EXPOSE 8021/tcp
EXPOSE 5060/tcp 5060/udp 5080/tcp 5080/udp
EXPOSE 5061/tcp 5061/udp 5081/tcp 5081/udp
EXPOSE 7443/tcp
EXPOSE 5070/udp 5070/tcp
EXPOSE 64535-65535/udp
EXPOSE 16384-32768/udp


# Volumes
## Freeswitch Configuration
VOLUME ["/etc/freeswitch"]
## Tmp so we can get core dumps out
VOLUME ["/tmp"]

# Limits Configuration
COPY    build/freeswitch.limits.conf /etc/security/limits.d/

# Healthcheck to make sure the service is running
SHELL       ["/bin/bash"]
HEALTHCHECK --interval=15s --timeout=5s \
    CMD  fs_cli -x status | grep -q ^UP || exit 1

ENTRYPOINT ["/docker-entrypoint.sh"]


CMD ["freeswitch"]
