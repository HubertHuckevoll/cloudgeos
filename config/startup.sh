#!/bin/bash

# GEOS als Festplatte (C:), Bootdisk als A:
qemu-system-i386 \
  -drive file=/opt/freedos.img,format=raw,if=floppy \
  -drive file=/opt/geos.img,format=raw,if=ide \
  -boot a \
  -m 16M \
  -vnc :0 &

sleep 2
exec websockify --web=/opt/novnc 6080 localhost:5900
