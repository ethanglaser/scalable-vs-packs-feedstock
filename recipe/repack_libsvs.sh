#!/bin/bash
set -euo pipefail
set -x

root="$SRC_DIR/libsvs"

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

# Copy CMake config files if they exist
if [ -d "$root/lib/cmake" ]; then
  mkdir -p "$PREFIX/lib/cmake"
  cp -a "$root/lib/cmake"/* "$PREFIX/lib/cmake/"
fi

# Copy headers if they exist
if [ -d "$root/include" ]; then
  mkdir -p "$PREFIX/include"
  cp -a "$root/include"/* "$PREFIX/include/"
fi

# Licenses
if [ -d "$root/info/licenses" ]; then
  mkdir -p "$PREFIX/libsvs/info"
  cp -a "$root/info/licenses" "$PREFIX/libsvs/info/"
fi

# Regenerate info
rm -rf "$PREFIX/info"