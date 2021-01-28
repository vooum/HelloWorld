#!/bin/bash

# 默认参数 #
threads=60 # 编译默认线程数
ROOT=OFF
Delphes=OFF
CheckMATE=OFF

OS_release_num=$(lsb_release -r --short) # 系统版本号
curPath=$(readlink -f "$(dirname "$0")") # 当前目录

program=none
# 高能程序包 #

while [ $#  -ne 0 ];
    do
    case $1 in
        'ROOT'|'Root'|'root')
            ROOT=ON
            ;;
        'CheckMATE'|'checkmate')
            CheckMATE=ON
            ;;
        'only')
            shift
            program=$1
            ;;
        *)
            echo "Unknown program $1"
            ;;
    esac
    shift
done

Install_ROOT() {
    echo "安装ROOT"
    echo y | sudo apt install dpkg-dev cmake g++ gcc binutils libx11-dev libxpm-dev libxft-dev libxext-dev libssl-dev
    echo y | sudo pip install numpy
    echo y | sudo apt install gfortran libpcre3-dev xlibmesa-glu-dev libglew1.5-dev libftgl-dev libmysqlclient-dev libfftw3-dev libcfitsio-dev graphviz-dev libavahi-compat-libdnssd-dev libldap2-dev python-dev libxml2-dev libkrb5-dev libgsl0-dev

    if [ ! -e ./root_v6.18.04.source.tar.gz ];then
        wget https://root.cern/download/root_v6.18.04.source.tar.gz
    fi
    tar -zxf ./root_v6.18.04.source.tar.gz
    sudo mv -T root-6.18.04 /opt/root-6.18.04
    cd /opt/root-6.18.04
    sudo mkdir builddir installdir
    cd builddir
    sudo cmake -DCMAKE_INSTALL_PREFIX=../installdir ..
    sudo sed -i '/minuit2:/s/OFF/ON/g' CMakeCache.txt # 将以 minuit2: 开头的行里的 OFF 替换成 ON
    # sudo sed -i '/pyroot_legacy:/s/OFF/ON/g' CMakeCache.txt
    sudo cmake --build . -- install -j$threads
    if [ $? ];then # $?==0
        sudo cp ~/.bashrc ~/.bashrc.bak_by_vooum
        sudo echo 'source /opt/root_v6.18.04/installdir/bin/thisroot.sh # ROOT' >> ~/.bashrc
        cd /opt/root-6.18.04/installdir/bin
        ./root-config --has-minuit2
        echo "ROOT 安装成功"
    else
        echo "ROOT 安装失败"
        exit 1
    fi
    # return 0 #default
}
if [ $ROOT == ON ]
then
    Install_ROOT
fi

Install_Delphes_for_CheckMATE() {
    echo "安装Delphes"
    echo y | sudo apt install tcl
    unzip delphes-master.zip
    sudo mv -T delphes-master /opt/delphes_for_CheckMATE
    cd /opt/delphes_for_CheckMATE
    source /opt/root-6.18.04/installdir/bin/thisroot.sh # 加载ROOT环境
    ./configure
    make -j$threads
    if [ $? ];then # $?==0
        echo "Delphes 安装成功"
    else
        echo "Delphes 安装失败"
        exit 2
    fi
}

Install_Delphes() {
    # to be complement
    echo "not ready"
}
if [ $Delphes == ON ]
then
    Install_ROOT
    Install_Delphes
fi

Install_HepMC2() {
    echo "安装HepMC2"
    tar -xf hepmc2.06.11.tgz
    sudo mv -T HepMC-2.06.11 /opt/HepMC-2.06.11
    cd /opt/HepMC-2.06.11
    sudo mkdir build
    cd build
    sudo cmake -DCMAKE_INSTALL_PREFIX=/opt/HepMC-2.06.11 -Dmomentum:STRING=GEV -Dlength:STRING=MM ../
    sudo make
    sudo make test
    sudo make install -j
}

Install_Pythia8() {
    echo "安装Pythia8"
    tar -xzf pythia8245.tgz
    sudo mv -T pythia8245 /opt/pythia8245
    cd /opt/pythia8245
    sudo ./configure --with-hepmc2=/opt/HepMC-2.06.11 --prefix=/opt/pythia8245
    sudo make -j$threads
    sudo make install
}

Install_CheckMATE() {
    echo "安装依赖"
    echo y | sudo apt install libtool autoconf
    echo y | sudo pip install scipy
    echo "开始编译 CheckMATE2"
    unzip checkmate2-master.zip
    sudo mv -T checkmate2-master /opt/checkmate2
    cd /opt/checkmate2
    autoreconf -ivf
    ./configure --with-rootsys=/opt/root-6.18.04/installdir/ --with-delphes=/opt/delphes_for_CheckMATE --with-hepmc=/opt/HepMC-2.06.11 --with-pythia=/opt/pythia8245
    make -j$threads
    cd /opt/checkmate2/bin/
    ./CheckMATE -n example -ev=example_run_cards/auxiliary/testfile.lhe -wp8
}
if [ $CheckMATE == ON ]
then
    echo y | sudo apt install python-pip
    sudo pip2 install pip -U
    Install_ROOT
    cd $curPath
    Install_Delphes_for_CheckMATE
    cd $curPath
    Install_HepMC2
    cd $curPath
    Install_Pythia8
    cd $curPath
    Install_CheckMATE
    cd /opt/
    sudo chmod 755 ./ -R
fi

if [ $program != none ];then
    $program
fi