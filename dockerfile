FROM debian:bookworm

# System-Tools, VNC, SDL und Entwicklungswerkzeuge
RUN apt-get update && apt-get install -y \
    wget curl gnupg unzip ca-certificates \
    tigervnc-standalone-server \
    libsdl2-2.0-0 libsdl2-net-2.0-0 \
    python3-websockify novnc \
    dbus-x11 \
    xserver-xorg-input-evdev \
    git build-essential gcc libevdev-dev \
    xautomation

# DOSBox-Staging herunterladen und installieren (inkl. resources)
RUN wget -O /tmp/dosbox-staging.tar.xz https://github.com/dosbox-staging/dosbox-staging/releases/download/v0.82.1/dosbox-staging-linux-x86_64-v0.82.1.tar.xz && \
    mkdir -p /opt/dosbox-staging && \
    tar -xf /tmp/dosbox-staging.tar.xz -C /opt/dosbox-staging && \
    install -m 755 $(find /opt/dosbox-staging -type f -name dosbox) /usr/local/bin/dosbox-staging && \
    mkdir -p /root/.config/dosbox && \
    cp -r $(find /opt/dosbox-staging -type d -name glshaders) /root/.config/dosbox/ && \
    rm -rf /tmp/dosbox-staging.tar.xz

# Basebox hinzufügen
# COPY pcgeos-basebox/ /root/pcgeos-basebox/

# Basebox-Konfiguration kopieren
COPY ./config/basebox.conf /root/basebox.conf

# GEOS herunterladen und entpacken
RUN mkdir -p /root/geos && \
    wget -O /tmp/geos.zip https://github.com/bluewaysw/pcgeos/releases/download/CI-latest/pcgeos-ensemble_nc.zip && \
    unzip /tmp/geos.zip -d /root/geos && \
    rm /tmp/geos.zip

# Optional: noVNC fix
RUN ln -s /usr/share/novnc/vnc.html /usr/share/novnc/index.html

# Startskript kopieren und ausführbar machen
COPY config/startup.sh /root/startup.sh
RUN chmod +x /root/startup.sh

# Aufräumen zum Schluss
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

EXPOSE 5901 6080
CMD ["/root/startup.sh"]
