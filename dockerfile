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

# GEOS herunterladen und entpacken
RUN mkdir -p /opt/geos_src && \
    wget -O /tmp/geos.zip https://github.com/bluewaysw/pcgeos/releases/download/CI-latest/pcgeos-ensemble_nc.zip && \
    unzip /tmp/geos.zip -d /opt/geos_src && \
    rm /tmp/geos.zip

# DOS-Image mit vorinstalliertem MS-DOS kopieren
COPY config/dos622dsk.img /opt/geos.img

# GEOS nach C:\GEOS kopieren (Partition beginnt bei Offset 32256)
RUN mmd -i /opt/geos.img@@32256 ::/GEOS && \
    mcopy -i /opt/geos.img@@32256 -s /opt/geos_src/* ::/GEOS/

# Copy ctmouse
COPY config/ctmouse.exe /opt/ctmouse.exe
RUN mcopy -i /opt/geos.img@@32256 /opt/ctmouse.exe ::/

# noVNC installieren
RUN git clone --depth 1 https://github.com/novnc/noVNC.git /opt/novnc && \
    ln -s /opt/novnc/vnc.html /opt/novnc/index.html

# Startup-Skript kopieren
COPY config/startup.sh /opt/startup.sh
RUN chmod +x /opt/startup.sh

EXPOSE 6080

CMD ["/opt/startup.sh"]
