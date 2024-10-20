# Docker commands
# 
#sudo docker stop $(sudo docker ps -a -q)

# Use a Debian base image
FROM debian:bookworm-slim

# Install necessary packages including LXDE, dosbox-staging, and VNC server
RUN apt-get update && apt-get install -y \
    lxde \
    tigervnc-standalone-server \
    tigervnc-common \
    xvfb \
    websockify \
    x11vnc \
    sudo \
    git \
    procps \
    libsdl2-dev \
    libsdl2-net-2.0-0 \
    python3-pyxdg \
    dbus-x11 \
    lxappearance \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Download and set up noVNC
RUN git clone https://github.com/novnc/noVNC.git /opt/novnc \
    && git clone https://github.com/novnc/websockify /opt/novnc/utils/websockify \
    && ln -s /opt/novnc/vnc_lite.html /opt/novnc/index.html

# Set environment variables for SDL and X11
ENV SDL_VIDEODRIVER=x11
ENV DISPLAY=:1
ENV SDL_MOUSE_RELATIVE=0

# Copy PC/GEOS installation to the container
COPY ./localpc/ensemble /root/localpc/ensemble

# Copy basebox and dosbox.conf
COPY ./pcgeos-basebox/ /root/pcgeos-basebox
COPY ./basebox.conf /root

# Expose ports for VNC and noVNC
EXPOSE 5901 6080

# Autostart configuration: Add the commands to run dosbox-staging
RUN mkdir -p /root/.config/lxsession/LXDE && \
    echo "/root/pcgeos-basebox/binl64/basebox -conf /root/basebox.conf" > /root/.config/lxsession/LXDE/autostart

# Start Xvfb, LXDE, x11vnc, and noVNC
CMD /usr/bin/Xvfb :1 -screen 0 1024x768x16 +extension XTEST & \
    startlxde & \
    x11vnc -display :1 -rfbport 5901 -nopw -forever -noxrecord -noxfixes -grabptr -scale_cursor 1 & \
    sleep 5 && xset -display :1 m 0 0 && \
    /opt/novnc/utils/novnc_proxy --vnc localhost:5901 --listen 6080 --web /opt/novnc
