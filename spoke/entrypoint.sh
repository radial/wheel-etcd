#!/bin/bash
set -e

# Tunable settings
export ETCD_DATA_DIR=${ETCD_DATA_DIR:-/data/backup}
export ETCD_CONFIG=${ETCD_CONFIG:-/config/etcd.conf}
export ETCD_NAME=${ETCD_NAME:-${HOSTNAME}}

# Misc settings
ERR_LOG=/log/$HOSTNAME/etcd_stderr.log

restart_message() {
    echo "Container restart on $(date)."
    echo -e "\nContainer restart on $(date)." | tee -a $ERR_LOG
}

if [ ! -e /tmp/etcd_first_run ]; then
    touch /tmp/etcd_first_run
else
    restart_message
fi

exec etcd
