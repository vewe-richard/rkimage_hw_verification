# MYD-LR3576 Debian Image

Build flashable image for MYD-LR3576 board (Rockchip RK3576).

## Quick Start

```bash
git clone https://github.com/xxx/myd-lr3576-image.git
cd myd-lr3576-image
# Download rootfs.img to current directory
./build_image.sh
```

Output: `myir-image-lr3576-debian.img`

## Flash to Board

```bash
sudo upgrade_tool uf myir-image-lr3576-debian.img
```

## Requirements

- gdown: `pip install gdown`

## For Maintainers: Update Image Files

### Update boot.img or uboot.img

```bash
# Compress and replace
gzip -c /path/to/new/boot.img > gz/boot.img.gz
gzip -c /path/to/new/uboot.img > gz/uboot.img.gz

# Commit and push
git add gz/
git commit -m "Update boot.img"
git push
```

### Update rootfs.img

1. Upload new rootfs.img to Google Drive
2. Get shareable link, set "Anyone with link can view"
3. Update `ROOTFS_URL.txt` with the new link

## File Sources

| File | Source |
|------|--------|
| gz/*.gz | GitHub (this repo) |
| rootfs.img | Google Drive (downloaded by script) |

## Directory Structure

```
.
├── gz/                     # Compressed files (on GitHub)
│   ├── boot.img.gz
│   ├── recovery.img.gz
│   ├── uboot.img.gz
│   ├── oem.img.gz
│   ├── userdata.img.gz
│   ├── misc.img.gz
│   ├── MiniLoaderAll.bin.gz
│   ├── parameter.txt.gz
│   ├── package-file.gz
│   ├── boot.bin.gz
│   ├── afptool.gz
│   └── rkImageMaker.gz
├── build_image.sh          # Build script
├── ROOTFS_URL.txt          # Google Drive link for rootfs.img
└── README.md
```

## Build Process

```
build_image.sh
    │
    ├── [1/4] Decompress tools (afptool, rkImageMaker)
    │
    ├── [2/4] Decompress image files to build/all/
    │
    ├── [3/4] Download rootfs.img from Google Drive
    │
    └── [4/4] Pack final image
            ├── afptool -pack build/all/ build/firmware.img
            └── rkImageMaker -RK3576 ... myir-image-lr3576-debian.img
```
