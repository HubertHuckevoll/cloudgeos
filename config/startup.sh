#!/bin/bash

# Enable debugging mode
# set -x  # Print each command before executing it

# Define a log file
LOGFILE="/var/log/startup.log"
exec > >(tee -a "$LOGFILE") 2>&1

echo "Starting startup script at $(date)"

# Set environment variables for SDL and X11
echo "Setting environment variables for SDL and X11..."
export SDL_VIDEODRIVER=x11
export DISPLAY=:1
export SDL_MOUSE_RELATIVE=0
export SDL_VIDEO_X11_MOUSEACCEL=0/0/0
echo "Environment variables set."

# Autostart configuration: Add the commands to run dosbox-staging via LXDE
echo "Configuring autostart for LXDE..."
mkdir -p /root/.config/lxsession/LXDE && \
    echo "/root/pcgeos-basebox/binl64/basebox -conf /root/basebox.conf" > /root/.config/lxsession/LXDE/autostart
if [ $? -eq 0 ]; then
    echo "Autostart configuration created successfully."
else
    echo "Failed to configure autostart. Exiting."
    exit 1
fi

# Start Xvfb (Virtual framebuffer)
echo "Starting Xvfb..."
/usr/bin/Xvfb :1 -screen 0 1024x768x16 +extension XTEST &
if [ $? -eq 0 ]; then
    echo "Xvfb started successfully."
else
    echo "Failed to start Xvfb. Exiting."
    exit 1
fi
sleep 2

# Start dbus (ensure dbus is running for lxsession)
echo "Starting dbus..."
dbus-launch --exit-with-session &
if [ $? -eq 0 ]; then
    echo "dbus started successfully."
else
    echo "Failed to start dbus. Exiting."
    exit 1
fi
sleep 2

# Start LXDE session (including lxsession)
echo "Starting LXDE session..."
/usr/bin/lxsession &
if [ $? -eq 0 ]; then
    echo "LXDE session started successfully."
else
    echo "Failed to start LXDE session. Exiting."
    exit 1
fi
sleep 2

# Start VNC server for remote access
echo "Starting x11vnc server..."
x11vnc -display :1 -ncache 10 -rfbport 5901 -nopw -forever -noxrecord -noxfixes -scale_cursor 1 &
if [ $? -eq 0 ]; then
    echo "x11vnc server started successfully."
else
    echo "Failed to start x11vnc server. Exiting."
    exit 1
fi
sleep 5

# Start noVNC for web-based access
echo "Starting noVNC server..."
/opt/novnc/utils/novnc_proxy --vnc localhost:5901 --listen 6080 --web /opt/novnc &
if [ $? -eq 0 ]; then
    echo "noVNC server started successfully."
else
    echo "Failed to start noVNC server. Exiting."
    exit 1
fi
sleep 5

# Wait for dosbox-staging (basebox) process to start
echo "Waiting for basebox to start..."
while ! pgrep -f "basebox"; do
    echo "basebox not running yet. Retrying in 1 second..."
    sleep 1
done
echo "basebox started successfully."

# Continuously monitor dosbox-staging process, and shut down LXDE when it ends
echo "Monitoring basebox process..."
while pgrep -f "basebox" > /dev/null; do
    sleep 1
done

# Shutdown LXDE and the container when dosbox-staging closes
echo "Basebox closed, shutting down LXDE and container..."
pkill -u root -x lxsession
if [ $? -eq 0 ]; then
    echo "LXDE shutdown successfully."
else
    echo "Failed to shut down LXDE."
fi

echo "Startup script finished at $(date)"
