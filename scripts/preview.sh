#!/usr/bin/env bash
# Build the encrypted site exactly as CI does, then serve it at http://localhost:8000
# Run as `sh scripts/preview.sh`
set -euo pipefail

scripts/build.sh
python3 -m http.server 8000 --bind 127.0.0.1 --directory encrypted_site
