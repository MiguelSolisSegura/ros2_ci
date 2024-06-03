# Use the official ROS Galactic base image
FROM osrf/ros:galactic-desktop

ENV LANG C.UTF-8

RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

# Install necessary packages
RUN apt-get update && apt-get install -y \
    ros-galactic-gazebo-ros-pkgs \
    ros-galactic-ros2-control \
    ros-galactic-ros2-controllers \
    ros-galactic-joint-state-publisher \
    ros-galactic-robot-state-publisher \
    ros-galactic-cartographer \
    ros-galactic-cartographer-ros \
    ros-galactic-gazebo-plugins \
    ros-galactic-teleop-twist-keyboard \
    ros-galactic-teleop-twist-joy \
    ros-galactic-xacro \
    ros-galactic-nav2-bringup \
    ros-galactic-nav2-common \
    ros-galactic-nav2-core \
    ros-galactic-nav2-lifecycle-manager \
    ros-galactic-nav2-msgs \
    ros-galactic-nav2-planner \
    ros-galactic-nav2-recoveries \
    ros-galactic-nav2-rviz-plugins \
    ros-galactic-nav2-system-tests \
    ros-galactic-nav2-util \
    ros-galactic-nav2-waypoint-follower \
    ros-galactic-urdf \
    ros-galactic-v4l2-camera \
    python3-rosdep \
    python3-vcstool \
    python3-colcon-common-extensions \
    build-essential \
    git \
    && rm -rf /var/lib/apt/lists/*

# Create a workspace
RUN mkdir -p /ros2_ws/src
WORKDIR /ros2_ws/src

# Clone the necessary repositories
RUN git clone -b ros2-galactic --recursive https://github.com/rigbetellabs/tortoisebot.git \
    && git clone https://github.com/MiguelSolisSegura/ros2_testing.git

# Copy the bringup_headless.launch.py file to the appropriate directory
COPY bringup_headless.launch.py /ros2_ws/src/tortoisebot/tortoisebot_bringup/launch/

# Install dependencies
WORKDIR /ros2_ws
RUN /bin/bash -c "source /opt/ros/galactic/setup.bash && \
                  rosdep install --from-paths src --ignore-src -r -y"

# Build the workspace, excluding the tortoisebot_control package
RUN /bin/bash -c "source /opt/ros/galactic/setup.bash && \
                  colcon build --packages-ignore tortoisebot_control --event-handler console_cohesion+"

# Source the setup.bash file and run the entrypoint
RUN echo "source /ros2_ws/install/setup.bash" >> /root/.bashrc

# Use the entrypoint to run your commands
ENTRYPOINT ["/bin/bash", "-c", "source /ros2_ws/install/setup.bash && \
                              (ros2 launch tortoisebot_bringup bringup.launch.py use_sim_time:=True &) && \
                              sleep 7 && \
                              (ros2 run tortoisebot_waypoints tortoisebot_action_server &) && \
                              sleep 3 && \
                              export GOAL_X=0.25 && \
                              export GOAL_Y=0.5 && \
                              colcon test --packages-select tortoisebot_waypoints --event-handler=console_direct+"]
