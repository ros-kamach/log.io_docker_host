#!/bin/bash
##################################
##########Enable Auth#############
##################################
add_auth_to_conf () {
sed -i '$ d' .log.io/web_server.conf
cat <<EOF | tee -a .log.io/web_server.conf > /dev/null
  // Enable HTTP Basic Authentication
  auth: {
    user: "${1}",
    pass: "${2}"
  },
}
EOF
}
##################################
if [[ "${AUTH}" == "enable" ]]
    then
        add_auth_to_conf ${AUTH_LOGIN} ${AUTH_PASS}
fi

FILE=$HOME/conf/harvester.conf	
if test -f "$FILE"; then	
    echo "$FILE exist"	
    cp $HOME/conf/harvester.conf /home/logio/.log.io/harvester.conf
fi

while sleep 60
do
if  [ -f "$HOME/trigger/restart_if_this_file_exist" ]
  then	
    echo "Trigger for reboot conteiner"
    kill -9 $( echo `ps | grep -v grep | grep "supervisord" | awk '{print$1}'` ) 2>/dev/null	
fi
if  [ ! -f "$HOME/conf/harvester.conf" ]
  then	
    echo "File not exist (probably script run afrer logio docker conteiner) "
    kill -9 $( echo `ps | grep -v grep | grep "supervisord" | awk '{print$1}'` ) 2>/dev/null	
fi
done &

supervisord --nodaemon --configuration /etc/supervisor/conf.d/supervisor.conf   