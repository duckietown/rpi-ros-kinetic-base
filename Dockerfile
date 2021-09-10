ARG ARCH=arm32v7
ARG ROS_DISTRO=kinetic
ARG OS_DISTRO=xenial

FROM ${ARCH}/ros:${ROS_DISTRO}-ros-base-${OS_DISTRO}

ARG ARCH
ARG ROS_DISTRO
ARG OS_DISTRO

# switch on systemd init system in container
ENV INITSYSTEM off
ENV QEMU_EXECVE 1
# setup environment
ENV TERM "xterm"
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8
ENV ROS_DISTRO "${ROS_DISTRO}"
ENV OS_DISTRO "${OS_DISTRO}"

COPY ./assets/qemu/${ARCH}/ /usr/bin/

RUN [ "cross-build-start" ]

# install packages
RUN apt-get update && apt-get install -q -y \
        dirmngr \
        gnupg2 \
        sudo \
        apt-utils \
        apt-file \
        locales \
        locales-all \
        i2c-tools \
        net-tools \
        iputils-ping \
        man \
        ssh \
        htop \
        atop \
        iftop \
        iotop \
        less \
        lsb-release \
    && rm -rf /var/lib/apt/lists/*

# setup keys
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654

# setup sources.list
RUN echo "deb http://packages.ros.org/ros/ubuntu `lsb_release -sc` main" > /etc/apt/sources.list.d/ros-latest.list

# install additional ros packages
RUN apt-get update && apt-get install -y \
        ros-kinetic-robot \
        ros-kinetic-perception \
        ros-kinetic-navigation \
        ros-kinetic-robot-localization \
        ros-kinetic-roslint \
        ros-kinetic-hector-trajectory-server \
        ros-kinetic-joystick-drivers \
        ros-kinetic-rqt \
        ros-kinetic-rqt-common-plugins \
        ros-kinetic-web-video-server \
    && rm -rf /var/lib/apt/lists/*

# RPi libs
ADD vc.tgz /opt/
COPY 00-vmcs.conf /etc/ld.so.conf.d
RUN ldconfig

# development tools & libraries
RUN apt-get update && apt-get install --no-install-recommends -y \
        emacs \
        vim \
        byobu \
        zsh \
        libxslt-dev \
        libnss-mdns \
        libffi-dev \
        libturbojpeg \
        libblas-dev \
        liblapack-dev \
        libatlas-base-dev \
        docker.io \
        # Python Dependencies
        ipython \
        python-pip \
        python-wheel \
        python-sklearn \
        python-smbus \
        python-termcolor \
        python-tables \
        python-lxml \
        python-bs4 \
        python-catkin-tools \
        python-frozendict \
        python-ruamel.yaml \
        python-pymongo \
    && rm -rf /var/lib/apt/lists/*

RUN [ "cross-build-end" ]

# setup entrypoint
COPY ./assets/ros_entrypoint.sh /

ENTRYPOINT ["/ros_entrypoint.sh"]
CMD ["bash"]

LABEL maintainer="Breandan Considine breandan.considine@umontreal.ca"
