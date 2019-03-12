#!/bin/bash
echo -e "******************************\n"
echo -e "****Author:   Phoveran   *****\n"
echo -e "****Mail:phoveran@126.com*****\n"
echo -e "******************************\n"
#读取用户需求
echo -e "请指定端口（推荐10000-20000间整数）：\c"
read ssport
echo -e "请输入密码：\c"
read sskey
#安装依赖文件
sudo apt update -y
sudo apt upgrade -y
sudo apt-get install --no-install-recommends gettext build-essential autoconf libtool libpcre3-dev asciidoc xmlto libev-dev libc-ares-dev automake libmbedtls-dev libsodium-dev -y
sudo apt install git -y
sudo apt install screen -y
#安装Libsodium
export LIBSODIUM_VER=1.0.17
wget https://download.libsodium.org/libsodium/releases/libsodium-$LIBSODIUM_VER.tar.gz
tar xvf libsodium-$LIBSODIUM_VER.tar.gz
pushd libsodium-$LIBSODIUM_VER
./configure --prefix=/usr && make
sudo make install
popd
sudo ldconfig
sudo rm -r libsodium-$LIBSODIUM_VER
#安装MbedTLS
export MBEDTLS_VER=2.16.0
wget https://tls.mbed.org/download/mbedtls-$MBEDTLS_VER-gpl.tgz
tar xvf mbedtls-$MBEDTLS_VER-gpl.tgz
pushd mbedtls-$MBEDTLS_VER
make SHARED=1 CFLAGS="-O2 -fPIC"
sudo make DESTDIR=/usr install
popd
sudo ldconfig
sudo rm -r mbedtls-$MBEDTLS_VER
#安装shadowsocks-libev
git clone https://github.com/shadowsocks/shadowsocks-libev.git
cd shadowsocks-libev
git submodule update --init --recursive
./autogen.sh && ./configure && make
sudo make install
cd ~
#开启bbr
modprobe tcp_bbr
echo "tcp_bbr" >> /etc/modules-load.d/modules.conf
echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf
sysctl -p
#开启shadowsocks
screen -dmS ss ss-server -p $ssport -k $sskey -m chacha20-ietf-poly1305