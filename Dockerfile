# STAGE 1: Build the C Engine
FROM gcc:14 as builder
WORKDIR /build

# Change these lines to look in the root instead of /libcxd/
COPY cxd_core.c .
COPY cxd_core.h .

# Compile into a Shared Object library (.so)
RUN gcc -fPIC -shared -o libcxd.so cxd_core.c -lssl -lcrypto
