#!/bin/bash

# Check if archive file is provided
if [ "$#" -eq 0 ]; then
    echo "Usage: $0 <archive_file>"
    exit 1
fi

ARCHIVE="$1"
# Ask for output directory
printf "Enter output directory (default: '.'): "
read -r OUTPUT_DIR
if [ -z "$OUTPUT_DIR" ]; then
    OUTPUT_DIR="."
fi

# Detect archive type
EXT="${ARCHIVE##*.}"
case "$ARCHIVE" in
    *.zip)     CMD="unzip \"$ARCHIVE\" -d \"$OUTPUT_DIR\"" ;;
    *.7z)      CMD="7z x \"$ARCHIVE\" -o\"$OUTPUT_DIR\"" ;;
    *.rar)     CMD="unrar x \"$ARCHIVE\" \"$OUTPUT_DIR\"" ;;
    *.tar.gz)  CMD="tar -xzf \"$ARCHIVE\" -C \"$OUTPUT_DIR\"" ;;
    *.tar.bz2) CMD="tar -xjf \"$ARCHIVE\" -C \"$OUTPUT_DIR\"" ;;
    *.tar.xz)  CMD="tar -xJf \"$ARCHIVE\" -C \"$OUTPUT_DIR\"" ;;
    *.tar)     CMD="tar -xf \"$ARCHIVE\" -C \"$OUTPUT_DIR\"" ;;
    *)
        echo "Unsupported archive type: $ARCHIVE"
        exit 1
        ;;
esac

# Create the directory
mkdir "${OUTPUT_DIR}" &> /dev/null

echo "Running: ${CMD}"
# Execute
eval "$CMD"
