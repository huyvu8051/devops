# Use Maven image with JDK 21 from SAP
FROM maven:3.9.9-sapmachine-21

# Install Git, Docker client, Node.js 24, and PostgreSQL client (for pg_dump)
RUN apt-get update && apt-get install -y \
    git \
    docker.io \
    curl \
    postgresql-client \
    && curl -fsSL https://deb.nodesource.com/setup_24.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# Set the working directory
WORKDIR /workspace

# Set the default command to bash
CMD ["bash"]
