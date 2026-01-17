#!/bin/bash
# Build MYD-LR3576 flashable image
# Usage: ./build_image.sh
#
# This script will:
#   1. Decompress all .gz files (tools + image files)
#   2. Download rootfs.img from Google Drive (if not cached)
#   3. Pack the final image using afptool and rkImageMaker

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
GZ_DIR="$SCRIPT_DIR/gz"
BUILD_DIR="$SCRIPT_DIR/build"
ALL_DIR="$BUILD_DIR/all"
TOOLS_DIR="$BUILD_DIR/tools"
OUTPUT_IMAGE="$SCRIPT_DIR/myir-image-lr3576-debian.img"

#----------------------------------------
# Check dependencies
#----------------------------------------
check_deps() {
    for cmd in gzip gdown; do
        if ! command -v "$cmd" &> /dev/null; then
            echo "Error: '$cmd' not found"
            echo "Install with: pip install gdown"
            exit 1
        fi
    done
}

#----------------------------------------
# Download rootfs.img from Google Drive
#----------------------------------------
download_rootfs() {
    local url
    url=$(cat "$SCRIPT_DIR/ROOTFS_URL.txt" | tr -d '\n')

    if [ -f "$BUILD_DIR/rootfs.img" ]; then
        echo "rootfs.img already exists, skipping download"
        echo "(Delete build/rootfs.img to re-download)"
        return
    fi

    echo "Downloading rootfs.img from Google Drive..."
    gdown "$url" -O "$BUILD_DIR/rootfs.img"
}

#----------------------------------------
# Main
#----------------------------------------
main() {
    echo "=========================================="
    echo "  MYD-LR3576 Image Builder"
    echo "=========================================="

    check_deps

    # Clean and create directories
    rm -rf "$ALL_DIR" "$TOOLS_DIR"
    mkdir -p "$ALL_DIR" "$TOOLS_DIR"
    mkdir -p "$BUILD_DIR"

    # Step 1: Decompress tools
    echo ""
    echo "[1/4] Decompressing tools..."
    gzip -dc "$GZ_DIR/afptool.gz" > "$TOOLS_DIR/afptool"
    gzip -dc "$GZ_DIR/rkImageMaker.gz" > "$TOOLS_DIR/rkImageMaker"
    chmod +x "$TOOLS_DIR/afptool" "$TOOLS_DIR/rkImageMaker"

    # Step 2: Decompress image files
    echo ""
    echo "[2/4] Decompressing image files..."
    for gz_file in "$GZ_DIR"/*.gz; do
        filename=$(basename "$gz_file" .gz)

        # Skip tools (already handled)
        [ "$filename" = "afptool" ] && continue
        [ "$filename" = "rkImageMaker" ] && continue

        # boot.bin goes to BUILD_DIR, others go to ALL_DIR
        if [ "$filename" = "boot.bin" ]; then
            echo "  $filename"
            gzip -dc "$gz_file" > "$BUILD_DIR/$filename"
        else
            echo "  $filename"
            gzip -dc "$gz_file" > "$ALL_DIR/$filename"
        fi
    done

    # Step 3: Download rootfs.img
    echo ""
    echo "[3/4] Getting rootfs.img..."
    download_rootfs
    cp "$BUILD_DIR/rootfs.img" "$ALL_DIR/"

    # Step 4: Pack final image
    echo ""
    echo "[4/4] Packing final image..."
    "$TOOLS_DIR/afptool" -pack "$ALL_DIR" "$BUILD_DIR/firmware.img"
    "$TOOLS_DIR/rkImageMaker" -RK3576 "$BUILD_DIR/boot.bin" \
        "$BUILD_DIR/firmware.img" \
        "$OUTPUT_IMAGE" \
        -os_type:androidos

    echo ""
    echo "=========================================="
    echo "  Build complete!"
    echo "  Output: $OUTPUT_IMAGE"
    echo "=========================================="
    ls -lh "$OUTPUT_IMAGE"
}

main "$@"
