# hakoCLAW icons

`hakoCLAW.svg` is the source. Run `./build-icons.sh` to produce:
- `hakoCLAW.iconset/` — 16/32/64/128/256/512 px PNGs (macOS iconset format)
- `hakoCLAW.icns` — macOS app icon (built by `iconutil`)
- `hakoCLAW.png` — 512 px PNG (Linux `.desktop` entry)
- `hakoCLAW.ico` — Windows multi-res icon

## Required tools

```sh
# macOS:
brew install librsvg imagemagick

# Linux:
sudo apt install librsvg2-bin imagemagick
# or
sudo dnf install librsvg2-tools ImageMagick
```

`iconutil` is built into macOS. On Linux you can skip `.icns` (no native use case).

## Design

Box outline (matches hako's `箱`/box motif) + three diagonal red claw marks. Drop a different SVG in here and rerun the script if you want to change it.
