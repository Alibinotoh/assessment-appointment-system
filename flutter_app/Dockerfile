# Stage 1: Build the Flutter app
FROM debian:stable-slim as build

# Install dependencies needed for Flutter SDK installation
RUN apt-get update && apt-get install -y curl git unzip xz-utils libglu1-mesa python3 python3-pip && rm -rf /var/lib/apt/lists/*

# Set up a non-root user
RUN useradd -ms /bin/bash flutteruser
USER flutteruser
WORKDIR /home/flutteruser

# Download and install Flutter SDK
ARG FLUTTER_VERSION=3.22.1
RUN git clone https://github.com/flutter/flutter.git --depth 1 --branch ${FLUTTER_VERSION} /home/flutteruser/flutter
ENV PATH="/home/flutteruser/flutter/bin:${PATH}"

# Run flutter doctor to download Dart SDK
RUN flutter doctor

# Copy the app files and build
COPY --chown=flutteruser:flutteruser . .
RUN flutter pub get
RUN flutter build web --web-renderer canvaskit --verbose

# Stage 2: Set up the production server
FROM debian:stable-slim

# Install Python
RUN apt-get update && apt-get install -y python3 && rm -rf /var/lib/apt/lists/*

# Set up a non-root user for the server
RUN useradd -ms /bin/bash serveruser
USER serveruser
WORKDIR /home/serveruser

# Copy the server script and the built app from the build stage
COPY --chown=serveruser:serveruser server.py .
COPY --from=build /home/flutteruser/build/web ./build/web

# Expose the port Render will use (Render sets the PORT env var, so we don't need to hardcode it)
# EXPOSE 10000

# Start the server
CMD ["python3", "server.py"]
