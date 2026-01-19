#!/bin/sh

# Exit on error
set -e

# 1. Install dependencies
apt-get update
apt-get install -y git curl unzip

# 2. Download and install Flutter SDK
FLUTTER_VERSION="3.22.1" # You can change this to your desired version
FLUTTER_CHANNEL="stable"
FLUTTER_DIR="/opt/flutter"

git clone -b $FLUTTER_CHANNEL https://github.com/flutter/flutter.git $FLUTTER_DIR
export PATH="$FLUTTER_DIR/bin:$PATH"

# 3. Pre-download Flutter assets
flutter precache

# 4. Run the original build command
flutter build web --release
