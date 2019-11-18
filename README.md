# log.io Real-time log monitoring in your browser
This repository contains components for running either an operational log.io server and harvester setup for your docker conteiners logs stream. 

#### Attention:
If on docker host conteiners stops or new contreiners runs, script will rediscover and stream to log.io WEB.

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
# To implement:
clone the repository<img src="https://help.github.com/assets/images/help/repository/clone-repo-clone-url-button.png" alt="Thunder" width="20%"/>
***
```
$ bash ./harvester_conf.sh
```
```
$ docker-compose-up --build
```
***

# How does it work?

*Harvesters* watch log files for changes, send new log messages to the *server* via TCP, which broadcasts to *web clients* via socket.io.

Log streams are defined by mapping file paths to a stream name in harvester configuration.

Users browse streams in the web UI, and activate (stream, node) pairs to view and search log messages in screen widgets.
