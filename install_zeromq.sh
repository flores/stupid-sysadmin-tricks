#!/bin/bash
# doesn't remove packages.  just beginning/sharing script for the install.

if [ -e /etc/redhat-release ]; then
    yum install -y gcc make autoconf automake e2fsprogs-devel glibc-devel
elif [ -e /etc/debian_version ]; then
    apt-get install -y build-essential uuid-dev
else
    echo "sorry, this script only installs on RedHat/CentOS or Debian/Ubuntu boxes"
    exit 2
fi

cd /usr/src
mkdir /usr/local/zeromq
wget http://download.zeromq.org/zeromq-2.1.7.tar.gz
tar xfz zeromq-2.1.7.tar.gz
cd zeromq-2.1.7
./configure --prefix=/usr/local/zeromq
make && make install
ldconfig
