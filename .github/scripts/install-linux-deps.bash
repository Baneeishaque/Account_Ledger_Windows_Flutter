#!/bin/bash
# This script installs all necessary OS-level dependencies for building the Flutter Linux app.
# It's designed to be run from a GitHub Actions workflow.

# Exit immediately if a command exits with a non-zero status.
set -e

echo "Updating package lists..."
sudo apt-get update

echo "Installing build dependencies..."
sudo apt-get install -y \
    clang \
    cmake \
    ninja-build \
    pkg-config \
    libgtk-3-dev \
    liblzma-dev \
    curl \
    git \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa \
    libstdc++-12-dev \
    libupower-glib-dev

echo "SUCCESS: All Linux dependencies installed."

