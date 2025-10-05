# Dockerfile for Minimal Developer Environment - DataOps
# Build: docker build -t dataops-env:latest .
# Run: docker run -it --rm -v $(pwd):/workspace dataops-env:latest

FROM mcr.microsoft.com/devcontainers/base:alpine-3.19

# Metadata
LABEL maintainer="tmj"
LABEL description="Minimal Developer Environment for DataOps - 450MB"
LABEL version="1.0.0"

# Create tmj user (non-root)
RUN adduser -D -s /bin/sh tmj && \
    echo "tmj ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/tmj && \
    chmod 0440 /etc/sudoers.d/tmj

# Install system dependencies
RUN apk add --no-cache \
    # Build essentials (needed for some Python packages)
    gcc \
    g++ \
    musl-dev \
    python3-dev \
    # Database clients
    postgresql-client \
    mysql-client \
    sqlite \
    # Text processing
    jq \
    yq \
    xmlstarlet \
    libxml2-utils \
    libxslt \
    # Development tools
    git \
    curl \
    wget \
    openssh \
    bash \
    shadow

# Install Python 3.12 and pip
# Use --break-system-packages to allow pip upgrades (safe in container)
RUN apk add --no-cache python3 py3-pip && \
    pip3 install --break-system-packages --upgrade pip setuptools wheel

# Install Node.js 20 LTS and npm
RUN apk add --no-cache nodejs npm && \
    npm install -g npm@latest 2>/dev/null || true

# Install PowerShell
RUN apk add --no-cache \
    ca-certificates \
    less \
    ncurses-terminfo-base \
    krb5-libs \
    libgcc \
    libintl \
    libssl3 \
    libstdc++ \
    tzdata \
    userspace-rcu \
    zlib \
    icu-libs && \
    apk -X https://dl-cdn.alpinelinux.org/alpine/edge/main add --no-cache lttng-ust && \
    mkdir -p /opt/microsoft/powershell/7 && \
    wget -O /tmp/powershell.tar.gz https://github.com/PowerShell/PowerShell/releases/download/v7.4.0/powershell-7.4.0-linux-musl-x64.tar.gz && \
    tar zxf /tmp/powershell.tar.gz -C /opt/microsoft/powershell/7 && \
    chmod +x /opt/microsoft/powershell/7/pwsh && \
    ln -s /opt/microsoft/powershell/7/pwsh /usr/bin/pwsh && \
    rm /tmp/powershell.tar.gz

# Install GitHub CLI
RUN apk add --no-cache github-cli

# Install DuckDB
RUN wget -q https://github.com/duckdb/duckdb/releases/latest/download/duckdb_cli-linux-amd64.zip && \
    unzip -q duckdb_cli-linux-amd64.zip && \
    mv duckdb /usr/local/bin/ && \
    chmod +x /usr/local/bin/duckdb && \
    rm duckdb_cli-linux-amd64.zip

# Install Python DataOps packages
RUN pip3 install --break-system-packages --no-cache-dir \
    # Core data processing
    duckdb==0.10.0 \
    pandas==2.2.0 \
    polars==0.20.0 \
    pyarrow==15.0.0 \
    # Data formats
    deltalake==0.15.0 \
    fastparquet==2024.2.0 \
    xmltodict==0.13.0 \
    lxml==5.1.0 \
    avro-python3==1.10.2 \
    fastavro==1.9.4 \
    protobuf==4.25.0 \
    openpyxl==3.1.2 \
    pyyaml==6.0.1 \
    jsonschema==4.21.1 \
    # DataOps tools
    great-expectations==0.18.0 \
    dbt-core==1.7.0 \
    dbt-duckdb==1.7.0 \
    # Utilities
    python-dotenv==1.0.0 \
    click==8.1.7 \
    black==24.1.0 \
    pylint==3.0.0 \
    pytest==7.4.0

# Install Node.js packages
RUN npm install -g --quiet \
    csvtojson \
    json2csv \
    xml2js \
    fast-csv \
    papaparse \
    prettier

# Create workspace directory
RUN mkdir -p /workspace/data/{raw,processed,output} && \
    chown -R tmj:tmj /workspace

# Set up DuckDB directory
RUN mkdir -p /home/tmj/.duckdb && \
    chown -R tmj:tmj /home/tmj

# Clean up
RUN apk del gcc g++ musl-dev python3-dev && \
    rm -rf /var/cache/apk/* /tmp/* /root/.cache /home/tmj/.cache 2>/dev/null || true

# Switch to non-root user
USER tmj
WORKDIR /workspace

# Environment variables
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    NODE_ENV=development \
    DATA_PATH=/workspace/data \
    PATH="/home/tmj/.local/bin:${PATH}"

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD python3 -c "import duckdb; import pandas; import polars" || exit 1

# Default command
CMD ["/bin/sh"]
