FROM debian:bookworm-slim

# System-Tools, VNC, SDL und Entwicklungswerkzeuge
RUN apt-get update && apt-get install -y \
    wget curl gnupg unzip ca-certificates \
    tigervnc-standalone-server \
    libsdl2-2.0-0 libsdl2-net-2.0-0 \
    python3-websockify novnc \
    dbus-x11 \
    xserver-xorg-input-evdev \
    git build-essential gcc libevdev-dev \
    matchbox-window-manager \
    x11-utils \
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

# Optional: noVNC Fix (für index.html)
RUN ln -s /usr/share/novnc/vnc.html /usr/share/novnc/index.html

# Startup-Skript kopieren und ausführbar machen
COPY config/startup.sh /root/startup.sh
RUN chmod +x /root/startup.sh

# Setze Display fest
ENV DISPLAY=:1

# Expose VNC + Web
EXPOSE 5901 6080

# Verwende supervisord oder ein minimales Startskript
CMD ["/root/startup.sh"]
