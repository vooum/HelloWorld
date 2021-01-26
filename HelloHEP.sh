#!/bin/bash

# 默认参数 #
threads=4 # 编译默认线程数
ROOT=OFF

# 高能程序包 #

while [ $#  -ne 0 ];
    do
    case $1 in
        'ROOT'|'Root'|'root')
            ROOT=ON
            ;;
    esac
    shift
done

Install_ROOT() {
    echo y | sudo apt install dpkg-dev cmake g++ gcc binutils libx11-dev libxpm-dev libxft-dev libxext-dev libssl-dev
    # ubuntu 20
    # echo y | sudo apt install python2
    echo y | sudo pip3 install numpy
    echo y | sudo apt install gfortran libpcre3-dev xlibmesa-glu-dev libglew1.5-dev libftgl-dev libmysqlclient-dev libfftw3-dev libcfitsio-dev graphviz-dev libavahi-compat-libdnssd-dev libldap2-dev python-dev libxml2-dev libkrb5-dev libgsl0-dev

    curPath=$(readlink -f "$(dirname "$0")")
    if [ ! -e ./root_v6.14.04.source.tar.gz ];then
        wget https://root.cern/download/root_v6.14.04.source.tar.gz
    fi
    tar -zxf ./root_v6.14.04.source.tar.gz
    cd /opt/
    sudo mkdir ROOT6
    cd ROOT6
    sudo mkdir builddir installdir
    cd builddir
    sudo cmake -DCMAKE_INSTALL_PREFIX=../installdir $curPath/root-6.14.04
    sudo sed -i '/minuit2:/s/OFF/ON/g' CMakeCache.txt
    # sudo sed -i '/pyroot_legacy:/s/OFF/ON/g' CMakeCache.txt
    sudo cmake --build . -- install -j$threads
    if [ $? ];then
        echo "ROOT 安装失败"
        exit 2
    else
        sudo cp ~/.bashrc ~/.bashrc.bak.vooum
        sudo echo 'source /opt/ROOT6/installdir/bin/thisroot.sh # ROOT' >> ~/.bashrc
        ./root-config --has-minuit2
    fi
}
if [ $ROOT == ON ]
then
    Install_ROOT
fi