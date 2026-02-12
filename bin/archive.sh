#!/usr/bin/env bash

set -euo pipefail
IFS=$'\n\t'

# Check that at least one argument is provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 <file_or_directory> [...]"
    exit 1
fi

# Collect list of files/directories
files=("$@")
for i in "${!files[@]}"; do
  files[$i]=$(realpath --relative-to="$PWD" "${files[$i]}")
done

# === Step 1: Choose archive type ===
default_type="zip"
printf "Select archive type [zip, 7z, rar, tar] (default: %s): " "$default_type"
read -r archive_type
archive_type="${archive_type:-$default_type}"

# === Step 2: Password option (if supported) ===
use_password="no"
case "$archive_type" in
    zip|7z|rar)
        printf "Use password? [y/N]: "
        read -r use_password
        case "${use_password,,}" in
            y|yes) use_password="yes" ;;
            *)     use_password="no" ;;
        esac
        ;;
    tar)
        # Choose compression for tar
        echo "Select tar compression:"
        echo "1) gzip"
        echo "2) bzip2"
        echo "3) xz"
        echo "4) none"
        printf "Choice (default: gzip): "
        read -r tar_choice
        tar_choice="${tar_choice:-1}"
        case "$tar_choice" in
            1) tar_compression_flag="z" ; tar_compression_ext="gz" ;;
            2) tar_compression_flag="j" ; tar_compression_ext="bz2" ;;
            3) tar_compression_flag="J" ; tar_compression_ext="xz" ;;
            4) tar_compression_flag="" ; tar_compression_ext="" ;;
            *) echo "Invalid choice, using gzip"; tar_compression_flag="z" ; tar_compression_ext="gz" ;;
        esac
        ;;
    *)
        echo "Unsupported type, using default zip"
        archive_type="zip"
        ;;
esac

# === Step 3: Archive name ===
default_name=$(basename "${files[0]}")
printf "Archive name (default: %s): " "$default_name"
read -r archive_name
archive_name="${archive_name:-$default_name}"

# Append proper extension
case "$archive_type" in
    zip) ext="zip" ;;
    7z) ext="7z" ;;
    rar) ext="rar" ;;
    tar)
        ext="tar"
        [[ -n "$tar_compression_flag" ]] && ext+=${tar_compression_ext:+".$tar_compression_ext"}
        ;;
esac

archive_name="$archive_name.$ext"

# === Step 4: Build and run archive command ===
case "$archive_type" in
    zip)
        cmd=("zip" "-r")
        [[ "$use_password" == "yes" ]] && cmd+=("-e")
        cmd+=("$archive_name" "${files[@]}")
        ;;
    7z)
        cmd=("7z" "a")
        [[ "$use_password" == "yes" ]] && cmd+=("-p")
        cmd+=("$archive_name" "${files[@]}")
        ;;
    rar)
        cmd=("rar" "a")
        [[ "$use_password" == "yes" ]] && cmd+=("-p")
        cmd+=("$archive_name" "${files[@]}")
        ;;
    tar)
        cmd=("tar")
        cmd+=("-c${tar_compression_flag}")
        cmd+=("-f" "$archive_name" "${files[@]}")
        ;;
esac

echo "Running: ${cmd[@]}"
"${cmd[@]}"
echo "Archive created: $archive_name"


