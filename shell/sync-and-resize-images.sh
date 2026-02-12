#!/bin/bash

# Exit on any error
set -e

# Get the directory where this script lives
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo "Syncing images from source to working directory..."

# Define paths using realpath-style resolution (create if needed first)
WEBSITE_IMAGES_ORIGIN="/Users/bensmith/Documents/Tiika/Website Images/"

# Create directories FIRST, then resolve paths
mkdir -p "$SCRIPT_DIR/../everydays"
mkdir -p "$SCRIPT_DIR/../everydays_small"
mkdir -p "$SCRIPT_DIR/../../tiika/everydays"
mkdir -p "$SCRIPT_DIR/../../tiika/everydays_small"
mkdir -p "$SCRIPT_DIR/../images"
mkdir -p "$SCRIPT_DIR/../../tiika/images"

# NOW resolve to absolute paths (with trailing slashes)
EVERYDAYS_PATH="$(cd "$SCRIPT_DIR/../everydays" && pwd)/"
EVERYDAYS_SMALL_PATH="$(cd "$SCRIPT_DIR/../everydays_small" && pwd)/"
EVERYDAYS_TIIKA_PATH="$(cd "$SCRIPT_DIR/../../tiika/everydays" && pwd)/"
EVERYDAYS_SMALL_TIIKA_PATH="$(cd "$SCRIPT_DIR/../../tiika/everydays_small" && pwd)/"
ARTICLE_IMAGES_ORIGIN="$(cd "$SCRIPT_DIR/../images" && pwd)/"
ARTICLE_IMAGES_DEST="$(cd "$SCRIPT_DIR/../../tiika/images" && pwd)/"

# Sync full-size everydays
rsync -a --ignore-existing \
  --include='*.jpg' \
  --exclude='*' \
  "$WEBSITE_IMAGES_ORIGIN" \
  "$EVERYDAYS_PATH"

echo "Resizing new images..."

# Resize only new images
resized_count=0
for img in "$EVERYDAYS_PATH"*.jpg; do
    filename=$(basename "$img")
    target="$EVERYDAYS_SMALL_PATH$filename"
    
    if [ ! -f "$target" ]; then
        echo "  Resizing: $filename"
        sips -Z 300 "$img" --out "$target" &>/dev/null
        ((resized_count++))
    fi
done

echo "Resized $resized_count images"

# Sync to output directories
echo "Syncing to output directories..."

rsync -a --ignore-existing \
  --include='*.jpg' \
  --exclude='*' \
  "$EVERYDAYS_PATH" \
  "$EVERYDAYS_TIIKA_PATH"

rsync -a --ignore-existing \
  --include='*.jpg' \
  --exclude='*' \
  "$EVERYDAYS_SMALL_PATH" \
  "$EVERYDAYS_SMALL_TIIKA_PATH"

rsync -a --ignore-existing \
  --include='*.jpg' \
  --include='*.svg' \
  --exclude='*' \
  "$ARTICLE_IMAGES_ORIGIN" \
  "$ARTICLE_IMAGES_DEST"

echo "Image sync and resize complete"