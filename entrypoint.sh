#!/bin/bash
set -e

# Set ROS 2 environment variables for proper communication
export ROS_DOMAIN_ID=${ROS_DOMAIN_ID:-0}
export RMW_IMPLEMENTATION=${RMW_IMPLEMENTATION:-rmw_fastrtps_cpp}
export FASTRTPS_DEFAULT_PROFILES_FILE=${FASTRTPS_DEFAULT_PROFILES_FILE:-/tmp/fastrtps_profile.xml}

source /opt/ros/humble/setup.bash
source /ros2_ws/install/setup.bash

exec "$@"
