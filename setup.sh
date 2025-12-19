#!/usr/bin/env bash

set -e

# -------- Replace prompts --------

# Directory this script is in
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

SRC_PROMPTS="$SCRIPT_DIR/prompts"
DEST_PROMPTS="$HOME/.config/quickshell/ii/defaults/ai/prompts"

# Ensure source exists
if [ ! -d "$SRC_PROMPTS" ]; then
  echo "Bad! ----Source prompts folder not found: $SRC_PROMPTS ----"
  exit 1
fi

echo "- Removing existing prompts..."
rm -rf "$DEST_PROMPTS"

echo "- Copying new prompts..."
mkdir -p "$(dirname "$DEST_PROMPTS")"
cp -r "$SRC_PROMPTS" "$DEST_PROMPTS"

echo "Good! ---- Prompts replaced ----"

# -------- Replace Ai.qml service --------

SRC_AI="$SCRIPT_DIR/model/Ai.qml"
DEST_AI="$HOME/.config/quickshell/ii/services/Ai.qml"

# Ensure source exists
if [ ! -f "$SRC_AI" ]; then
  echo "Bad! ---- Source Ai.qml not found: $SRC_AI ----"
  exit 1
fi

echo "- Replacing Ai.qml service..."
mkdir -p "$(dirname "$DEST_AI")"
cp -f "$SRC_AI" "$DEST_AI"

echo "Good! ---- Ai.qml service replaced ----"

qs reload
