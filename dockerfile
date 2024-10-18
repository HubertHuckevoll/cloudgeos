# Use a Debian base image
FROM debian:latest

# Install necessary packages
RUN apt-get update && apt-get install -y \
    tightvncserver \
    xvfb \
    websockify \
    x11vnc \
    sudo \
    git \
    procps \
    libsdl2-dev \
    libsdl2-net-2.0-0 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Download and set up noVNC
RUN git clone https://github.com/novnc/noVNC.git /opt/novnc \
    && git clone https://github.com/novnc/websockify /opt/novnc/utils/websockify \
    && ln -s /opt/novnc/vnc_lite.html /opt/novnc/index.html

# Set the TERM environment variable globally for DOSBox
#ENV TERM=xterm
ENV SDL_VIDEODRIVER=x11
ENV DISPLAY=:1
#ENV SDL_NOMOUSEGRAB=1
ENV SDL_MOUSE_RELATIVE=0
#ENV SDL_GRAB_MOUSE=0
ENV SDL_MOUSE_RELATIVE=0

#ENV SDL_VIDEO_X11_MOUSEACCEL=1/1/1

# Set the working directory
#WORKDIR /root/localpc

# Copy PC/GEOS installation to the container
COPY ./localpc/ensemble /root/localpc/ensemble

# Copy basebox
COPY ./pcgeos-basebox/ /root/pcgeos-basebox

# Copy the dosbox.conf file into the container
COPY ./basebox.conf /root

# Expose ports for VNC and noVNC
EXPOSE 5901 6080

# Start Xvfb (virtual display), dosbox, x11vnc, and websockify
# x11vnc -display :1 -rfbport 5901 -nopw -listen localhost -grabkbd -grabptr -forever -noxrecord -noxfixes & \
# /opt/novnc/utils/novnc_proxy --vnc localhost:5901 --listen 6080 --web /opt/novnc --vnc_auto=true & \
CMD /usr/bin/Xvfb :1 -screen 0 800x600x16 +extension XTEST & \  
    x11vnc -display :1 -rfbport 5901 -nopw -listen localhost -forever -noxrecord -noxfixes & \ 
    /opt/novnc/utils/novnc_proxy --vnc localhost:5901 --listen 6080 --web /opt/novnc & \
    /root/pcgeos-basebox/binl64/basebox -conf /root/basebox.conf
