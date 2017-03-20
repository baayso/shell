#!/bin/bash

#===============================================================================
#
#          FILE: install_jdk.sh
# 
#         USAGE: ./install_jdk.sh jdk1.8.0_66-linux-x64.zip
# 
#   DESCRIPTION: Install JDK!
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: ChenFangjie 
#  ORGANIZATION: 
#       CREATED: 2015/12/20 18:04
#      REVISION: v1.0.0 - First release
#===============================================================================

log()
{
    echo "["$(date '+%Y-%m-%d %H:%M:%S')"] - $*"
    echo "["$(date '+%Y-%m-%d %H:%M:%S')"] - $*" >> ${CURRENT_DIR}/install_jdk.log
}


# main()
JDK_INSTALL_ZIP_NAME=$1

if [ -z ${JDK_INSTALL_ZIP_NAME} ]; then
    log "Missing parameter, please check it!"
    exit 1
fi

DATE=$(date '+%Y-%m-%d-%H:%M:%S')
CURRENT_DIR=$(cd "$(dirname "$0")"; pwd)
JDK_INSTALL_ZIP=${CURRENT_DIR}/${JDK_INSTALL_ZIP_NAME}
JDK_INSTALL_PATH=/usr/java
PROFILE_PATH=/etc/profile

if [ -d ${JDK_INSTALL_PATH} ]; then
    log "${JDK_INSTALL_PATH} directory already exists, please check it!"
    exit 1
elif [ ! -f ${PROFILE_PATH} ]; then
    log "${PROFILE_PATH} file does not exist, please check it!"
    exit 1
fi


if [ -f ${JDK_INSTALL_ZIP} ]; then
    log "Create directory ${JDK_INSTALL_PATH}"
    mkdir ${JDK_INSTALL_PATH}
    # cp ${JDK_INSTALL_ZIP} ${JDK_INSTALL_PATH}
else
    log "No installation package in ${JDK_INSTALL_ZIP}, please check it!"
    exit 1
fi


# var=$(command 2>&1)
log "Unzip ${JDK_INSTALL_ZIP} to ${JDK_INSTALL_PATH}"
unzip -o ${JDK_INSTALL_ZIP} -d ${JDK_INSTALL_PATH} > /dev/null 2>&1


# 将字符串 jdk1.8.0_66-linux-x64.zip 变为 jdk1.8.0_66
JDK_DIR_NAME=${JDK_INSTALL_ZIP_NAME/'-linux-x64.zip'/''}
log "Create ${JDK_INSTALL_PATH}/jdk soft links"
ln -s ${JDK_INSTALL_PATH}/${JDK_DIR_NAME}/ ${JDK_INSTALL_PATH}/jdk
chmod -R 755 ${JDK_INSTALL_PATH}/jdk/bin
chmod -R 755 ${JDK_INSTALL_PATH}/jdk/jre/bin
# /usr/java/jdk/bin/java -version
# /usr/java/jdk/jre/bin/java -version


log "Set JAVA_HOME"
cp ${PROFILE_PATH} ${PROFILE_PATH}.${DATE}
JAVA_HOME=/usr/java/jdk
echo '' >> ${PROFILE_PATH}
echo export "JAVA_HOME=${JAVA_HOME}" >> ${PROFILE_PATH}
echo export 'PATH=$JAVA_HOME/bin:$PATH:.' >> ${PROFILE_PATH}
source ${PROFILE_PATH}


log "JDK installation finished!"

java -version

