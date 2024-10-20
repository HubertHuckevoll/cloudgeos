#!/bin/bash

# Set environment variables for SDL and X11
export SDL_VIDEODRIVER=x11
export DISPLAY=:1
export SDL_MOUSE_RELATIVE=0

# Autostart configuration: Add the commands to run dosbox-staging
mkdir -p /root/.config/lxsession/LXDE && echo "/root/pcgeos-basebox/binl64/basebox -conf /root/basebox.conf" > /root/.config/lxsession/LXDE/autostart

# Launch xvfb
/usr/bin/Xvfb :1 -screen 0 1024x768x16 +extension XTEST & \

# start LXDE, needed for mouse to work!
startlxde & \

# start X11VNC
x11vnc -display :1 -rfbport 5901 -nopw -forever -noxrecord -noxfixes -grabptr -scale_cursor 1 & \

# make sure display mouse is not accelerated (?)
sleep 5 && xset -display :1 m 0 0 && \

# launch noVNC web frontend (client)
/opt/novnc/utils/novnc_proxy --vnc localhost:5901 --listen 6080 --web /opt/novnc