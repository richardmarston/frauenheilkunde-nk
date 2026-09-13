#!/bin/sh
# Serve the site locally for previewing, e.g. http://localhost:8420
cd "$(dirname "$0")/.."
python3 -m http.server 8420
