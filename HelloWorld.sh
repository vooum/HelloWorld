#!/bin/bash

tsinghua_pypi=https://pypi.tuna.tsinghua.edu.cn/simple # 清华源

# 新机基础安装 #
if [ $#  -eq 0 ];then
    Upgrade_apt() {
        sudo apt clean
        sudo apt update
        echo y | sudo apt upgrade
    }
    echo "开始安装"
    sudo echo "更新并配置系统"
    Upgrade_apt
    echo y | sudo apt install gcc g++ gfortran python3{,-dev,-pip,-tk} git cmake vim screen
    echo "设置 Python3"
    ## sudo cp pip.conf /etc/pip.conf # 放置系统级(site-wide)配置文件， 该行备用
    sudo pip3 install -i $tsinghua_pypi pip -U # 用清华源升级pip
    sudo pip3 config set global.index-url $tsinghua_pypi # 产生配置文件：~/.config/pip/pip.conf
    echo y | sudo pip3 install numpy scipy pandas matplotlib ipython jupyter
    ## 输入法 ##
    echo y | sudo apt install ibus-pinyin
    echo "配置完成"
else
    echo "No arguments needed"
fi