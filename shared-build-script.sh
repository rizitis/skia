#!/bin/bash

# This script builds shared skia libs for Slackware64 current 07/02/2025...
# unsupported arguments like skia_use_libjpeg_turbo, skia_use_libwebp, and skia_use_libpng included you never know... but you can remove them ;)
# Define Skia and SkiaSharp repositories
SKIA_REPO="https://skia.googlesource.com/skia.git"
SKIA_DIR="skia"
BRANCH="main"

# Define build output directory
BUILD_DIR="out/Portable"

# Clone Skia if not already cloned
if [ ! -d "$SKIA_DIR" ]; then
    echo "Cloning Skia repository..."
    git clone $SKIA_REPO $SKIA_DIR
else
    echo "Skia repository already cloned."
fi

# Navigate to the Skia directory
cd $SKIA_DIR

# Checkout to the latest or specific branch
echo "Checking out the branch: $BRANCH"
git checkout $BRANCH
git pull origin $BRANCH

# Initialize Skia dependencies
echo "Syncing Skia dependencies..."
python3 tools/git-sync-deps

# Clean any previous build artifacts
echo "Cleaning previous builds..."
rm -rf $BUILD_DIR || true
mkdir -p $BUILD_DIR

echo "Generating build files with GN for shared libraries..."
bin/gn gen $BUILD_DIR --args="
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
is_component_build=true  # Build shared libraries (.so files)
extra_cflags=[\"-mavx\", \"-mfma\", \"-msse4.2\"]  # Enable AVX and SSE for performance
"

echo "Building Skia shared libraries..."
ninja -C $BUILD_DIR -j$(nproc)


echo "Skia shared libraries built successfully!"
