#!/bin/bash

set -e

IMAGE=./geos.img
IMAGE_SIZE_MB=64

echo "🛠 Erstelle leeres ${IMAGE_SIZE_MB} MiB großes Image: $IMAGE"
dd if=/dev/zero of="$IMAGE" bs=1M count=$IMAGE_SIZE_MB

echo "🧩 Erstelle Partitionstabelle mit parted (msdos + 1 primäre Partition)"
parted -s "$IMAGE" mklabel msdos
parted -s "$IMAGE" mkpart primary fat16 1MiB 100%

echo "🔍 Suche freien Loop Device"
LOOPDEV=$(losetup -f)
echo "📎 Binde Image an $LOOPDEV"
losetup -P "$LOOPDEV" "$IMAGE"

echo "🧼 Formatiere Partition als FAT16"
mkfs.fat -F 16 "${LOOPDEV}p1"

echo "📴 Trenne Loop Device wieder"
losetup -d "$LOOPDEV"

echo "✅ Fertig: $IMAGE ist nun eine MBR-basierte FAT16-Festplatte"
