#!/bin/bash

# Starte QEMU mit explizitem PS/2-Maus-Support (Standard, ohne USB-Geräte)
qemu-system-i386 \
  -vga std \
  -m 16M \
  -drive file=/opt/geos.img,format=raw,if=ide \
  -boot c \
  -no-reboot \
  -vnc :0 &

sleep 2
exec websockify --web=/opt/novnc 6080 localhost:5900
