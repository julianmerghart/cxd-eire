# STAGE 1: Build the C Engine
FROM gcc:14 as builder
WORKDIR /build
# Copy your C source files
COPY ./libcxd/cxd_core.c .
COPY ./libcxd/cxd_core.h .
# Compile into a Shared Object library (.so)
RUN gcc -fPIC -shared -o libcxd.so cxd_core.c -lssl -lcrypto

# STAGE 2: Run the Python API
FROM python:3.11-slim
WORKDIR /app
# Install Python dependencies
RUN pip install --no-cache-dir Flask requests flask-cors
# Copy the compiled library from the builder stage
COPY --from=builder /build/libcxd.so .
# Copy your Python wrapper and config
COPY cxdengine.py .
COPY config.json .

EXPOSE 8080
# Run the Python gateway which calls the C core
CMD ["python", "cxdengine.py"]
