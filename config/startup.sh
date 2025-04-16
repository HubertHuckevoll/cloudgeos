#!/bin/sh

# Starte Xvnc sauber
Xvnc :1 -geometry 800x600 -depth 24 -SecurityTypes None &
sleep 2

# SDL-Konfig
export SDL_VIDEODRIVER=x11
export SDL_RENDER_DRIVER=software
export SDL_OPENGL=0
export LIBGL_ALWAYS_SOFTWARE=true

# Starte Window Manager (optional)
matchbox-window-manager -use_cursor no -use_titlebar no &

# Starte noVNC
websockify --web=/usr/share/novnc/ 6080 localhost:5901 &

# Starte GEOS/Basebox
basebox -conf /root/basebox.conf
