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

# Setup Python 2 and pip
RUN curl -s -L -O https://bootstrap.pypa.io/pip/2.7/get-pip.py \
    && python2 get-pip.py \
    && rm get-pip.py

RUN mkdir -p /opt/hostedtoolcache

RUN groupadd ubuntu
RUN useradd -rm -d /home/ubuntu -s /bin/bash -g ubuntu -G sudo -u 1001 ubuntu
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

USER ubuntu
RUN mkdir /home/ubuntu/runner
RUN mkdir /home/ubuntu/_work
WORKDIR /home/ubuntu/runner

COPY --chown=ubuntu:ubuntu bootstrap entrypoint /home/ubuntu/runner/

RUN sudo chmod +x /home/ubuntu/runner/bootstrap \
  && sudo chmod +x /home/ubuntu/runner/entrypoint \
  && /home/ubuntu/runner/bootstrap \
  && rm /home/ubuntu/runner/bootstrap

ENTRYPOINT ["/home/ubuntu/runner/entrypoint"]
CMD ["/home/ubuntu/runner/bin/runsvc.sh"]

HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD pgrep -f runsvc.sh || exit 1

LABEL maintainer="aloshy.🅰🅸 <noreply@aloshy.ai>"
LABEL version="1.0"
LABEL description="GitHub Actions self-hosted runner for Raspberry Pi 4"