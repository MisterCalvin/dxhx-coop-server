FROM i386/alpine

ARG S6_OVERLAY_VERSION=3.1.6.0
ARG HX_VERSION=0.9.89.4

ENV \
  S6_CATCHALL_USER="wine" \
  S6_VERBOSITY="0" \ 
  UMASK="022" \
  PUID="1000" \
  PGID="1000" \
  WINEDEBUG="-all" \
  WINEARCH="win32" \
  WINEPREFIX="/container/.wine" \
  SERVER_NAME="Another Docker DXHX Coop Server" \
  SERVER_PASSWORD="" \
  SERVER_INI="" \
  SERVER_PORT="7990" \  
  MAP="00_Training" \
  ADMIN_PASSWORD="" \
  MUTATORS="" \
  MAX_PLAYERS="8" \
  DIFFICULTY="1" \
  ADDITIONAL_ARGS="" \
  INSTALL_HX=""

RUN apk add --no-cache \ 
  	'wine'  \
	'shadow' \
	'tzdata' \
	'wget' && \ 
	wget -q -nc --show-progress --progress=bar:force:noscroll --no-hsts -O /tmp/s6-overlay-noarch.tar.xz --user-agent=Mozilla --content-disposition -E -c "https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz" && \
	wget -q -nc --show-progress --progress=bar:force:noscroll --no-hsts -O /tmp/s6-overlay-x86_64.tar.xz --user-agent=Mozilla --content-disposition -E -c "https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-x86_64.tar.xz" && \
	wget -q -nc --show-progress --progress=bar:force:noscroll --no-hsts -O /tmp/HX.zip --user-agent=Mozilla --content-disposition -E -c "https://builds.hx.hanfling.de/testing/HX-${HX_VERSION}.zip" && \
        mkdir -pm 760 /container/ServerFiles/HX && \
        tar -C / -Jxpf /tmp/s6-overlay-noarch.tar.xz && \
	tar -C / -Jxpf /tmp/s6-overlay-x86_64.tar.xz && \
	unzip /tmp/HX.zip -d /container/ServerFiles/HX/ && \
        rm /tmp/* && \
        wineboot -i && \
	rm -rf $WINEPREFIX/drive_c/windows/Installer && \
	rm -rf $WINEPREFIX/drive_c/windows/mono && \
	rm -rf $WINEPREFIX/drive_c/windows/system32/gecko/ && \
	rm -rf $WINEPREFIX/drive_c/windows/syswow64/gecko/ && \
	addgroup --gid $PGID wine && \
	adduser --uid $PUID --home /container --disabled-password --no-create-home --shell /bin/false --ingroup wine wine && \
        chown -R wine:wine /container && \
        apk --purge del wget

WORKDIR /container/deusex

COPY	./root /
COPY ./dxhx_startup.sh /usr/bin/dxhx_startup.sh
COPY ./HX.ini /container/ServerFiles/

EXPOSE 7790-7792/udp

ENTRYPOINT [ "/init" ]

LABEL \
  org.opencontainers.image.authors="Kevin Moore" \
  org.opencontainers.image.title="DXHX Coop Server" \
  org.opencontainers.image.description="Docker container for running a Deus Ex Coop Dedicated Server" \
  org.opencontainers.image.source=https://github.com/MisterCalvin/dxhx-coop-server \
  org.opencontainers.image.version="1.0" \
  org.opencontainers.image.licenses=MIT
