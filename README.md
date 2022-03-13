# jetson_tx2_docker

## Purpose
This Dockerfile creates container with ROS-Noetic and Tensorflow 2.5 under Python3.6 environment running on Nvidia's Jetson TX2. It's created from the based container [ros:melodic-ros-base-l4t-r32.7.1](https://github.com/dusty-nv/jetson-containers).

## The Process
The container is targeted to run on Jetson TX2 with AArch64 platform and CUDA support. The container is built on x86 PC using [qemu](https://www.qemu.org/). A number of resources have been referred to create this Dockerfile for build process:
+ https://github.com/dusty-nv/jetson-containers
+ https://github.com/NVIDIA/nvidia-docker/wiki/NVIDIA-Container-Runtime-on-Jetson (Please carefully read the *Troubleshooting* section and make sure you are free of errors before building through qemu.

## Build Conditions
The Dockerfile is built and tested on this workstation:
+ Intel i9-9820X 20 cores with 64GB DDR4 RAM
+ Nvidia TITAN RTX
+ Ubuntu 18.04 LTS
+ JetPack 4.6
+ Nvidia-docker 2
+ Nvidia-container-runtime

To build this docker container, use this command:
```
sudo docker build -t <your Docker USERNAME>/<your Docker repo name>:<Tag> .
```
(don't forget the . at the end)


The final container is pushed and available here:
```
docker pull oscarkfpang/tx2_ros_noetic_tf2
```

## To Execute on TX2
On a newly flashed Jetson TX2 with JetPack 4.6 or above, run the following:
```
docker run -it --runtime nvidia oscarkfpang/tx2_ros_noetic_tf2:tf2.5_jp4.6
```


