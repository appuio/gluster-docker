#!/bin/bash

HEKETI_PATH=/var/lib/heketi

if [[ -d ${HEKETI_PATH} ]]; then
    if [[ ! -f ${HEKETI_PATH}/heketi.db ]]; then
        echo "" > ${HEKETI_PATH}/container.log
        echo "DB file not found. heketi service will create a new DB" > ${HEKETI_PATH}/container.log
        mount | grep ${HEKETI_PATH} | grep heketidbstorage >> ${HEKETI_PATH}/container.log
        mount | grep ${HEKETI_PATH} | grep heketidbstorage
        if [[ $? -eq 0 ]]; then
            check=0
            while [[ ! -f ${HEKETI_PATH}/heketi.db ]]; do
                sleep 5
                if [[ check -eq 5 ]]; then
                   echo "DB file not found so exiting." >> ${HEKETI_PATH}/container.log
                   exit 1
                fi
                check=+1
            done
        fi
    fi
    echo "" > ${HEKETI_PATH}/container.log
    stat ${HEKETI_PATH}/heketi.db > ${HEKETI_PATH}/container.log
    # Workaround for scenario where a lock on the heketi.db has not been
    # released.
    flock -w 60 ${HEKETI_PATH}/heketi.db true
    if [ $? -ne 0 ]; then
        echo "Could not acquire lock on Database file" >> ${HEKETI_PATH}/container.log
        exit 1
    fi
else
    mkdir -p ${HEKETI_PATH}
fi

# Test that our volume is writable.
touch ${HEKETI_PATH}/test && rm ${HEKETI_PATH}/test || exit 1

if [[ ! -f ${HEKETI_PATH}/heketi.db ]] && [[ -f /backupdb/heketi.db ]] ; then
    cp /backupdb/heketi.db ${HEKETI_PATH}/heketi.db
    if [[ $? -ne 0 ]] ; then
        echo "Unable to copy database"
        exit 1
    fi
    echo "Copied backup db to ${HEKETI_PATH}/heketi.db"
fi

/usr/bin/heketi --config=/etc/heketi/heketi.json
