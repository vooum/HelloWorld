#!/bin/bash

echo "开始安装"
apt clean
apt update
apt upgrade
apt install gcc g++ gfortran python3{,-dev,-pip,-tk} git cmake vim screen
pip3 install numpy scipy pandas matplotlib ipython