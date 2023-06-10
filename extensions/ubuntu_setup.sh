#!/usr/bin/env bash

# Common setups
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install build-essential cmake git -y

# FastDDS
sudo apt-get install wget libasio-dev libssl-dev -y

# MAVSDK
sudo apt-get install pkg-config python-is-python3 python3-pip curl libcurl4-openssl-dev libtinyxml2-dev -y

# Godot
sudo apt-get install scons libx11-dev libxcursor-dev libxinerama-dev libgl1-mesa-dev libglu-dev libasound2-dev libpulse-dev libudev-dev libxi-dev libxrandr-dev -y

pip install future
