# Use Python slim image which is much faster to build
FROM python:3.9-slim

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Set working directory
WORKDIR /app

# Install only essential system dependencies
RUN apt-get update && apt-get install -y \
    cmake \
    build-essential \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender-dev \
    libgomp1 \
    libgtk-3-0 \
    libavcodec-dev \
    libavformat-dev \
    libswscale-dev \
    libv4l-dev \
    libatlas-base-dev \
    gfortran \
    libjpeg-dev \
    libpng-dev \
    && rm -rf /var/lib/apt/lists/*

# Upgrade pip and install wheel for faster builds
RUN python -m pip install --upgrade pip setuptools wheel

# Install Python dependencies (using newer compatible versions)
RUN pip install --no-cache-dir \
    opencv-python-headless==4.8.1.78 \
    face-recognition==1.3.0 \
    numpy==1.24.3 \
    Pillow

# Create directories
RUN mkdir -p /app/known_faces

# Copy the application
COPY face_recognition_system.py /app/
COPY known_faces/ /app/known_faces/

# Set environment variables for GUI display
ENV DISPLAY=:0
ENV QT_X11_NO_MITSHM=1

# Make sure the script is executable
RUN chmod +x /app/face_recognition_system.py

# Create a non-root user for security
RUN useradd -m -s /bin/bash faceuser && \
    chown -R faceuser:faceuser /app

USER faceuser

# Default command
CMD ["python", "face_recognition_system.py"]