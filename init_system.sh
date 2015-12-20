#!/bin/bash

#===============================================================================
#
#          FILE: init_system.sh
# 
#         USAGE: ./init_system.sh
# 
#   DESCRIPTION: Init system!
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: ChenFangjie 
#  ORGANIZATION: 
#       CREATED: 2015/12/20 21:10
#      REVISION: v1.0.0 - First release
#===============================================================================

log()
{
    echo "["$(date '+%Y-%m-%d %H:%M:%S')"] - $*"
    echo "["$(date '+%Y-%m-%d %H:%M:%S')"] - $*" >> ${CURRENT_DIR}/init_system.log
}


CURRENT_DIR=$(cd "$(dirname "$0")"; pwd)

yum -y update
yum -y install zip unzip
yum -y install vim
yum -y install expect
yum -y install lvm2
yum -y install net-tools
yum -y install make gcc gcc-c++ kernel-devel m4 ncurses-devel openssl-devel
yum -y install zlib-devel bzip2-devel openssl-devel ncurses-devel sqlite-devel readline-devel tk-devel gdbm-devel db4-devel libpcap-devel xz-deve
yum -y groupinstall "Development tools"

wget https://www.python.org/ftp/python/3.5.1/Python-3.5.1.tgz
tar -zxvf Python-3.5.1.tgz
cd Python-3.5.1
./configure --prefix=/usr/local
make && make altinstall

# echo /usr/local/lib >> /etc/ld.so.conf.d/local.conf

ln -s /usr/local/bin/python3.5 /usr/local/bin/python3
ln -s /usr/local/bin/python3 /usr/bin/python3




