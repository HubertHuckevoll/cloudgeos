FROM debian:bookworm-slim

# Install QEMU, websockify, wget, Python3, unzip, ca-certs
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        qemu-system-i386 \
        wget \
        python3 \
        python3-websockify \
        unzip \
        ca-certificates \
        git && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Arbeitsverzeichnis
WORKDIR /opt

# Download FreeDOS boot floppy
RUN wget -O freedos.img \
    https://raw.githubusercontent.com/codercowboy/freedosbootdisks/master/bootdisks/freedos.boot.disk.1.4MB.img

# Hole noVNC (minimaler Clone)
RUN git clone --depth 1 https://github.com/novnc/noVNC.git /opt/novnc && \
    ln -s /opt/novnc/vnc.html /opt/novnc/index.html

# Kopiere Startup-Skript in Container
COPY config/startup.sh /opt/startup.sh
RUN chmod +x /opt/startup.sh

# Ports: 6080 = noVNC Websocket, 5900 = QEMU VNC
EXPOSE 6080

# Start-Skript
CMD ["/opt/startup.sh"]
