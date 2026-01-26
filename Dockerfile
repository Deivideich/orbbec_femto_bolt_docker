ARG ROS_DISTRO=humble
FROM osrf/ros:${ROS_DISTRO}-desktop

ENV DEBIAN_FRONTEND=noninteractive
ENV RMW_IMPLEMENTATION=rmw_cyclonedds_cpp
ENV ROS_DOMAIN_ID=0

RUN apt update && apt install -y software-properties-common && \
    add-apt-repository universe && \
    apt update

RUN apt install -y \
    git \
    wget \
    curl \
    udev \
    libusb-1.0-0-dev \
    libgl1 \
    libglib2.0-0 \
    libgflags-dev \
    libgoogle-glog-dev \
    nlohmann-json3-dev \
    libdw-dev \
    python3-colcon-common-extensions \
    python3-rosdep \
    && rm -rf /var/lib/apt/lists/*

RUN apt update && apt install -y \
    ros-${ROS_DISTRO}-image-pipeline \
    ros-${ROS_DISTRO}-diagnostics \
    ros-${ROS_DISTRO}-vision-opencv \
    ros-${ROS_DISTRO}-image-transport \
    ros-${ROS_DISTRO}-rmw-cyclonedds-cpp \
    && rm -rf /var/lib/apt/lists/*

# Orbbec SDK v2
WORKDIR /tmp
RUN wget https://github.com/orbbec/OrbbecSDK_v2/releases/download/v2.4.8/OrbbecSDK_v2.4.8_amd64.deb && \
    dpkg -i OrbbecSDK_v2.4.8_amd64.deb && \
    rm OrbbecSDK_v2.4.8_amd64.deb

WORKDIR /ros2_ws
RUN mkdir -p src

# backward_ros
RUN git clone https://github.com/pal-robotics/backward_ros.git src/backward_ros

# Orbbec ROS 2 driver
RUN git clone https://github.com/orbbec/OrbbecSDK_ROS2.git src/orbbec_camera

RUN rosdep init || true && rosdep update

RUN bash -c "source /opt/ros/${ROS_DISTRO}/setup.bash && \
    rosdep install --from-paths src --ignore-src -r -y"

RUN bash -c "source /opt/ros/${ROS_DISTRO}/setup.bash && \
    colcon build --symlink-install"

COPY fastrtps_profile.xml /tmp/fastrtps_profile.xml
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

CMD ["ros2", "launch", "orbbec_camera", "femto_bolt.launch.py"]
