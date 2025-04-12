#!/bin/bash
set -e

echo "Starting D-Bus..."
eval "$(dbus-launch --sh-syntax)"

echo "Setting environment for SDL and mouse input..."
export DISPLAY=:1
export SDL_VIDEODRIVER=x11
export SDL_HINT_MOUSE_RELATIVE_MODE_WARP=1
export SDL_MOUSEDEV=""
export SDL_DEBUG=1
export SDL_VIDEO_X11_WMCLASS=basebox

echo "Starting TigerVNC (Xvnc)..."
/usr/bin/Xvnc :1 \
  -geometry 800x600 \
  -depth 16 \
  -SecurityTypes None \
  -AlwaysShared &

sleep 2  # give Xvnc time to initialize

echo "Starting Dosbox-Staging"
/usr/local/bin/dosbox-staging -conf /root/basebox.conf &

#echo "Starting Basebox..."
#/root/pcgeos-basebox/binl64/basebox -conf /root/basebox.conf &

echo "Starting noVNC..."
/usr/bin/websockify --web=/usr/share/novnc 6080 localhost:5901

# Keep the script running
wait
