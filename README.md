# XMRig Docker Container

This Docker container automatically downloads and runs the latest version of [XMRig](https://github.com/xmrig/xmrig), a high-performance RandomX, KawPow, CryptoNight, AstroBWT and GhostRider CPU/GPU miner.

Repository: [https://github.com/simeononsecurity/xmrig-docker](https://github.com/simeononsecurity/xmrig-docker)

_________
[![Sponsor](https://img.shields.io/badge/Sponsor-Click%20Here-ff69b4)](https://github.com/sponsors/simeononsecurity) [![DockerHub](https://img.shields.io/badge/DockerHub-View%20Image-blue?logo=docker)](https://hub.docker.com/r/simeononsecurity/xmrig)

## Features

- Automatically downloads the latest XMRig release
- Runs the RandomX boost script at startup for optimal performance
- Allows custom configuration via mounted config.json
- Supports passing command-line arguments directly to XMRig

## Prerequisites

- Docker installed on your system
- MSR modules available on the host (for RandomX optimization)

## Usage

### Pulling the Image

You can pull the image from either Docker Hub or GitHub Container Registry:

#### Docker Hub
```bash
docker pull simeononsecurity/xmrig:latest
```

#### GitHub Container Registry
```bash
docker pull ghcr.io/simeononsecurity/xmrig:latest
```

### Basic Usage

```bash
docker run --privileged simeononsecurity/xmrig:latest
```

The `--privileged` flag is required to allow the container to run the RandomX boost script, which needs access to MSR (Model-Specific Registers).

### Using a Custom Configuration

You can mount your own `config.json` file to override the default configuration:

```bash
docker run --privileged -v /path/to/your/config.json:/config/config.json simeononsecurity/xmrig:latest
```

### Passing Command-Line Arguments

You can pass arguments directly to XMRig:

```bash
docker run --privileged simeononsecurity/xmrig:latest -o pool.example.com:3333 -u YOUR_WALLET_ADDRESS -p x -k
```

#### Using Docker Compose

The included `docker-compose.yml` file is pre-configured for both NVIDIA and AMD GPU support. Simply uncomment the relevant sections and run:

```bash
docker-compose up -d
```

## Building the Image

```bash
docker build -t xmrig .
```

## Security Considerations

- Running containers with the `--privileged` flag grants extensive permissions to the container, which could be a security risk. Only use this container in trusted environments.
- Always verify the source of Docker images before running them, especially for cryptocurrency mining software.

## License

This Dockerfile and associated scripts are provided under the Apache License 2.0. XMRig itself is subject to its own licensing terms.

<a href="https://simeononsecurity.com" target="_blank" rel="noopener noreferrer">
  <h2>Explore the World of Cybersecurity</h2>
</a>
<a href="https://simeononsecurity.com" target="_blank" rel="noopener noreferrer">
  <img src="https://simeononsecurity.com/img/banner.png" alt="SimeonOnSecurity Logo" width="300" height="300">
</a>

### **Links:**
- #### [github.com/simeononsecurity](https://github.com/simeononsecurity)
- #### [simeononsecurity.com](https://simeononsecurity.com)


