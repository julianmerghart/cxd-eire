# STAGE 1: Build the C Engine (The "Kitchen")
FROM gcc:14 as builder
WORKDIR /build

# Install SSL development headers for compilation
RUN apt-get update && apt-get install -y libssl-dev

# Copy all files (cxd_core.c, cxd_core.h, etc.)
COPY . . 

# Compile the C core into a shared library (.so)
RUN gcc -fPIC -shared -o libcxd.so cxd_core.c -lssl -lcrypto

# STAGE 2: Python Runtime (The "Service")
FROM python:3.11-slim
WORKDIR /app

# 1. Install the runtime SSL libraries needed by the C library
RUN apt-get update && apt-get install -y \
    libssl3 \
    && rm -rf /var/lib/apt/lists/*

# 2. Install Python web dependencies
RUN pip install --no-cache-dir flask flask-cors requests

# 3. Copy the compiled library and application files from the builder
COPY --from=builder /build/libcxd.so .
COPY cxdengine.py .
COPY config.json .

# 4. Set Environment Variables for Render
# Forces the system to look in the current folder for the C library
ENV LD_LIBRARY_PATH=/app
# Default port for Render
EXPOSE 10000

# Start the Python Gateway
CMD ["python", "cxdengine.py"]
