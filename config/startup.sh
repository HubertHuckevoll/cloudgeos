#!/bin/sh

# Port und Display
PORT=10000
DISPLAY_NUM=10

# SDL: Raw Input
export SDL_VIDEO_X11_MOUSE_WARP=0
export SDL_MOUSE_RELATIVE=0
export SDL_VIDEO_X11_DGAMOUSE=0

# Shader-Verzeichnis setzen (sehr wichtig!)
cd /usr/local/share/basebox/resources

# Cleanup
rm -rf /tmp/.X11-unix/X$DISPLAY_NUM /tmp/xpra.$USER

# Start Xpra mit echtem Xorg
exec xpra start :$DISPLAY_NUM \
  --start-child="basebox -conf /root/basebox.conf" \
  --html=on \
  --bind-tcp=0.0.0.0:$PORT \
  --xvfb="Xorg -noreset +extension GLX +extension RANDR +extension RENDER" \
  --input-devices=none \
  --daemon=no \
  --exit-with-children
