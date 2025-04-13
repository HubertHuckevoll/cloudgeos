#!/bin/bash

# Starte QEMU im Hintergrund (VNC auf :0 = TCP 5900)
qemu-system-i386 \
  -drive file=/opt/freedos.img,format=raw,if=floppy \
  -boot a \
  -m 16M \
  -vnc :0 &

# Warte kurz, damit QEMU läuft
sleep 2

# Starte websockify für noVNC (WebSocket-Proxy auf Port 6080)
exec websockify --web=/opt/novnc 6080 localhost:5900
