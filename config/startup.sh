#!/bin/sh

# Port und Display
PORT=10000
DISPLAY_NUM=10

# SDL: Raw Input
export SDL_MOUSE_RELATIVE=1
export SDL_VIDEO_X11_MOUSE_WARP=0

# Cleanup
rm -rf /tmp/.X11-unix/X$DISPLAY_NUM /tmp/xpra.$USER

# Start Xpra mit echtem Xorg (nicht Xvfb!)
exec xpra start :$DISPLAY_NUM \
  --start-child="basebox" \
  --html=on \
  --bind-tcp=0.0.0.0:$PORT \
  --xvfb="Xorg -noreset +extension GLX +extension RANDR +extension RENDER" \
  --input-devices=all \
  --daemon=no \
  --exit-with-children
