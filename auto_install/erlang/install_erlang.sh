#!/bin/bash

#===============================================================================
#
#          FILE: install_erlang.sh
# 
#         USAGE: ./install_erlang.sh otp_src_18.1.tar.gz
# 
#   DESCRIPTION: Install Erlang!
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: ChenFangjie 
#  ORGANIZATION: 
#       CREATED: 2015/12/21 22:26
#      REVISION: v1.0.0 - First release
#===============================================================================

log()
{
    echo "["$(date '+%Y-%m-%d %H:%M:%S')"] - $*"
    echo "["$(date '+%Y-%m-%d %H:%M:%S')"] - $*" >> ${CURRENT_DIR}/install_jdk.log
}


# ------ main() ------
ERLANG_INSTALL_TAR_NAME=$1

if [ -z ${ERLANG_INSTALL_TAR_NAME} ]; then
    log "Missing parameter, please check it!"
    exit 1
fi


CURRENT_DIR=$(cd "$(dirname "$0")"; pwd)
ERLANG_INSTALL_TAR=${CURRENT_DIR}/${ERLANG_INSTALL_TAR_NAME}
ERLANG_INSTALL_PATH=/usr/local/lib/erlang

if [ -d ${ERLANG_INSTALL_PATH} ]; then
    log "${ERLANG_INSTALL_PATH} directory already exists, please check it!"
	exit 1
fi


if [ ! -f ${ERLANG_INSTALL_TAR} ]; then
    log "No installation package in ${ERLANG_INSTALL_TAR}, please check it!"
    exit 1
fi


log "Unzip ${ERLANG_INSTALL_TAR}"
tar -zxvf ${ERLANG_INSTALL_TAR} > /dev/null 2>&1

log "Start install dependent..."
yum -y install make gcc gcc-c++ kernel-devel m4 ncurses-devel openssl-devel

# 将字符串 otp_src_18.1.tar.gz 变为 otp_src_18.1
ERLANG_DIR_NAME=${ERLANG_INSTALL_TAR_NAME/'.tar.gz'/''}
cd ${CURRENT_DIR}/${ERLANG_DIR_NAME}

log "Start make erlang source code..."
./configure --with-ssl --enable-threads --enable-smp-support --enable-kernel-poll --enable-hipe --without-javac > /dev/null 2>&1
make > /dev/null 2>&1

log "Start install erlang..."
make install > /dev/null 2>&1

ERLANG_PATH=$(whereis erl)
log "${ERLANG_PATH}"

log "Erlang install finished!"
