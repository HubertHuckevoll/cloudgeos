# Docker commands
# Clean up: sudo docker system prune --all --force

# Use a Debian base image
# FROM debian:bookworm-slim
FROM debian:stable-slim

# Install necessary packages including LXDE, dosbox-staging, and VNC server
RUN apt-get update && apt-get install -y \
    lxde \
    xvfb \
    websockify \
    x11vnc \
    sudo \
    git \
    procps \
    libsdl2-dev \
    libsdl2-net-2.0-0 \
    dbus-x11 \
    lxappearance \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# this is part of policykit-1 and produces error messages on startup
# therefore it has to go
RUN apt-get remove -y lxpolkit

# Download and set up noVNC
RUN git clone https://github.com/novnc/noVNC.git /opt/novnc \
    && git clone https://github.com/novnc/websockify /opt/novnc/utils/websockify \
    && ln -s /opt/novnc/vnc_lite.html /opt/novnc/index.html

# Copy PC/GEOS installation to the container
COPY ./localpc/ensemble /root/localpc/ensemble

# Copy basebox and basebox.conf
COPY ./pcgeos-basebox/ /root/pcgeos-basebox
COPY ./config/basebox.conf /root

# Copy the configuration files for openbox
COPY ./config/desktop-items-0.conf /root/.config/pcmanfm/LXDE/desktop-items-0.conf
COPY ./config/rc.xml /root/.config/openbox/rc.xml

# Expose ports for VNC and noVNC
EXPOSE 5901 6080

# Copy the startup script
COPY ./config/startup.sh /root/startup.sh
RUN chmod +x /root/startup.sh

# Start Xvfb, LXDE, x11vnc, and noVNC
CMD ["/root/startup.sh"]
