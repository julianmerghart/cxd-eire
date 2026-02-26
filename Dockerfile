# STAGE 1: Build the C Core
FROM gcc:14 as builder
WORKDIR /build
# Ensure OpenSSL headers are available for compilation
RUN apt-get update && apt-get install -y libssl-dev
COPY . . 
RUN gcc -fPIC -shared -o libcxd.so cxd_core.c -lssl -lcrypto

# STAGE 2: Production Runtime
FROM python:3.11-slim
WORKDIR /app

# FIX: Install the SSL runtime that the C library needs to function
RUN apt-get update && apt-get install -y \
    libssl3 \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Copy only the necessary files from the builder
COPY --from=builder /build/libcxd.so .
COPY cxdengine.py .
COPY config.json .

# Force the dynamic linker to see the current directory
ENV LD_LIBRARY_PATH=/app

EXPOSE 10000
CMD ["python", "cxdengine.py"]
