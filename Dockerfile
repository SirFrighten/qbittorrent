FROM debian:jessie

RUN apt-get update
RUN apt-get install -y qbittorrent-nox
RUN apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ARG UID=1982
ARG GID=1982

ARG HOST_UID=$(stat -c %u docker-compose.yml)
ARG HOST_GID=$(stat -c %g docker-compose.yml)

RUN groupadd -f -g $HOST_GID qbittorrent
RUN useradd --system -u $HOST_UID -g $HOST_GID -m --shell /usr/sbin/nologin qbittorrent \
    && mkdir -p /home/qbittorrent/.config/qBittorrent \
    && ln -s /home/qbittorrent/.config/qBittorrent /config \
    && mkdir -p /home/qbittorrent/.local/share/data/qBittorrent \
    && ln -s /home/qbittorrent/.local/share/data/qBittorrent /torrents \
    && chown -R qbittorrent:$HOST_GID /home/qbittorrent/ \
    && mkdir /downloads \
    && chown qbittorrent:$HOST_GID /downloads

# Default configuration file.
COPY qBittorrent.conf /default/qBittorrent.conf
COPY entrypoint.sh /

RUN chown qbittorrent:$GID /default/qBittorrent.conf
RUN chown qbittorrent:$GID /entrypoint.sh

VOLUME /config
VOLUME /torrents
VOLUME /downloads

EXPOSE 8080
EXPOSE 6881

USER qbittorrent

ENTRYPOINT ["/entrypoint.sh"]
CMD ["qbittorrent-nox"]