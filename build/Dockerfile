FROM alpine:3.7

MAINTAINER Rostylav Kamach <ros.kamach@gmail.com>

RUN \
    #Install needed packages
    apk add --no-cache curl make gcc g++ python linux-headers binutils-gold gnupg libstdc++ && \
    #Install nodejs
    curl https://raw.githubusercontent.com/ros-kamach/log.io_docker_host/files/node-v6.9.5.tar.xz \
    --output node-v6.9.5.tar.xz && \
    tar -xf node-v6.9.5.tar.xz && \
    cd /node-v6.9.5 && \
    ./configure --prefix=/usr && \
    make -j$(getconf _NPROCESSORS_ONLN) && \
    make install && \
    #Install yarn 
    cd / && \
    mkdir /usr/local/share/yarn && \
    curl https://raw.githubusercontent.com/ros-kamach/log.io_docker_host/files/yarn-v1.19.1.tar.gz \
    --output yarn-v1.19.1.tar.gz && \
    tar -xf yarn-v1.19.1.tar.gz -C /usr/local/share/yarn --strip 1 && \
    ln -s /usr/local/share/yarn/bin/yarn /usr/local/bin/ && \
    ln -s /usr/local/share/yarn/bin/yarnpkg /usr/local/bin/ && \
    #Clean up image from unkneeded packages and files
    rm yarn-v1.19.1.tar.gz && \
    rm node-v6.9.5.tar.xz && \
    rm -rf /node-v6.9.5* /tmp/* /var/cache/apk/* \
    /usr/share/man/* /usr/share/doc /root/.npm /root/.node-gyp /root/.config \
    /usr/lib/node_modules/npm/man /usr/lib/node_modules/npm/doc /usr/lib/node_modules/npm/html /usr/lib/node_modules/npm/scripts && \
    { rm -rf /root/.gnupg || true; } && \
    #Installing Log.io
    adduser -s /bin/false -g "" -D logio && \
    export USER=logio && export HOME=/home/logio && \
    npm install -g log.io --user "logio" && \
    apk add supervisor bash && apk del make gcc g++ python linux-headers binutils-gold gnupg && \
    rm -rf /tmp/* /var/cache/apk/* \
    /usr/share/man/* /usr/share/doc /root/.npm /root/.node-gyp /root/.config \
    /usr/lib/node_modules/npm/man /usr/lib/node_modules/npm/doc /usr/lib/node_modules/npm/html /usr/lib/node_modules/npm/scripts && \
    { rm -rf /root/.gnupg || true; } && \
    mkdir /home/logio/supervisord && chown logio:logio /home/logio/supervisord

EXPOSE 28778 28777

USER logio
ENV HOME /home/logio
ENV USER logio
WORKDIR /home/logio

COPY ./script.sh /home/logio/
COPY ./supervisor.conf /etc/supervisor/conf.d/supervisor.conf

CMD ["bash", "./script.sh"]
