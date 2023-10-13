FROM osrf/ros:humble-desktop-full AS rover_image


# FROM osrf/ros:humble-desktop

# nvidia-container-runtime
ENV NVIDIA_VISIBLE_DEVICES \
    ${NVIDIA_VISIBLE_DEVICES:-all}
ENV NVIDIA_DRIVER_CAPABILITIES \
    ${NVIDIA_DRIVER_CAPABILITIES:+$NVIDIA_DRIVER_CAPABILITIES,}graphics
# Make sure everything is up to date before building from source
RUN apt-get update \
  && apt-get upgrade -y \
  && apt-get clean

RUN apt-get update && apt-get install -q -y --no-install-recommends \
    dirmngr \
    gnupg2 \
    lsb-release \
    python3-colcon-ros \
    python3-rospkg \
    ros-humble-gazebo-ros-pkgs \
    ros-humble-ros-ign-bridge \
    ros-humble-teleop-twist-keyboard \
    ros-humble-ros2-control \
    ros-humble-ros2-controllers \
    ros-humble-controller-manager \
    ros-humble-xacro \
    ros-humble-twist-mux 

RUN mkdir -p /home/ros2_ws/src \
    && cd /home/ros2_ws/src/ \
    && git clone https://github.com/chaithanya121/ros2_humble_robot2.git 
    #  \
    # && rosdep fix-permissions && rosdep update \
    # && rosdep install --from-paths ./ -i -y --rosdistro humble \
    #   --ignore-src

RUN cd /home/ros2_ws/ \
  && . /opt/ros/humble/setup.sh \
  && colcon build --merge-install



COPY entrypoint.sh /entrypoint.sh
RUN chmod +x entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

# CMD ros2 launch gazebo_ros2_control_demos cart_example_position.launch.py