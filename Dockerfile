# Use Maven image with JDK 21 from SAP
FROM maven:3.9.9-sapmachine-21

# Install Git and Docker client
RUN apt-get update && apt-get install -y \
  git \
  docker.io \
  && rm -rf /var/lib/apt/lists/*

# Set the working directory
WORKDIR /workspace

# Set the default command to bash
CMD ["bash"]


