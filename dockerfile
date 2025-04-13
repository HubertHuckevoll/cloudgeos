FROM debian:bookworm-slim

# Installiere QEMU, wget, unzip, Python3, websockify und Git für noVNC
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        qemu-system-i386 \
        wget \
        unzip \
        python3 \
        python3-websockify \
        ca-certificates \
        git && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /opt

# Kopiere lokale Bootdisk
COPY config/DOS622.img /opt/freedos.img

# GEOS nach /opt/geos herunterladen und entpacken
RUN mkdir -p /opt/geos && \
    wget -O /tmp/geos.zip https://github.com/bluewaysw/pcgeos/releases/download/CI-latest/pcgeos-ensemble_nc.zip && \
    unzip /tmp/geos.zip -d /opt/geos && \
    rm /tmp/geos.zip

# Schreibrechte setzen
RUN chmod -R a+rwX /opt/geos && chmod 644 /opt/freedos.img

# noVNC klonen und vorbereiten
RUN git clone --depth 1 https://github.com/novnc/noVNC.git /opt/novnc && \
    ln -s /opt/novnc/vnc.html /opt/novnc/index.html

# Startup-Skript kopieren
COPY config/startup.sh /opt/startup.sh
RUN chmod +x /opt/startup.sh

EXPOSE 6080

CMD ["/opt/startup.sh"]
