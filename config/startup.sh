#!/bin/bash

# Enable debugging mode (uncomment if needed)
# set -x

# Define a log file and redirect output
LOGFILE="/var/log/startup.log"
exec > >(tee -a "$LOGFILE") 2>&1

echo "Starting startup script at $(date)"

# Abort on any error
set -e

# Set environment variables for SDL and X11
echo "Setting environment variables for SDL and X11..."
export SDL_VIDEODRIVER=x11
export DISPLAY=:1
export SDL_MOUSE_RELATIVE=0
export SDL_VIDEO_X11_MOUSEACCEL=0/0/0
echo "Environment variables set."

# Start Xvfb (Virtual framebuffer)
echo "Starting Xvfb..."
/usr/bin/Xvfb :1 -screen 0 1024x768x16 +extension XTEST &
sleep 2
echo "Xvfb started successfully."

# Start dbus
echo "Starting dbus..."
eval $(dbus-launch --sh-syntax)
sleep 2
echo "dbus started successfully."

# Start LXDE
echo "Starting LXDE session..."
/usr/bin/lxsession &
sleep 2
echo "LXDE session started successfully."

# Start VNC server
echo "Starting x11vnc server..."
x11vnc -display :1 -ncache 10 -rfbport 5901 -nopw -forever -noxrecord -noxfixes -scale_cursor 1 &
sleep 5
echo "x11vnc server started successfully."

# Start noVNC
echo "Starting noVNC server..."
/opt/novnc/utils/novnc_proxy --vnc localhost:5901 --listen 6080 --web /opt/novnc &
sleep 5
echo "noVNC server started successfully."

# Show valid noVNC URL
echo ""
echo "------------------------------------------------------"
echo "VNC is available at: http://localhost:6080/vnc.html"
echo "------------------------------------------------------"
echo ""

# Start basebox directly
echo "Starting basebox..."
/root/pcgeos-basebox/binl64/basebox -conf /root/basebox.conf &
BASEBOX_PID=$!

# Wait for basebox to terminate
echo "Monitoring basebox (PID=$BASEBOX_PID)..."
wait $BASEBOX_PID

# Cleanup and shutdown
echo "Basebox closed, shutting down LXDE and container..."
pkill -u root -x lxsession || echo "LXDE was not running or already closed."

echo "Startup script finished at $(date)"
