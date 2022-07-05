FROM ubuntu:20.04

# environment
LABEL org.opencontainers.image.source https://github.com/petemcw/docker-linuxgsm
LABEL maintainer="petemcw@petemcw.dev"
ENV \
    DEBIAN_FRONTEND="noninteractive" \
    PUID="${PUID:-99}" \
    PGID="${PGID:-100}" \
    LGSM_COMMON_CONFIG_FILE="" \
    LGSM_COMMON_CONFIG="" \
    LGSM_GAMESERVER_RENAME="" \
    LGSM_GAMESERVER_START="false" \
    LGSM_GAMESERVER_UPDATE="true" \
    LGSM_GAMESERVER="" \
    LGSM_SERVER_CONFIG_FILE="" \
    LGSM_SERVER_CONFIG="" \
    LGSM_VERSION="latest" \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8 \
    TERM="xterm" \
    TZ="America/Chicago"
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# packages & configure
RUN \
    echo "**** configure locale ****" && \
    DEBIAN_FRONTEND=noninteractive apt-get update --quiet && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        apt-utils \
        debconf-utils \
        locales \
        software-properties-common && \
    localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8 && \
    ln -nfs /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN \
    echo "**** install runtime packages ****" && \
    add-apt-repository multiverse && \
    DEBIAN_FRONTEND=noninteractive apt-get update --quiet && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        cron \
        bc \
        binutils \
        bsdmainutils \
        bzip2 \
        ca-certificates \
        cpio \
        cron \
        curl \
        distro-info \
        file \
        gzip \
        hostname \
        iproute2 \
        iputils-ping \
        jq \
        lib32gcc1 \
        lib32stdc++6 \
        netcat \
        python3 \
        sudo \
        tar \
        tini \
        tmux \
        tzdata \
        unzip \
        util-linux \
        vim \
        wget \
        xz-utils \
        wget && \
    echo "**** install steamcmd ****" && \
    echo steam steam/question select "I AGREE" | debconf-set-selections && \
    echo steam steam/license note '' | debconf-set-selections && \
    dpkg --add-architecture i386 && \
    DEBIAN_FRONTEND=noninteractive apt-get update --quiet && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        libsdl2-2.0-0:i386 \
        steamcmd && \
    ln -s /usr/games/steamcmd /usr/bin/steamcmd && \
    echo "**** install nodejs ****" && \
    curl -sL https://deb.nodesource.com/setup_16.x | bash - && \
    DEBIAN_FRONTEND=noninteractive apt-get update --quiet && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        nodejs && \
    echo "**** install GameDig ****" && \
    npm install -g gamedig && \
    echo "**** add steam user ****" && \
    adduser \
        --disabled-login \
        --disabled-password \
        --shell /bin/bash \
        --gecos "" \
        --uid "${PUID}" \
        --gid "${PGID}" \
        linuxgsm && \
    usermod -G sudo,tty linuxgsm && \
    echo "linuxgsm ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/linuxgsm && \
    chmod 0440 /etc/sudoers.d/linuxgsm && \
    echo "**** add linuxgsm cron ****" && \
    (crontab -l 2>/dev/null; echo "*/5 * * * * /home/linuxgsm/*server monitor > /dev/null 2>&1") | crontab - && \
    (crontab -l 2>/dev/null; echo "*/30 * * * * /home/linuxgsm/*server update > /dev/null 2>&1") | crontab - && \
    (crontab -l 2>/dev/null; echo "0 1 * * 0 /home/linuxgsm/*server update-lgsm > /dev/null 2>&1") | crontab - && \
    echo "**** cleanup ****" && \
    apt-get clean && \
    rm -rf \
        /tmp/* \
        /var/lib/apt/lists/* \
        /var/tmp/*

# copy root filesystem
COPY ./src /
USER linuxgsm
WORKDIR /home/linuxgsm

# external
ENTRYPOINT [ "/usr/bin/tini", "--" ]
CMD [ "/bin/bash", "/entrypoint.sh" ]
HEALTHCHECK --interval=60s --timeout=30s --start-period=300s --retries=3 CMD [ "/lgsm_healthcheck.sh" ]
