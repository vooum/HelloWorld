#!/bin/bash

# 新机基础安装 #
if [ $#  -eq 0 ];then
    Upgrade_apt() {
        sudo apt clean
        sudo apt update
        echo y | sudo apt upgrade
    }
    tsinghua_pypi=https://pypi.tuna.tsinghua.edu.cn/simple # 清华源

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
fi


# 高能程序包 #

Install_ROOT() {
    echo y | sudo apt install dpkg-dev cmake g++ gcc binutils libx11-dev libxpm-dev libxft-dev libxext-dev python2 libssl-dev
    echo y | sudo pip3 install numpy
    echo y | sudo apt install gfortran libpcre3-dev xlibmesa-glu-dev libglew1.5-dev libftgl-dev libmysqlclient-dev libfftw3-dev libcfitsio-dev graphviz-dev libavahi-compat-libdnssd-dev libldap2-dev python-dev libxml2-dev libkrb5-dev libgsl0-dev

    curPath=$(readlink -f "$(dirname "$0")")
    if [ -e ./root_v6.18.04.source.tar.gz ];then
        echo "root package exist"
    else
        wget https://root.cern/download/root_v6.18.04.source.tar.gz
    fi
    tar -zxf ./root_v6.18.04.source.tar.gz
    cd /opt/
    sudo mkdir ROOT6
    cd ROOT6
    sudo mkdir builddir installdir
    cd builddir
    sudo cmake -DCMAKE_INSTALL_PREFIX=../installdir $curPath/root-6.18.04
    sed -i '/minuit2:/s/OFF/ON/g' CMakeCache.txt
    sed -i '/pyroot_legacy:/s/OFF/ON/g' CMakeCache.txt
    sudo cmake --build . -- install
    sudo cp ~/.bashrc ~./bashrc.bak.vooum
    sudo echo 'source /opt/ROOT6/installdir/bin/thisroot.sh' >> ~./bashrc
    ./root-config --has-minuit2
}

while [ $#  -ne 0 ];
    do
    case $1 in
        'ROOT'|'Root'|'root')
            Install_ROOT
            ;;
    esac
    shift
done

# if [ $#  -eq 0];then
# exit
# fi
