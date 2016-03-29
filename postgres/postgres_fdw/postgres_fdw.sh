#!/bin/bash

log()
{
    echo "["$(date '+%Y-%m-%d %H:%M:%S')"] $*"
    echo "["$(date '+%Y-%m-%d %H:%M:%S')"] $*" >> ${CURRENT_DIR}/postgres_fdw.sql.log
}

#main()
CURRENT_DIR=$(cd "$(dirname "$0")"; pwd)

SERVER=$1
PORT=$2
DATABASE=$3
USERNAME=$4

if [ -z ${SERVER} ]; then
    SERVER="127.0.0.1"
fi

if [ -z ${PORT} ]; then
    PORT="5432"
fi

if [ -z ${DATABASE} ]; then
    DATABASE="postgres"
fi

if [ -z ${USERNAME} ]; then
    USERNAME="postgres"
fi

log "psql -h ${SERVER} -p ${PORT} -d ${DATABASE} -U ${USERNAME} -W -f postgres_fdw.sql"

log "============================================================================================================="

psql -h ${SERVER} -p ${PORT} -d ${DATABASE} -U ${USERNAME} -W -f postgres_fdw.sql
