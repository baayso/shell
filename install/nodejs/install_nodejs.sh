#!/bin/bash

#===============================================================================
#
#          FILE: install_nodejs.sh
# 
#         USAGE: ./install_nodejs.sh node-v6.10.0.tar.gz
# 
#   DESCRIPTION: Install Node.js!
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: ChenFangjie 
#  ORGANIZATION: 
#       CREATED: 2017/03/20 12:38
#      REVISION: v1.0.0 - First release
#===============================================================================

log()
{
    echo "["$(date '+%Y-%m-%d %H:%M:%S')"] - $*"
    echo "["$(date '+%Y-%m-%d %H:%M:%S')"] - $*" >> ${CURRENT_DIR}/install_nodejs.log
}


# main()
INSTALL_PKG_NAME=$1

if [ -z ${INSTALL_PKG_NAME} ]; then
    log "Missing parameter, please check it!"
    exit 1
fi

DATE=$(date '+%Y-%m-%d-%H:%M:%S')
CURRENT_DIR=$(cd "$(dirname "$0")"; pwd)
INSTALL_PKG=${CURRENT_DIR}/${INSTALL_PKG_NAME}
INSTALL_PATH=/usr/local/nodejs
PROFILE_PATH=/etc/profile

if [ -d ${INSTALL_PATH} ]; then
    log "${INSTALL_PATH} directory already exists, please check it!"
    exit 1
elif [ ! -f ${PROFILE_PATH} ]; then
    log "${PROFILE_PATH} file does not exist, please check it!"
    exit 1
fi


if [ -f ${INSTALL_PKG} ]; then
    log "Create directory ${INSTALL_PATH}"
    mkdir ${INSTALL_PATH}
else
    log "No installation package in ${INSTALL_PKG}, please check it!"
    exit 1
fi

log "Start install dependent..."
yum -y install gcc gcc-c++ openssl-devel

log "Unzip ${INSTALL_PKG}"
tar -zxvf ${INSTALL_PKG}

# 将字符串 node-v6.10.0.tar.gz 变为 node-v6.10.0
INSTALL_FILE_DIR_NAME=${INSTALL_PKG_NAME/'.tar.gz'/''}

cd ${INSTALL_FILE_DIR_NAME}

./configure --prefix=${INSTALL_PATH}
make && make install

log "Set NODEJS_HOME"
cp ${PROFILE_PATH} ${PROFILE_PATH}.${DATE}
echo '' >> ${PROFILE_PATH}
echo export "NODEJS_HOME=${INSTALL_PATH}" >> ${PROFILE_PATH}
echo export 'PATH=$NODEJS_HOME/bin:$PATH:.' >> ${PROFILE_PATH}
echo export 'NODE_PATH=$NODEJS_HOME/lib/node_modules:$PATH' >> ${PROFILE_PATH}
source ${PROFILE_PATH}


log "node.js installation finished!"

node -v

