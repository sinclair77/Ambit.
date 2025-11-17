#!/usr/bin/env bash
# Move any incorrectly placed Swift files from Ambit.xcodeproj to Ambit/Views
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
XCODEPROJ="$ROOT/Ambit.xcodeproj"
VIEWS_DIR="$ROOT/Ambit/Views"
WORKSPACE_FILE="$XCODEPROJ/project.xcworkspace/contents.xcworkspacedata"

echo "Repo root: $ROOT"
mkdir -p "$VIEWS_DIR"

moved=false
while IFS= read -r -d $'\0' file; do
  name="$(basename "$file")"
  dest="$VIEWS_DIR/$name"
  if [ -e "$dest" ]; then
    echo "Destination $dest already exists. Changing name to avoid overwrite: $dest.orig"
    dest="$dest.orig"
  fi
  echo "Moving $file -> $dest"
  mv "$file" "$dest"
  moved=true
done < <(find "$XCODEPROJ" -maxdepth 1 -type f -name "*.swift" -print0)

if [ "$moved" = true ]; then
  echo "Cleaning workspace file entries for removed/sourced files..."
  if [ -f "$WORKSPACE_FILE" ]; then
    # Remove group references that match top-level swift files
    awk '!/group:[^>]*.swift>/' "$WORKSPACE_FILE" > "$WORKSPACE_FILE.tmp" && mv "$WORKSPACE_FILE.tmp" "$WORKSPACE_FILE"
  fi
fi

echo "Done. If Xcode was open, restart it or open the file again to refresh the project view."
