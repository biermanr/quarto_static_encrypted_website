#!/bin/sh
# Usage: sh build.sh
# Renders + encrypts into website/encrypted_site. Open
# website/encrypted_site/index.html in a browser to check the result.
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
