#!/bin/bash
# convert_to_webp.sh — bulk JPG → WebP conversion + reference rewrite
#
# Run this from the repo root. Requires cwebp (install via `brew install webp`).
#
# What it does:
#   1. Finds every .jpg/.jpeg under images/, gallery/, thumbs/
#   2. Encodes each one as .webp at quality 82 (visually transparent for
#      interior design photos; ~35% smaller files than JPG q90)
#   3. Rewrites .jpg/.jpeg references in site.json, projects.json,
#      index.html, and 404.html to point at the .webp version
#   4. Prints next-step git commands so you can review and commit
#
# Usage:
#   ./convert-to-webp.sh                # default quality 82
#   QUALITY=85 ./convert-to-webp.sh     # bump quality
#   DRY_RUN=1 ./convert-to-webp.sh      # show what would happen
#
# Originals: keep your JPG/RAW masters OUTSIDE the repo (e.g. ~/Photos/SlowDust/
# or Dropbox). After this script + git rm, the repo will only contain WebP.

set -e

QUALITY=${QUALITY:-82}
DRY_RUN=${DRY_RUN:-0}

# Locate cwebp
if ! command -v cwebp &> /dev/null; then
  echo "ERROR: cwebp not found." >&2
  echo "Install via: brew install webp" >&2
  exit 1
fi

ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT"

echo "Repo root: $ROOT"
echo "Quality:   $QUALITY"
echo "Dry run:   $DRY_RUN"
echo

# Step 1: convert
converted=0
skipped=0
for dir in images gallery thumbs; do
  [ -d "$dir" ] || continue
  while IFS= read -r -d '' jpg; do
    webp="${jpg%.*}.webp"
    if [ -f "$webp" ]; then
      skipped=$((skipped + 1))
      continue
    fi
    if [ "$DRY_RUN" = "1" ]; then
      echo "[dry] would convert: $jpg → $webp"
    else
      cwebp -q "$QUALITY" "$jpg" -o "$webp" -quiet
      echo "  converted: $jpg → $webp"
    fi
    converted=$((converted + 1))
  done < <(find "$dir" -type f \( -iname "*.jpg" -o -iname "*.jpeg" \) -print0)
done

echo
echo "Converted: $converted file(s)"
echo "Skipped (already had .webp): $skipped"

# Step 2: rewrite references in tracked text files
echo
echo "Rewriting references…"
for f in site.json projects.json index.html 404.html; do
  [ -f "$f" ] || continue
  if [ "$DRY_RUN" = "1" ]; then
    matches=$(grep -ciE '\.(jpg|jpeg)' "$f" || true)
    echo "[dry] would update $f ($matches matches)"
  else
    # Portable in-place sed (Mac + Linux): write to .tmp, then mv
    sed -E 's/\.(jpg|jpeg)/\.webp/gi' "$f" > "$f.tmp" && mv "$f.tmp" "$f"
    echo "  updated: $f"
  fi
done

# Step 3: print next steps
echo
echo "Done."
echo
echo "Next steps (review, then run manually):"
echo "  1. Visually verify a sample of WebP files look right:"
echo "       open images/slides/01.webp"
echo "  2. Test the site locally with the new references."
echo "  3. Remove JPG files from git:"
echo "       find images gallery thumbs -type f \\( -iname '*.jpg' -o -iname '*.jpeg' \\) -delete"
echo "       git add -A"
echo "       git commit -m 'images: convert JPG to WebP, drop originals from repo'"
echo "       git push"
