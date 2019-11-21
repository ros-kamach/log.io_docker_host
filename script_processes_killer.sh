#!/bin/bash
##################################
printf 'Kill all bash script jobs \n'
while true; do
    read -p "yes(Yy) to process or no(Nn) to skip : " yn
    case $yn in
        [Yy]* ) echo "Killing..."
                for pid in $( ps -ef | grep -v grep | grep "harvester_conf.sh" | awk '{print $2}' ); do kill -9 $pid; done;
                for pid in $( ps -ef | grep -v grep | grep "docker logs" | awk '{print $2}' ); do kill -9 $pid; done;
                # for pid in $( ps -ef | grep -v grep | grep "sleep" | awk '{print $2}' ); do kill -9 $pid; done;
                echo "Done"
                break;;
        [Nn]* ) printf "${5}Step Skipped!!!${7}\n";break;;
        * )     echo "Please answer yes(Yy) to process or no(Nn) to skip .";;
    esac
done
