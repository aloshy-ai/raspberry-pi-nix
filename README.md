# NixOS Raspberry Pi Image Builder

A Docker-based build environment for creating custom NixOS images for Raspberry Pi (aarch64).

This project uses the NixOS Raspberry Pi configuration from [nix-community/raspberry-pi-nix](https://github.com/nix-community/raspberry-pi-nix).

## Overview

This project provides:
- Docker-based build environment for NixOS Raspberry Pi images
- VS Code integration for easy builds
- Integration with Raspberry Pi Imager

## Prerequisites

- Docker installed
- Visual Studio Code
- [Raspberry Pi Imager](https://www.raspberrypi.com/software/) for flashing

## Building NixOS Image

### Using VS Code (Recommended)

1. Open project in VS Code
2. Press `F5` to start the build
   - See the live logs in the  terminal
3. Wait for the build to complete
4. Find the built image in the `artifacts` directory

### Using Docker Directly

```bash
# Build the Docker image
docker build -t nixos-rpi-builder .

# Run the build
docker run --rm \
  --name nixos-rpi-builder-container \
  -v ${PWD}/artifacts:/build/artifacts \
  nixos-rpi-builder
```

## Project Structure

```
.
├── .vscode/
│   ├── launch.json        # VS Code launch configuration
│   └── tasks.json         # VS Code build tasks
├── artifacts/            # Build output directory (created during build)
├── .github/             # GitHub-related configurations
└── Dockerfile           # Build environment definition
```

## Using the Built Image

1. After a successful build, find the image file in the `artifacts` directory
2. Use Raspberry Pi Imager to flash the image to an SD card or USB drive

## Troubleshooting

Monitor build progress:
```bash
docker logs -f nixos-rpi-builder-container
```

Clean build environment:
```bash
docker rm -f nixos-rpi-builder-container
docker rmi nixos-rpi-builder
rm -rf artifacts/*
```

## Contributing

Feel free to open issues or submit pull requests for:
- Build configuration improvements
- NixOS configuration options
- Documentation updates
- Bug fixes

## Credits

This project builds upon:
- [nix-community/raspberry-pi-nix](https://github.com/nix-community/raspberry-pi-nix) - NixOS modules for Raspberry Pi configuration
