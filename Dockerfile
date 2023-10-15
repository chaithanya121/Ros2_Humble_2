# FROM osrf/ros:humble-desktop-full AS rover_image


FROM my_robot:latest

# nvidia-container-runtime
ENV NVIDIA_VISIBLE_DEVICES \
    ${NVIDIA_VISIBLE_DEVICES:-all}
ENV NVIDIA_DRIVER_CAPABILITIES \
    ${NVIDIA_DRIVER_CAPABILITIES:+$NVIDIA_DRIVER_CAPABILITIES,}graphics


# SHELL [ "/bin/bash" , "-c" ]
# Make sure everything is up to date before building from source

RUN apt-get update \
  && apt-get upgrade -y \
  && apt-get clean

#Add new sudo user
# ENV USERNAME sai
# RUN useradd -m $USERNAME && \
#         echo "$USERNAME:$USERNAME" | chpasswd && \
#         usermod --shell /bin/bash $USERNAME && \
#         usermod -aG sudo $USERNAME && \
#         echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/$USERNAME && \
#         chmod 0440 /etc/sudoers.d/$USERNAME && \
#         # Replace 1000 with your user/group id
#         usermod  --uid 1000 $USERNAME && \
#         groupmod --gid 1000 $USERNAME

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
    ros-humble-twist-mux \
    python3-colcon-common-extensions \
    ros-humble-joint-state-publisher-gui \
    ros-humble-gazebo-plugins 
    # opencv-contrib-python


RUN mkdir -p ldlidar_ros2_ws/src \
    && cd /home/ldlidar_ros2_ws/src \
    && git clone https://github.com/ldrobotSensorTeam/ldlidar_stl_ros2.git 
    #  \
    # && rosdep fix-permissions && rosdep update \
    # && rosdep install --from-paths ./ -i -y --rosdistro humble \
    #   --ignore-src
# RUN cd /home/ros2_ws/ros2_humble_robot2 \
#       && git pull

RUN cd /home/ros2_ws/ \
  && . /opt/ros/humble/setup.sh \
  && colcon build --merge-install

RUN cd /home/ldlidar_ros2_ws/ \
  && . /opt/ros/humble/setup.sh \
  && colcon build --merge-install

RUN echo "source /home/ros2_ws/install/setup.bash" >> ~/.bashrc
RUN echo "source /home/ldlidar_ros2_ws/install/setup.bash" >> ~/.bashrc

ENV GAZEBO_MASTER_URI http://localhost:11348

# export GAZEBO_MASTER_URI=http://localhost:11348
# ENV GAZEBO_MODEL_PATH /path/to/your/gazebo/models


COPY entrypoint.sh /entrypoint.sh
RUN chmod +x entrypoint.sh



ENTRYPOINT ["/entrypoint.sh"]

# CMD ros2 launch ros2_humble_robot2 launch_sim.launch.py