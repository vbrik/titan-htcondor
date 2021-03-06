#!/bin/bash
set -o errexit
pool=$(readlink -f $1)
extra_daemons="$2"
set -o nounset

titan-sshd

source $(dirname "${BASH_SOURCE[0]}")/common.sh
condor_setup_common $pool
ln -T -sf $(hostname) $pool/nodes/cm
echo $_CONDOR_NETWORK_INTERFACE > $pool/cm_addr
create_pool_config $pool $_CONDOR_NETWORK_INTERFACE

export _CONDOR_EVENT_LOG="$pool/events"
export _CONDOR_EVENT_LOG_ROTATION_LOCK=/tmp/$USER/EventLogLock
export _CONDOR_EVENT_LOG_MAX_SIZE=0
export _CONDOR_SPOOL="$pool/spool"
mkdir -p $_CONDOR_SPOOL
export _CONDOR_HISTORY="$pool/history"
export _CONDOR_ENABLE_HISTORY_ROTATION=False
export _CONDOR_DAEMON_LIST="MASTER SCHEDD COLLECTOR NEGOTIATOR $extra_daemons"

export TITAN_POOL_DIR=$pool
export | grep -v 'SSH\|PWD\|SHLVL' > /tmp/env
monitor_host $_CONDOR_LOCAL_DIR $pool
shutdown_on_pool_kill $pool &

(sleep 5 && touch $pool/pool_is_ready) &
condor_master -f
