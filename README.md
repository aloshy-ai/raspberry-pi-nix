# NixOS Raspberry Pi Image Builder

A GitHub Actions workflow to build custom NixOS images for Raspberry Pi (aarch64), using a self-hosted runner optimized for ARM64 architecture.

This project combines:

- NixOS Raspberry Pi configuration from [nix-community/raspberry-pi-nix](https://github.com/nix-community/raspberry-pi-nix)
- Self-hosted runner implementation inspired by [wbond/pi-github-runner](https://github.com/wbond/pi-github-runner)

## Overview

This project provides:

- A local GitHub Actions runner for ARM64 builds
- Automated NixOS image building for Raspberry Pi
- Docker-based build environment
- Integration with Raspberry Pi Imager

## Prerequisites

- Raspberry Pi 4 (or newer) with Docker installed
- Visual Studio Code
- Git repository connected to GitHub
- [Raspberry Pi Imager](https://www.raspberrypi.com/software/) for flashing

## Setup Build Environment

1. Copy environment template:

```bash
cp .env.example .env
```

2. Configure environment:
   - Get GitHub token from `https://github.com/settings/tokens`
   - Required token scopes: `repo`, `workflow`
   - Edit `.env`:

```env
GITHUB_ACCESS_TOKEN=your_github_token
RUNNER_NAME=your-runner-name
```

## Starting the Build Runner

### Using VS Code (Recommended)

1. Open project in VS Code
2. Press `F5` to start the runner

### Using Terminal

```bash
# Load environment and start runner
source .env && bash .github/actions/runner/start
```

## Building NixOS Image

1. The runner will automatically process workflows when triggered
2. Build artifacts will be available in GitHub Actions
3. Download the generated image from the workflow artifacts
4. Use Raspberry Pi Imager to flash the image to SD card/USB

## Project Structure

```
.
├── .github/actions/runner/   # ARM64 runner configuration
│   ├── Dockerfile           # Runner container definition
│   ├── build               # Image build script
│   ├── start              # Runner start script
│   ├── bootstrap          # Runner setup script
│   └── entrypoint        # Container entry point
├── .vscode/
│   └── launch.json        # VS Code launch configuration
├── .env.example           # Environment template
└── .env                   # Environment configuration (git-ignored)
```

## Troubleshooting

Monitor build progress:

```bash
docker logs -f {repository-name}-runner
```

Restart build runner:

```bash
docker restart {repository-name}-runner
```

## Runner Management

Stop runner:

```bash
docker stop {repository-name}-runner
```

Remove runner:

```bash
docker rm -f {repository-name}-runner
```

Rebuild runner container:

```bash
.github/actions/runner/build --no-cache
```

## Security Notes

- Never commit `.env` file
- Regularly rotate GitHub token
- Keep build environment updated

## Contributing

Feel free to open issues or submit pull requests for:

- Build configuration improvements
- NixOS configuration options
- Documentation updates
- Bug fixes

## Credits

This project builds upon:

- [nix-community/raspberry-pi-nix](https://github.com/nix-community/raspberry-pi-nix) - NixOS modules for Raspberry Pi configuration
- [wbond/pi-github-runner](https://github.com/wbond/pi-github-runner) - GitHub Actions runner implementation for Raspberry Pi

## License

[Add your license information here]
