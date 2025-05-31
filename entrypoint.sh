#!/bin/bash

# Set fallback URL
FALLBACK_URL="https://github.com/xmrig/xmrig/releases/download/v6.22.2/xmrig-6.22.2-linux-static-x64.tar.gz"

# Try to get latest release URL
echo "Attempting to get latest XMRig release URL..."
LATEST_RELEASE_URL=$(wget -qO- https://api.github.com/repos/xmrig/xmrig/releases/latest | grep "browser_download_url.*linux-static-x64.tar.gz" | cut -d '"' -f 4)

# If we couldn't get the latest release URL, use the fallback
if [ -z "$LATEST_RELEASE_URL" ]; then
    echo "Failed to get latest release URL, using fallback URL"
    LATEST_RELEASE_URL="$FALLBACK_URL"
fi

echo "Downloading XMRig from: $LATEST_RELEASE_URL"

# Download the latest release
if ! wget -O xmrig.tar.gz "$LATEST_RELEASE_URL"; then
    echo "Failed to download from $LATEST_RELEASE_URL, trying fallback URL"
    if ! wget -O xmrig.tar.gz "$FALLBACK_URL"; then
        echo "Failed to download XMRig. Exiting."
        exit 1
    fi
fi

# Extract the tarball
echo "Extracting XMRig tarball..."
if ! tar -xzf xmrig.tar.gz --strip-components=1; then
    echo "Failed to extract with --strip-components=1, trying without it..."
    # Try extracting without strip-components
    if ! tar -xzf xmrig.tar.gz; then
        echo "Failed to extract XMRig tarball. Exiting."
        exit 1
    fi
    
    # Find the xmrig executable
    echo "Looking for xmrig executable..."
    XMRIG_PATH=$(find . -name xmrig -type f | head -n 1)
    
    if [ -z "$XMRIG_PATH" ]; then
        echo "ERROR: Could not find xmrig executable in the extracted files!"
        echo "Contents of the current directory:"
        ls -la
        exit 1
    fi
    
    echo "Found XMRig at: $XMRIG_PATH"
    
    # Move the xmrig executable and config.json to the current directory if they're in a subdirectory
    if [ "$XMRIG_PATH" != "./xmrig" ]; then
        echo "Moving XMRig to current directory..."
        XMRIG_DIR=$(dirname "$XMRIG_PATH")
        mv "$XMRIG_PATH" ./xmrig
        chmod +x ./xmrig
        
        # Also move config.json if it exists in the same directory
        if [ -f "$XMRIG_DIR/config.json" ]; then
            echo "Moving config.json to current directory..."
            mv "$XMRIG_DIR/config.json" ./config.json
        fi
    fi
fi

# Verify xmrig executable exists
if [ ! -f "./xmrig" ]; then
    echo "ERROR: xmrig executable not found after extraction!"
    echo "Contents of the current directory:"
    ls -la
    exit 1
fi

echo "XMRig executable found and ready"
chmod +x ./xmrig

# Clean up
echo "Cleaning up..."
rm -f xmrig.tar.gz
rm -rf $(find . -type d -name "xmrig*" | grep -v "^.$")

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
