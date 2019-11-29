#!/bin/bash

echo "开始安装"
apt clean
apt update
apt upgrade
echo y | apt install gcc g++ gfortran python3{,-dev,-pip,-tk} git cmake vim screen
pip3 install -i https://pypi.tuna.tsinghua.edu.cn/simple numpy scipy pandas matplotlib ipython