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

# Download CUDA plugin for NVIDIA GPU support
echo "Checking for NVIDIA GPUs..."
if [ -c /dev/nvidia0 ] || [ -d /proc/driver/nvidia ]; then
    echo "NVIDIA GPU detected, downloading xmrig-cuda plugin..."
    
    # Get latest CUDA plugin release URL
    CUDA_RELEASE_URL=$(wget -qO- https://api.github.com/repos/xmrig/xmrig-cuda/releases/latest | grep "browser_download_url.*cuda.*tar.gz" | grep -v "sha256" | cut -d '"' -f 4 | grep "12.4" | head -n 1)
    
    if [ -z "$CUDA_RELEASE_URL" ]; then
        echo "Failed to get latest CUDA plugin URL, using fallback URL"
        CUDA_RELEASE_URL="https://github.com/xmrig/xmrig-cuda/releases/download/v6.22.0/xmrig-cuda-6.22.0-cuda12.4-win64.zip"
    fi
    
    echo "Downloading CUDA plugin from: $CUDA_RELEASE_URL"
    
    # Download the CUDA plugin
    if wget -O cuda-plugin.tar.gz "$CUDA_RELEASE_URL"; then
        echo "Successfully downloaded CUDA plugin"
        
        # Extract the plugin
        if [[ "$CUDA_RELEASE_URL" == *".zip" ]]; then
            apt-get update && apt-get install -y unzip
            unzip -o cuda-plugin.tar.gz
        else
            tar -xzf cuda-plugin.tar.gz
        fi
        
        # Find the plugin file
        CUDA_PLUGIN=$(find . -name "libxmrig-cuda.so" -o -name "xmrig-cuda.dll" | head -n 1)
        
        if [ -n "$CUDA_PLUGIN" ]; then
            echo "Found CUDA plugin: $CUDA_PLUGIN"
            # Move the plugin to the current directory if it's in a subdirectory
            if [ "$(dirname "$CUDA_PLUGIN")" != "." ]; then
                mv "$CUDA_PLUGIN" ./
            fi
            chmod +x ./$(basename "$CUDA_PLUGIN")
            
            # Update config.json to enable CUDA if it exists
            if [ -f "./config.json" ]; then
                echo "Updating config.json to enable CUDA support"
                sed -i 's/"cuda": {[^}]*}/"cuda": {\n      "enabled": true,\n      "loader": null,\n      "nvml": true,\n      "devices": []\n    }/g' ./config.json
            fi
        else
            echo "CUDA plugin not found in the downloaded package"
        fi
        
        # Clean up
        rm -f cuda-plugin.tar.gz
    else
        echo "Failed to download CUDA plugin"
    fi
else
    echo "No NVIDIA GPU detected, skipping CUDA plugin download"
fi

# Clean up XMRig download files
echo "Cleaning up XMRig download files..."
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
