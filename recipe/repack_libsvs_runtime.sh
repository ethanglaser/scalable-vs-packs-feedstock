#!/bin/bash
set -euo pipefail
set -x

root="$SRC_DIR/libsvs-runtime"

# Convert embedded .conda(s) -> .tar.bz2 and extract
for f in "$root"/*.conda; do
  [ -e "$f" ] || continue
  cph transmute "$f" .tar.bz2
  tbz="${f%.conda}.tar.bz2"
  tar xjf "$tbz" -C "$root"
  rm -f "$f" "$tbz"
done

# Copy library files to $PREFIX/lib
if [ -d "$root/lib" ]; then
  mkdir -p "$PREFIX/lib"
  cp -a "$root/lib"/*.so* "$PREFIX/lib/" 2>/dev/null || true
  cp -a "$root/lib"/*.a "$PREFIX/lib/" 2>/dev/null || true
fi

# Copy headers if they exist
if [ -d "$root/include" ]; then
  mkdir -p "$PREFIX/include"
  cp -a "$root/include"/* "$PREFIX/include/"
fi

# Licenses
if [ -d "$root/info/licenses" ]; then
  mkdir -p "$PREFIX/libsvs-runtime/info"
  cp -a "$root/info/licenses" "$PREFIX/libsvs-runtime/info/"
fi

# Regenerate info
rm -rf "$PREFIX/info"