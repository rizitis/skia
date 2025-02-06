#!/bin/bash
# This is statical build for Slackware current 07/02/2025
set -e  # Exit on any error
set -x  # Print commands for debugging

# Define build directory
BUILD_DIR="skia"
OUT_DIR="out/FullBuild"

# Number of parallel jobs for faster builds
JOBS=$(nproc)

# Clone Skia if not already present
if [ ! -d "$BUILD_DIR" ]; then
    git clone --recursive https://github.com/google/skia.git
fi

cd skia

# Sync dependencies
python3 tools/git-sync-deps

# Create output directory
mkdir -p $OUT_DIR

bin/gn gen $OUT_DIR --args="
is_official_build=true
is_debug=false
skia_use_gl=true
skia_use_vulkan=true
skia_use_metal=false
skia_use_dawn=true
skia_use_libwebp=true
skia_use_libjpeg_turbo=true
skia_use_libpng=true
skia_use_freetype=true
skia_use_zlib=true
skia_enable_gpu=true
skia_enable_skottie=true
skia_enable_svg=true
skia_enable_pdf=true
skia_enable_skshaper=true
skia_use_expat=true
skia_enable_graphite=true  # Required for Dawn
is_component_build=false  # Disables shared libraries (forces static build)
skia_enable_ccpr=false  # Avoids some dynamic dependencies
extra_cflags=[\"-mavx\", \"-mfma\", \"-msse4.2\"]  # Enable AVX and SSE
extra_ldflags=[\"-static-libstdc++\", \"-static-libgcc\"]
"

# Build all Skia libraries using Ninja
ninja -C $OUT_DIR -j$JOBS
# Display success message :p
echo "Skia full build completed successfully! Libraries are in $OUT_DIR"
