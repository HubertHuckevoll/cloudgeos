FROM debian:bookworm-slim

# Tools installieren
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        qemu-system-i386 \
        wget \
        unzip \
        mtools \
        dosfstools \
        parted \
        python3 \
        python3-websockify \
        ca-certificates \
        git && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /opt

# MS-DOS 6.22 Bootdisk kopieren
COPY config/DOS622.img /opt/freedos.img

# GEOS herunterladen und vorbereiten
RUN mkdir -p /opt/geos_src && \
    wget -O /tmp/geos.zip https://github.com/bluewaysw/pcgeos/releases/download/CI-latest/pcgeos-ensemble_nc.zip && \
    unzip /tmp/geos.zip -d /opt/geos_src && \
    rm /tmp/geos.zip

# GEOS.img (mit Partitionstabelle, aber unformatiert) in Container kopieren
COPY config/geos.img /opt/geos.img

# GEOS herunterladen und vorbereiten
RUN mkdir -p /opt/geos_src && \
    wget -O /tmp/geos.zip https://github.com/bluewaysw/pcgeos/releases/download/CI-latest/pcgeos-ensemble_nc.zip && \
    unzip -o /tmp/geos.zip -d /opt/geos_src && \
    rm /tmp/geos.zip

# FAT16-Dateisystem ab Offset 1 MiB (2048 * 512) formatieren + GEOS-Dateien hineinkopieren
RUN mformat -i /opt/geos.img@@1048576 -h 64 -t 64 -n 32 :: && \
    mcopy -i /opt/geos.img@@1048576 -s /opt/geos_src/* ::/

# noVNC installieren
RUN git clone --depth 1 https://github.com/novnc/noVNC.git /opt/novnc && \
    ln -s /opt/novnc/vnc.html /opt/novnc/index.html

# Startup-Skript kopieren
COPY config/startup.sh /opt/startup.sh
RUN chmod +x /opt/startup.sh

EXPOSE 6080

CMD ["/opt/startup.sh"]
