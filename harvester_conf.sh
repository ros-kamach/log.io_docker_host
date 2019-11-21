#!/bin/bash
##################################
CONFIG_DIR="logio_scan_files"
LOGIO_SERVER_URL="0.0.0.0"
SINCE_TIME=1h
LOGS_CLEAN_PERIOD=3600
# GREP_POD_NAMES=mysql
SKIP_POD_NAMES=logio
##################################
###Create Template for Harvester##
##################################
constructor_harvester_conf_start () {
cat <<EOF | tee ${1} > /dev/null
exports.config = {
  nodeName: "${2}",
  logStreams: {
EOF
}
##################################
constructor_harvester_conf_stream_log () {
cat <<EOF | tee -a ${1} > /dev/null
    "${2}": ["/home/logio/logs/${2}.log"],
EOF
}
##################################
constructor_harvester_conf_end () {
cat <<EOF | tee -a ${1} > /dev/null
},
  server: {
    host: '${2}',
    port: 28777
  }
}
EOF
}
##################################
#########Check PID Function#######
##################################

log_clearn () {
while sleep ${1}
do
echo $BASHPID > ./${CONFIG_DIR}/pid/kill_docker_logs.tmp
kill -9 $( ps -ef | grep -v grep | grep "docker logs" | awk '{print$2}' ) 2>/dev/null
done &
}

check_pid_kill () {
while sleep 25
do
PID_CHECK_KILL=$BASHPID
if [ -f "./$1/pid/pid.tmp" ]
    then
        COUNT_LINES_PID=$(cat ./$1/pid/pid.tmp | wc -l 2>/dev/null )
        COUNT_LINES_POD=$(cat ${4} | wc -l)
        # echo COUNT_LINES_PID=$COUNT_LINES_PID
        # echo COUNT_LINES_POD=$COUNT_LINES_POD
        if [ "$COUNT_LINES_PID" -lt "$COUNT_LINES_POD" ]
            then
                # echo "-lt append"
                echo ${PID_CHECK_KILL} >> ./$1/pid/pid.tmp

        fi
        if [ "$COUNT_LINES_PID" -eq "$COUNT_LINES_POD" ]
            then
                # echo "-eq copy and clearn"
                cp ./$1/pid/pid.tmp ./$1/pid/check_log_live.tmp
                rm ./$1/pid/pid.tmp 2>/dev/null
#                 echo "#########"
#                 cat ./$1/pid/check_log_live.tmp
        fi
        if [ "$COUNT_LINES_PID" -gt "$COUNT_LINES_POD" ]
            then
                # echo "-gt clearn"
                rm ./$1/pid/pid.tmp 2>/dev/null

        fi
    else
        # echo "pid kill else"
        echo ${PID_CHECK_KILL} > ./$1/pid/pid.tmp
fi
files=$(ps -ef  | grep -v grep | grep "docker logs" | grep ${3} | awk '{print$2}')
    if [[ $? != 0 ]] 
    then
        echo "Command failed."
    elif [[ ! ${files} ]]; then
        printf "\nNo PID founded for ${3}\n"
        docker logs ${3} ${2} -f --tail=1 2>&1 | tee ./${1}/logs/${3}.log >/dev/null &
        printf "\n!!! PID for ${3} Started\n"    
    fi
done &
}
##################################
######Check pod output pods#######
#########And Implement############
##################################
pod_logs () {
  for val in $( cat ${4} ); do
        constructor_harvester_conf_stream_log ${1} ${val}
        docker logs ${val} ${2} -f --tail=1  2>&1 | tee ./${3}/logs/${val}.log >/dev/null &
        check_pid_kill ${3} ${2} ${val} ${4}
  done
}
##################################
########Show input param##########
echo "Input Environment Variables"
echo "LOGIO_SERVER_URL=$LOGIO_SERVER_URL"
echo "SINCE_TIME=$SINCE_TIME"
echo "PROJECT_NAME=$PROJECT_NAME"
echo "GREP_POD_NAMES=$GREP_POD_NAMES"
echo "SKIP_POD_NAMES=$SKIP_POD_NAMES"
echo "READOUT_LOG_PERIOD=$READOUT_LOG_PERIOD"
##################################
if [ -z "$CONFIG_DIR" ]
    then
        echo "[ERROR] Missing config dir environment variable. Aborting."
        exit 1
fi
if [ -z "$LOGIO_SERVER_URL" ]
    then
        echo "[ERROR] Missing Log.io server URL environment variable. Aborting."
        exit 1
fi
##################################
###########Clear folder###########
##################################
if [ -d "${CONFIG_DIR}" ]
    then
        rm -rf ${CONFIG_DIR}
        mkdir -p ${CONFIG_DIR}/logs ${CONFIG_DIR}/pods ${CONFIG_DIR}/conf ${CONFIG_DIR}/pid ${CONFIG_DIR}/trigger
        # chown -R :1000 ${CONFIG_DIR}
        # chmod -R 755 ${CONFIG_DIR}
    else
        mkdir -p ${CONFIG_DIR}/logs ${CONFIG_DIR}/pods ${CONFIG_DIR}/conf ${CONFIG_DIR}/pid ${CONFIG_DIR}/trigger
        # chown -R :1000 ${CONFIG_DIR}
        # chmod -R 755 ${CONFIG_DIR}
fi
##################################
###Check Conteiner list ###
##################################
pod_discovery () {
CONTEINER_LIST=$( docker ps --format '{{.Names}}' | grep -v upbeat_pascal )
NODE_NAME=$(hostname)

if [ ! -z "${1}" ]
    then
        SINCE_TIME_COMMAND="--since=${1}"
fi

if [ -z "${5}" ]
    then
        if [ -z "${4}" ]
            then
                PODS_LIST=$( echo $CONTEINER_LIST | tr ' ' '\n' )
            else
                # echo "Filter Pods by Skipping pattern ${4}"
                PODS_LIST="$( echo $CONTEINER_LIST | tr ' ' '\n' | grep -v ${4} )"
        fi
    else
        if [ -z "${4}" ]
            then
                # echo "Filter Pods by Grep command grep ${5}"
                PODS_LIST="$( echo $CONTEINER_LIST | tr ' ' '\n' | grep ${5} )"
            else
                # echo "Filter Pods by Grep command grep ${5} and Skipping pattern ${4}"
                PODS_LIST=$( echo $CONTEINER_LIST | tr ' ' '\n' | grep ${5} | grep -v ${4} )
        fi
fi

if [[ "${3}" == "apply" ]]
    then
        CONF_FILE_START="./${2}/conf/harvester_compare.conf"
        constructor_harvester_conf_start ${CONF_FILE_START} ${NODE_NAME}
        echo ${PODS_LIST} | tr ' ' '\n' > ./${2}/pods/conteiners_compare.list
    else
        CONF_FILE_START="./${2}/conf/harvester.conf"
        constructor_harvester_conf_start ${CONF_FILE_START} ${NODE_NAME}
        echo ${PODS_LIST} | tr ' ' '\n' > ./${2}/pods/conteiners.list
fi
}

PREFIX="no"
CONF_FILE_START="./${CONFIG_DIR}/conf/harvester.conf"
FILE_1="./${CONFIG_DIR}/pods/conteiners.list"
pod_discovery ${SINCE_TIME} ${CONFIG_DIR} ${PREFIX} ${SKIP_POD_NAMES} ${GREP_POD_NAMES}
pod_logs ${CONF_FILE_START} ${SINCE_TIME_COMMAND} ${CONFIG_DIR} ${FILE_1}
constructor_harvester_conf_end ${CONF_FILE_START} ${LOGIO_SERVER_URL}

while sleep 70
do
PREFIX="apply"
FILE_2="./${CONFIG_DIR}/pods/conteiners_compare.list"

pod_discovery $SINCE_TIME ${CONFIG_DIR} ${PREFIX} ${SKIP_POD_NAMES} ${GREP_POD_NAMES}

    if cmp -s "${FILE_1}" "${FILE_2}"; then
        RECREATE_LOGS_STREAM="no"
        # echo "same conteiner list" 

    else
        printf 'Compare of conteiner list different\n'
        for pid in $( cat ./${CONFIG_DIR}/pid/check_log_live.tmp ); do kill -9 $pid; done
        for pid in $( cat ./${CONFIG_DIR}/pid/kill_docker_logs.tmp ); do kill -9 $pid; done
        for pid in $( ps -ef | grep -v grep | grep "docker logs" | awk '{print $2}' ); do kill -9 $pid; done
        rm ./${CONFIG_DIR}/pid/* ./${CONFIG_DIR}/logs/* 2>/dev/null
        touch ./${CONFIG_DIR}/trigger/restart_if_this_file_exist
        chmod 777 ./${CONFIG_DIR}/trigger/restart_if_this_file_exist
        CONF_FILE_START="./${CONFIG_DIR}/conf/harvester_compare.conf"
        RECREATE_LOGS_STREAM="apply"
        pod_logs ${CONF_FILE_START} ${SINCE_TIME_COMMAND} ${CONFIG_DIR} ${FILE_2} ${RECREATE_LOGS_STREAM}
        constructor_harvester_conf_end ${CONF_FILE_START} ${LOGIO_SERVER_URL}
        cp ${CONF_FILE_START} ./${CONFIG_DIR}/conf/harvester.conf
        cp ${FILE_2} ${FILE_1}
        log_clearn ${LOGS_CLEAN_PERIOD}
        echo $! > ./${CONFIG_DIR}/pid/kill_docker_logs.tmp
    fi

    if  [ -f "${CONFIG_DIR}/trigger/restart_if_this_file_exist" ]
    then
        retries_counter=0
        max_retries=65
        until [ ! -f "${CONFIG_DIR}/trigger/restart_if_this_file_exist" ]; do
            if [ ${retries_counter} -eq ${max_retries} ]
            then
            rm ${CONFIG_DIR}/trigger/restart_if_this_file_exist
            fi
            retries_counter=$(($retries_counter+1))
            sleep 1
        done
    fi
done &

log_clearn ${LOGS_CLEAN_PERIOD}
echo $! > ./${CONFIG_DIR}/pid/kill_docker_logs.tmp
