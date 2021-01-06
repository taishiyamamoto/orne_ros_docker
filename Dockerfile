FROM nvidia/cudagl:10.2-runtime-ubuntu18.04

ENV NVIDIA_VISIBLE_DEVICES ${NVIDIA_VISIBLE_DEVICES:-all}
ENV NVIDIA_DRIVER_CAPABILITIES ${NVIDIA_DRIVER_CAPABILITIES:+$NVIDIA_DRIVER_CAPABILITIES,}graphics
ENV DEBIAN_FRONTEND noninteractive
ENV ROS_DISTRO melodic

RUN apt update && apt install -y lsb-release language-pack-en

RUN locale-gen en_US.UTF-8  
ENV LANG en_US.UTF-8  
ENV LANGUAGE en_US:en  
ENV LC_ALL en_US.UTF-8

RUN sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
RUN apt-key adv --keyserver 'hkp://keyserver.ubuntu.com:80' --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654
RUN apt update
RUN apt install -y ros-${ROS_DISTRO}-desktop-full

RUN apt install -y python-rosdep python-rosinstall python-catkin-tools python-wstools
RUN rosdep init
RUN rosdep update
RUN echo "source /opt/ros/$ROS_DISTRO/setup.bash" >> ~/.bashrc
RUN bash -c "source ~/.bashrc"

RUN apt-get install -y git tmux wget tar vim

RUN mkdir -p /root/catkin_ws/src
RUN cd /root/catkin_ws && catkin init
RUN rm /bin/sh && ln -s /bin/bash /bin/sh
RUN cd /root/catkin_ws/src && wget https://raw.githubusercontent.com/open-rdc/orne_navigation/$ROS_DISTRO-devel/orne_pkgs.install
RUN cd /root/catkin_ws/src && \
	wstool init && \
	wstool merge orne_pkgs.install && \
	wstool up
RUN source /opt/ros/melodic/setup.bash && \
	cd /root/catkin_ws && \
	rosdep install --from-paths src/ --ignore-src --rosdistro $ROS_DISTRO -y && \
	export CMAKE_PREFIX_PATH=~/catkin_ws/devel:/opt/ros/$ROS_DISTRO

RUN cd /root/catkin_ws && source /opt/ros/$ROS_DISTRO/setup.bash && catkin build

RUN echo "source /opt/ros/melodic/setup.bash" >> ~/.bashrc
RUN echo "source ~/catkin_ws/devel/setup.bash" >> ~/.bashrc
