#!/usr/bin/env bash
# Build hakoCLAW.icns / .ico / .png from hakoCLAW.svg.
# Requires: rsvg-convert (or ImageMagick `magick`/`convert`), iconutil (macOS), `magick` for .ico.
set -eu

cd "$(dirname "$0")"

SRC=hakoCLAW.svg
NAME=hakoCLAW

if ! [ -f "$SRC" ]; then echo "missing $SRC" >&2; exit 1; fi

# pick a rasterizer
if command -v rsvg-convert >/dev/null 2>&1; then
	RAST="rsvg-convert"
elif command -v magick >/dev/null 2>&1; then
	RAST="magick"
elif command -v convert >/dev/null 2>&1; then
	RAST="convert"
else
	echo "need rsvg-convert or imagemagick (brew install librsvg | imagemagick)" >&2
	exit 1
fi

render() {
	# render <size> <output.png>
	local s=$1 out=$2
	case "$RAST" in
		rsvg-convert) rsvg-convert -w "$s" -h "$s" "$SRC" -o "$out" ;;
		magick)       magick -background none -density 384 "$SRC" -resize "${s}x${s}" "$out" ;;
		convert)      convert -background none -density 384 "$SRC" -resize "${s}x${s}" "$out" ;;
	esac
}

# ---- iconset (macOS) ----
ICONSET="${NAME}.iconset"
rm -rf "$ICONSET"
mkdir -p "$ICONSET"
for s in 16 32 64 128 256 512; do
	render "$s"           "$ICONSET/icon_${s}x${s}.png"
	d=$((s * 2))
	render "$d"           "$ICONSET/icon_${s}x${s}@2x.png"
done

# ---- icns (macOS) ----
if command -v iconutil >/dev/null 2>&1; then
	iconutil -c icns -o "${NAME}.icns" "$ICONSET"
	echo "wrote ${NAME}.icns"
else
	echo "iconutil not found — skipping .icns"
fi

# ---- 512 PNG (linux desktop entry) ----
render 512 "${NAME}.png"
echo "wrote ${NAME}.png"

# ---- ico (windows) ----
if command -v magick >/dev/null 2>&1; then
	magick "$ICONSET/icon_16x16.png" "$ICONSET/icon_32x32.png" "$ICONSET/icon_64x64.png" \
		"$ICONSET/icon_128x128.png" "$ICONSET/icon_256x256.png" \
		"${NAME}.ico"
	echo "wrote ${NAME}.ico"
elif command -v convert >/dev/null 2>&1; then
	convert "$ICONSET/icon_16x16.png" "$ICONSET/icon_32x32.png" "$ICONSET/icon_64x64.png" \
		"$ICONSET/icon_128x128.png" "$ICONSET/icon_256x256.png" \
		"${NAME}.ico"
	echo "wrote ${NAME}.ico"
else
	echo "imagemagick not found — skipping .ico"
fi

echo "done."
