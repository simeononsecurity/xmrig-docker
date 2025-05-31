FROM ubuntu:22.04

# Add metadata labels
LABEL org.opencontainers.image.title="XMRig Docker"
LABEL org.opencontainers.image.description="Docker container for XMRig cryptocurrency miner with CPU, NVIDIA and AMD GPU support"
LABEL org.opencontainers.image.url="https://github.com/simeononsecurity/xmrig-docker"
LABEL org.opencontainers.image.source="https://github.com/simeononsecurity/xmrig-docker"
LABEL org.opencontainers.image.version="latest"
LABEL org.opencontainers.image.licenses="Apache-2.0"
LABEL org.opencontainers.image.vendor="SimeonOnSecurity"
LABEL org.opencontainers.image.authors="SimeonOnSecurity"
LABEL maintainer="SimeonOnSecurity"

# GitHub Container Registry labels
LABEL com.github.repo="simeononsecurity/xmrig-docker"
LABEL org.opencontainers.image.documentation="https://github.com/simeononsecurity/xmrig-docker/blob/main/README.md"

# Docker Hub labels
LABEL com.docker.hub.repository="simeononsecurity/xmrig"

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

# Copy the randomx_boost script
COPY randomx_boost.sh /app/randomx_boost.sh
RUN chmod +x /app/randomx_boost.sh

# Copy the entrypoint script
COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

# Set the entrypoint script
ENTRYPOINT ["/app/entrypoint.sh"]

# Create a volume for the config
VOLUME ["/config"]
