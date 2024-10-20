#!/bin/bash

# Set environment variables for SDL and X11
export SDL_VIDEODRIVER=x11
export DISPLAY=:1
export SDL_MOUSE_RELATIVE=0

# Autostart configuration: Add the commands to run dosbox-staging
mkdir -p /root/.config/lxsession/LXDE && echo "/root/pcgeos-basebox/binl64/basebox -conf /root/basebox.conf" > /root/.config/lxsession/LXDE/autostart

# Start Xvfb (Virtual framebuffer)
/usr/bin/Xvfb :1 -screen 0 1024x768x16 +extension XTEST &

# Start Polkit for authentication
/usr/lib/policykit-1/polkitd --no-debug &

# Start dbus (ensure dbus is running for lxsession)
dbus-launch &

# Start LXDE session (including lxsession)
/usr/bin/lxsession &

# Start VNC server for remote access
x11vnc -display :1 -rfbport 5901 -nopw -forever -noxrecord -noxfixes -grabptr -scale_cursor 1 &

# Start noVNC for web-based access
sleep 5 && /opt/novnc/utils/novnc_proxy --vnc localhost:5901 --listen 6080 --web /opt/novnc &

# Start DOSBox-Staging
#/root/pcgeos-basebox/binl64/basebox -conf /root/basebox.conf

# Ensure the script waits for all background processes to finish
wait
