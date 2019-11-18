FROM alpine:3.7

COPY ./script.sh /home/logio/
COPY ./supervisor.conf /etc/supervisor/conf.d/supervisor.conf

ENV VERSION=v6.9.5
ENV YARN_VERSION=v1.19.1
COPY ./node-${VERSION}.tar.xz ./node-${VERSION}.tar.xz
COPY ./yarn-${YARN_VERSION}.tar.gz ./yarn-${YARN_VERSION}.tar.gz

RUN \
    #Install needed packages
    apk add --no-cache curl make gcc g++ python linux-headers binutils-gold gnupg libstdc++ && \
    #Install nodejs
    tar -xf node-${VERSION}.tar.xz && \
    cd /node-${VERSION} && \
    ./configure --prefix=/usr && \
    make -j$(getconf _NPROCESSORS_ONLN) && \
    make install && \
    #Install yarn 
    cd / && \
    mkdir /usr/local/share/yarn && \
    tar -xf yarn-${YARN_VERSION}.tar.gz -C /usr/local/share/yarn --strip 1 && \
    ln -s /usr/local/share/yarn/bin/yarn /usr/local/bin/ && \
    ln -s /usr/local/share/yarn/bin/yarnpkg /usr/local/bin/ && \
    #Clean up image from unkneeded packages and files
    rm yarn-${YARN_VERSION}.tar.gz && \
    rm node-${VERSION}.tar.xz && \
    rm -rf /node-${VERSION}* /tmp/* /var/cache/apk/* \
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

CMD ["bash", "./script.sh"]