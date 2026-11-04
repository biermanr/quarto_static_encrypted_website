#!/usr/bin/env bash
# Run as `sh scripts/build.sh`
set -euo pipefail

quarto render website
rm -rf encrypted_site # StatiCrypt never removes pages that no longer exist

# NOTE! The demo password "BBQ" is written in plain text!
# This is ok as long as the repo stays private, but
# better to use a GitHub secret instead
npx --yes staticrypt@3.5.4 website/unencrypted_site/*.html \
  --directory encrypted_site \
  --password BBQ \
  --short \
  --config false
