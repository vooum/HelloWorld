#!/bin/bash

echo "开始安装"
sudo apt clean
sudo apt update
echo y | sudo apt upgrade
echo y | sudo apt install gcc g++ gfortran python3{,-dev,-pip,-tk} git cmake vim screen
sudo cp pip.conf /etc/pip.conf # 放置系统级(site-wide)配置文件
sudo pip3 install pip -U # 用清华源升级pip
# sudo pip3 config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple # 产生配置文件：~/.config/pip/pip.conf
echo y | sudo pip3 install numpy scipy pandas matplotlib ipython jupyter