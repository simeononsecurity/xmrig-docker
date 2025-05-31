FROM ubuntu:22.04

# Install required packages
RUN apt-get update && \
    apt-get install -y wget tar msr-tools \
    ocl-icd-libopencl1 opencl-headers clinfo \
    libcurl4 libssl3 libhwloc15 \
    nvidia-opencl-dev libnvidia-compute && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create directory for AMD GPU support
RUN mkdir -p /etc/OpenCL/vendors && \
    echo "libamdocl64.so" > /etc/OpenCL/vendors/amdocl64.icd

# Create app directory
WORKDIR /app

# Download and run randomx_boost script at startup
RUN wget https://raw.githubusercontent.com/xmrig/xmrig/dev/scripts/randomx_boost.sh -O /app/randomx_boost.sh && \
    chmod +x /app/randomx_boost.sh

# Create a script to download the latest XMRig release
RUN echo '#!/bin/bash \n\
# Get latest release URL \n\
LATEST_RELEASE_URL=$(wget -qO- https://api.github.com/repos/xmrig/xmrig/releases/latest | grep "browser_download_url.*linux-static-x64.tar.gz" | cut -d : -f 2,3 | tr -d \") \n\
\n\
# If we couldn'"'"'t get the latest release URL, use a fallback \n\
if [ -z "$LATEST_RELEASE_URL" ]; then \n\
    LATEST_RELEASE_URL="https://github.com/xmrig/xmrig/releases/download/v6.22.2/xmrig-6.22.2-linux-static-x64.tar.gz" \n\
fi \n\
\n\
# Download the latest release \n\
wget -O xmrig.tar.gz "$LATEST_RELEASE_URL" \n\
\n\
# Extract the tarball \n\
tar -xzf xmrig.tar.gz --strip-components=1 \n\
\n\
# Clean up \n\
rm xmrig.tar.gz \n\
\n\
# Run randomx_boost.sh script \n\
/app/randomx_boost.sh \n\
\n\
# Check if a custom config.json is mounted \n\
if [ -f "/config/config.json" ]; then \n\
    echo "Using mounted config.json" \n\
    cp /config/config.json /app/config.json \n\
fi \n\
\n\
# Run XMRig with any additional arguments passed to the container \n\
exec ./xmrig "$@" \n\
' > /app/entrypoint.sh && \
    chmod +x /app/entrypoint.sh

# Set the entrypoint script
ENTRYPOINT ["/app/entrypoint.sh"]

# Create a volume for the config
VOLUME ["/config"]
