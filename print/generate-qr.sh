#!/bin/sh
# Generates a QR code for the ordination-sign booking link, using the
# `location` query param to distinguish signs if more are added later
# (e.g. a second location or a different room). Requires `qrencode`
# (brew install qrencode) and `rsvg-convert` (brew install librsvg).
#
# Usage: print/generate-qr.sh [location-number]
set -eu

cd "$(dirname "$0")"

LOCATION="${1:-1}"
URL="https://frauenheilkunde-nk.at/qr?location=$LOCATION"
OUT="ordination-qr-location-$LOCATION"

qrencode -o "$OUT.png" -s 20 -m 2 -l H "$URL"
qrencode -t SVG -o "$OUT.svg" -m 2 -l H "$URL"
rsvg-convert -f pdf -o "$OUT.pdf" "$OUT.svg"

echo "Generated $OUT.png, $OUT.svg and $OUT.pdf for $URL"
