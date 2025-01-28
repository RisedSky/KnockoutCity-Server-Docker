# Use the official Debian image as base, with amd64 architecture specified
FROM --platform=linux/amd64 debian:bullseye

LABEL org.opencontainers.image.source "https://github.com/Tandashi/knockoutcity-server-docker"
LABEL org.opencontainers.image.description "A Docker Container Image that runs a Knockout City Private Server"

# Set environment variable to disable interactive prompts during package installs
ENV DEBIAN_FRONTEND=noninteractive

# Add multiarch support and install dependencies
RUN dpkg --add-architecture i386 && apt-get update && apt-get install -y \
    wget \
    curl \
    ca-certificates \
    gpg \
    unzip

RUN apt-get install -y \
    libwine:i386 \
    fonts-wine:i386
RUN apt install -y \
    tzdata
RUN mkdir -pm755 /etc/apt/keyrings

RUN wget -O - https://dl.winehq.org/wine-builds/winehq.key | gpg --dearmor -o /etc/apt/keyrings/winehq-archive.key -

RUN wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/debian/dists/bullseye/winehq-bullseye.sources

RUN apt update && apt install --install-recommends winehq-stable -y

RUN rm -rf /var/lib/apt/lists/*

# Verify wine installation
RUN wine --version || { echo "Wine installation check failed"; exit 1; }

# Wine boot step (ensure this step succeeds)
RUN wine wineboot || { echo "Wine boot failed"; exit 1; }

# Copy entrypoint script and set permissions
COPY --chmod=0755 entrypoint.sh entrypoint.sh

# Set entrypoint
ENTRYPOINT ["sh", "entrypoint.sh"]
