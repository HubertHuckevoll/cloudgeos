#!/bin/bash

# Set environment variables for SDL and X11
export SDL_VIDEODRIVER=x11
export DISPLAY=:1
export SDL_MOUSE_RELATIVE=0
export SDL_VIDEO_X11_MOUSEACCEL=0/0/0

# Autostart configuration: Add the commands to run dosbox-staging via LXDE
mkdir -p /root/.config/lxsession/LXDE && \
    echo "/root/pcgeos-basebox/binl64/basebox -conf /root/basebox.conf" > /root/.config/lxsession/LXDE/autostart

# Start Xvfb (Virtual framebuffer)
/usr/bin/Xvfb :1 -screen 0 1024x768x16 +extension XTEST &

# Start dbus (ensure dbus is running for lxsession)
dbus-launch --exit-with-session &

# Start LXDE session (including lxsession)
/usr/bin/lxsession &

# Start VNC server for remote access
# -grabptr
x11vnc -display :1 -ncache 10 -rfbport 5901 -nopw -forever -noxrecord -noxfixes -scale_cursor 1 &

# Start noVNC for web-based access
sleep 5 && /opt/novnc/utils/novnc_proxy --vnc localhost:5901 --listen 6080 --web /opt/novnc &

# Wait for dosbox-staging process to start
while ! pgrep -f "basebox"; do
    sleep 1
done

# Continuously monitor dosbox-staging process, and shut down LXDE when it ends
while pgrep -f "basebox" > /dev/null; do
    sleep 1
done

# Shutdown LXDE and the container when dosbox-staging closes
echo "Basebox closed, shutting down LXDE and container..."
pkill -u root -x lxsession
