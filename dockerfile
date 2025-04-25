FROM debian:bookworm-slim

# System-Tools, Xpra und SDL
RUN apt-get update && apt-get install -y \
    wget curl unzip ca-certificates \
    xpra xpra-html5 \
    libsdl2-2.0-0 libsdl2-net-2.0-0 \
    xserver-xorg-core xserver-xorg-video-dummy \
    dbus-x11 \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Ressourcen für Basebox
COPY config/resources /tmp/resources

# Basebox (PC/GEOS-spezifische Version) installieren
RUN wget -O /tmp/pcgeos-basebox.zip https://github.com/bluewaysw/pcgeos-basebox/releases/download/CI-latest-issue-2/pcgeos-basebox.zip && \
    unzip /tmp/pcgeos-basebox.zip -d /opt/basebox && \
    cp -r /tmp/resources /opt/basebox/pcgeos-basebox/binl64/ && \
    install -m 755 /opt/basebox/pcgeos-basebox/binl64/basebox /usr/local/bin/basebox && \
    rm -rf /tmp/pcgeos-basebox.zip

# Basebox-Konfiguration
COPY ./config/basebox.conf /root/basebox.conf

# GEOS herunterladen und entpacken
RUN mkdir -p /root/geos && \
    wget -O /tmp/geos.zip https://github.com/bluewaysw/pcgeos/releases/download/CI-latest/pcgeos-ensemble_nc.zip && \
    unzip /tmp/geos.zip -d /root/geos && \
    rm /tmp/geos.zip

# Startup-Skript für Xpra
COPY config/start-xpra-geos.sh /usr/local/bin/startup.sh
RUN chmod +x /usr/local/bin/startup.sh

# Port für XPRA Web-Client
EXPOSE 10000

# Entry Point
CMD ["/usr/local/bin/startup.sh"]
