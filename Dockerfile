# Use the official Maven image with JDK 21
FROM maven:3.9.9-sapmachine-21

# Verify Maven and Java version
RUN java -version && mvn -version

# Set the working directory
WORKDIR /app

# Optionally, copy your source code here
# COPY . /app

# Default command (can be customized based on your project)
CMD ["sh"]

