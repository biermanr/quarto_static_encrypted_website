#!/bin/sh
# Usage:
#   sh build.sh             # render + encrypt into website/encrypted_site
#   sh build.sh --preview   # ...then serve it at http://localhost:8000
set -eu

# 1. Quarto render the website/*.qmd files into website/unencrypted_site/*.html files
quarto render website/

# 2. StatiCrypt encrypt the website/unencrypted_site/*.html files into website/encrypted_site/*.html files
rm -rf website/encrypted_site

# NOTE! The demo password "BBQ" is written in plain text!
# This is ok as long as the repo stays private, but
# better to use a GitHub secret instead
npx --yes staticrypt@3.5.4 website/unencrypted_site/*.html \
  --directory website/encrypted_site \
  --password BBQ \
  --short \
  --config false

# 3. Optionally serve the encrypted site locally (WebCrypto needs localhost or https)
if [ "${1:-}" = "--preview" ]; then
  python3 -m http.server 8000 --bind 127.0.0.1 --directory website/encrypted_site
fi
