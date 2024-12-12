FROM nixos/nix:latest

# Enable nix flakes and cross-compilation
RUN echo "experimental-features = nix-command flakes" >> /etc/nix/nix.conf && \
    echo "extra-platforms = aarch64-linux arm-linux" >> /etc/nix/nix.conf

WORKDIR /build

# Copy local files into container
COPY . .

# Build command as the default command
CMD nix build \
    --option system aarch64-linux \
    --no-update-lock-file \
    '.#nixosConfigurations.rpi-example.config.system.build.sdImage' && \
    mkdir -p artifacts && \
    cp -L /nix/store/*nixos-sd-image-*.img artifacts/ && \
    sha256sum artifacts/*nixos-sd-image-*.img > artifacts/SHA256SUMS