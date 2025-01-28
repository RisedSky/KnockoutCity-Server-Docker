FROM --platform=linux/amd64 debian:bullseye

LABEL org.opencontainers.image.source "https://github.com/Tandashi/knockoutcity-server-docker"
LABEL org.opencontainers.image.description "A Docker Container Image that runs a Knockout City Private Server"

ENV DEBIAN_FRONTEND=noninteractive

# Add multiarch support and install dependencies
RUN dpkg --add-architecture i386 && apt-get update && apt-get install -y \
    wget \
    curl \
    ca-certificates \
    gpg \
    unzip \
    software-properties-common \
    libwine:i386 \
    fonts-wine:i386 \
    wine \
    wine32 \
    libx11-6 \
    libfreetype6 \
    libpng16-16 \
    tzdata

RUN apt-get update && apt-get install -y \
    libx11-6:i386 \
    libfreetype6:i386 \
    libpng16-16:i386 \
    libxrender1:i386 \
    libxcb1:i386 \
    libxext6:i386 \
    libxi6:i386 \
    libsm6:i386 \
    libice6:i386 \
    libcups2:i386 \
    && rm -rf /var/lib/apt/lists/*

# Install WineHQ
RUN mkdir -pm755 /etc/apt/keyrings && \
    wget -O - https://dl.winehq.org/wine-builds/winehq.key | gpg --dearmor -o /etc/apt/keyrings/winehq-archive.key && \
    wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/debian/dists/bullseye/winehq-bullseye.sources && \
    apt-get update && apt-get install --install-recommends winehq-stable -y

# Clean up
RUN rm -rf /var/lib/apt/lists/*

RUN wineboot --init winetricks

# Initialize Wine environment
RUN winecfg || wineboot || { echo "Wine initialization failed"; exit 1; }

# Copy entrypoint script
COPY --chmod=0755 entrypoint.sh entrypoint.sh

ENTRYPOINT ["sh", "entrypoint.sh"]
