FROM ubuntu:focal

ENV DEBIAN_FRONTEND=noninteractive

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# System locale setup
RUN apt-get update \
  && apt-get install -y --no-install-recommends locales \
  && locale-gen en_US.UTF-8 \
  && dpkg-reconfigure locales \
  && rm -rf /var/lib/apt/lists/* \
  && rm -rf /tmp/*

ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8 

# All apt installations in one layer
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    software-properties-common \
  && add-apt-repository ppa:git-core/ppa \
  && apt-get update \
  && apt-get install -y --no-install-recommends \
    curl \
    tar \
    apt-transport-https \
    ca-certificates \
    sudo \
    openssh-client \
    python3 \
    python3-dev \
    python3-pip \
    python3-coverage \
    python2 \
    dumb-init \
    git-core \
    xz-utils \
    systemd \
  && c_rehash \
  && rm -rf /var/lib/apt/lists/* \
  && rm -rf /tmp/*

# Install Nix and configure system-wide
RUN sh <(curl -L https://nixos.org/nix/install) --daemon

# Configure Nix system-wide with flakes enabled
RUN mkdir -p /etc/nix \
    && echo 'experimental-features = nix-command flakes' >> /etc/nix/nix.conf

# Add Nix paths according to multi-user installation guidelines
ENV PATH="/nix/var/nix/profiles/system/sw/bin:/nix/var/nix/profiles/default/bin:$PATH"
ENV NIX_PATH="nixpkgs=/nix/var/nix/profiles/per-user/root/channels/nixpkgs:/nix/var/nix/profiles/per-user/root/channels"

# Create necessary directories with proper permissions
RUN mkdir -p /opt/hostedtoolcache \
    && mkdir -p /home/ubuntu/runner \
    && mkdir -p /home/ubuntu/_work

# Setup Python 2 and pip
RUN curl -s -L -O https://bootstrap.pypa.io/pip/2.7/get-pip.py \
    && python2 get-pip.py \
    && rm get-pip.py

# User setup and permissions
RUN groupadd ubuntu \
    && useradd -rm -d /home/ubuntu -s /bin/bash -g ubuntu -G sudo -u 1001 ubuntu \
    && echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers \
    && chown -R ubuntu:ubuntu /home/ubuntu

# Copy and setup runner files
COPY --chown=ubuntu:ubuntu bootstrap entrypoint /home/ubuntu/runner/
RUN chmod +x /home/ubuntu/runner/bootstrap \
    && chmod +x /home/ubuntu/runner/entrypoint

# Switch to non-root user
USER ubuntu
WORKDIR /home/ubuntu/runner

# Run bootstrap after switching user
RUN /home/ubuntu/runner/bootstrap \
    && rm /home/ubuntu/runner/bootstrap

ENTRYPOINT ["/home/ubuntu/runner/entrypoint"]
CMD ["/home/ubuntu/runner/bin/runsvc.sh"]

HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD pgrep -f runsvc.sh || exit 1

LABEL maintainer="aloshy.🅰🅸 <noreply@aloshy.ai>"
LABEL version="1.0"
LABEL description="GitHub Actions self-hosted runner for Raspberry Pi 4"