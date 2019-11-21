# log.io Real-time log monitoring in your browser
This repository contains components for running either an operational log.io server and harvester setup for your docker conteiners log stream. 
***
#### Attention:
***You must run harvester_conf.sh***.User that runs script must have privileges to run docker without sudo. It discovers and streams docker logs. If on docker host conteiners stops or new contreiners runs, script will rediscover and stream to log.io WEB.
***
***!!!!***
Build this Docker image may take about 1h, if you dont'n need your own "secure" build, you could run it from prebuilded image on my docker hub,
cange in docker-compose.yaml :
```
    build:
     context: ./build
```
to
```
    image: roskamach/logio_alpine_docker:latest
```
***
To kill all processes that ***harvester_conf.sh*** run:
```
$ script_processes_killer.sh
```
***
# To implement:
***
```
$ git clone https://github.com/ros-kamach/log.io_docker_host.git && cd ./log.io_docker_host
```
```
$ docker-compose build
```
```
$ bash ./harvester_conf.sh
```
```
$ docker-compose --compatibility up -d
```
***
#### docker-compose properties:
***
| Property                   | Default Value   | Description                        |
|:-------------------------|:-----------------:|------------------------------------|         
| ```AUTH``` | ```"enable"```    | add authorization to log.io WEB (if othrer value it disables authorization ) |
| ```AUTH_LOGIN``` | ```"admin10"```  | Login value to autorize log.io WEB (```AUTH``` value must be ```"enable"```) |
| ```AUTH_PASS``` | ```"qwerty13q"```     | Password value to authorize log.io WEB (```AUTH``` value must be ```"enable"```) |
***

#### harvester_conf.sh (skript) properties:
***
| Property                      | Default Value         | Description                                             |
|:------------------------------|:-------------------------------------------:|---------------------------------------------------------|
| ```LOGIO_SERVER_URL```        | ```"0.0.0.0"```  | harvester sends logs to this URL                        |
| ```SINCE_TIME```              |   ```"1h"```      | Only return logs newer than a relative duration like 5s, 2m, or 3h. Defaults to all logs. Only one of since-time / since may be used.  |
| ```GREP_POD_NAMES```           |              ```<pattern>```               | connect pods with literal matched by pattern only (by default not active) |
| ```SKIP_POD_NAMES```          |               ```"logio"```               | skip conteiners names with literal matched by pattern |
| ```CONFIG_DIR```        |  ```"logio_scan_files"```     | name of directory where scripts files will stores  |
| ```LOGS_CLEAN_PERIOD```      |  ```"3600"```   | interval of clearning logs from steam files |
***

# How does it work?

*Harvesters* watch log files for changes, send new log messages to the *server* via TCP, which broadcasts to *web clients* via socket.io.

Log streams are defined by mapping file paths to a stream name in harvester configuration.

Users browse streams in the web UI, and activate (stream, node) pairs to view and search log messages in screen widgets.
