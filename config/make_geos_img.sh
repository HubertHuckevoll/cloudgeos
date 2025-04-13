#!/bin/bash
set -e

# Zielverzeichnis
OUT=./
IMG="$OUT/geos.img"

# Imagegröße und Startoffset der Partition
SIZE_MB=64
PART_START_MB=1
PART_START_SECTORS=$((PART_START_MB * 2048))  # 512-byte sectors
PART_OFFSET=$((PART_START_SECTORS * 512))    # Byte-Offset für mcopy

# Pfad zu den GEOS-Dateien
GEOS_SRC=./

echo "🛠️  Erzeuge leeres $SIZE_MB MiB Image..."
mkdir -p "$OUT"
dd if=/dev/zero of="$IMG" bs=1M count=$SIZE_MB

echo "🧱 Erzeuge Partitionstabelle..."
parted -s "$IMG" mklabel msdos
parted -s "$IMG" mkpart primary fat16 ${PART_START_MB}MiB 100%
parted -s "$IMG" set 1 boot on

echo "🧼 Formatiere FAT16-Dateisystem in der Partition..."
mkfs.fat -F 16 "$IMG" --offset=$PART_START_SECTORS

echo "📦 Kopiere GEOS-Dateien ins Image..."
mcopy -i "$IMG@@$PART_OFFSET" -s "$GEOS_SRC"/* ::/

echo "✅ Fertig: $IMG"
