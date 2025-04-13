#!/bin/bash

# Starte QEMU mit:
# - A: = FreeDOS 1.4 Bootdisk (lokale x86BOOT.img)
# - C: = GEOS als beschreibbares FAT-Laufwerk
qemu-system-i386 \
  -drive file=/opt/freedos.img,format=raw,if=floppy \
  -drive file=fat:rw:/opt/geos,format=raw,media=disk \
  -boot a \
  -m 16M \
  -vnc :0 &

# Websockify starten
sleep 2
exec websockify --web=/opt/novnc 6080 localhost:5900
