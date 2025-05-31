#!/bin/bash

# Get latest release URL
LATEST_RELEASE_URL=$(wget -qO- https://api.github.com/repos/xmrig/xmrig/releases/latest | grep "browser_download_url.*linux-static-x64.tar.gz" | cut -d : -f 2,3 | tr -d \")

# If we couldn't get the latest release URL, use a fallback
if [ -z "$LATEST_RELEASE_URL" ]; then
    LATEST_RELEASE_URL="https://github.com/xmrig/xmrig/releases/download/v6.22.2/xmrig-6.22.2-linux-static-x64.tar.gz"
fi

# Download the latest release
wget -O xmrig.tar.gz "$LATEST_RELEASE_URL"

# Extract the tarball
tar -xzf xmrig.tar.gz --strip-components=1

# Clean up
rm xmrig.tar.gz

# Try to download the latest randomx_boost.sh script
echo "Attempting to download the latest randomx_boost.sh script..."
if wget -q https://raw.githubusercontent.com/xmrig/xmrig/dev/scripts/randomx_boost.sh -O /app/randomx_boost_latest.sh; then
    echo "Successfully downloaded the latest randomx_boost.sh script"
    chmod +x /app/randomx_boost_latest.sh
    /app/randomx_boost_latest.sh
else
    echo "Failed to download the latest randomx_boost.sh script, using the bundled version"
    /app/randomx_boost.sh
fi

# Check if a custom config.json is mounted
if [ -f "/config/config.json" ]; then
    echo "Using mounted config.json"
    cp /config/config.json /app/config.json
fi

# Run XMRig with any additional arguments passed to the container
exec ./xmrig "$@"
