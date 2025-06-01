#!/bin/bash

echo "=== Docker Face Recognition Diagnostic ==="
echo "This script will check your setup and help identify issues"
echo

# Basic system info
echo "🖥️  System Information:"
echo "OS: $(uname -a)"
echo "User: $(whoami)"
echo "Current directory: $(pwd)"
echo "Shell: $SHELL"
echo

# Check Docker installation
echo "🐳 Docker Installation Check:"
if command -v docker &> /dev/null; then
    echo "✅ Docker is installed"
    docker --version
    
    # Check Docker daemon
    if docker info &> /dev/null; then
        echo "✅ Docker daemon is running"
        echo "Docker info:"
        docker info | grep -E "(Server Version|Storage Driver|Operating System|Architecture)"
    else
        echo "❌ Docker daemon is not running or no permission"
        echo "Try: sudo systemctl start docker"
        echo "Or: sudo usermod -aG docker $USER && newgrp docker"
    fi
else
    echo "❌ Docker is not installed"
    echo "Install with: curl -fsSL https://get.docker.com -o get-docker.sh && sudo sh get-docker.sh"
fi
echo

# Check Docker Compose
echo "🔧 Docker Compose Check:"
if command -v docker-compose &> /dev/null; then
    echo "✅ docker-compose is installed"
    docker-compose --version
    COMPOSE_CMD="docker-compose"
elif docker compose version &> /dev/null; then
    echo "✅ docker compose (plugin) is available"
    docker compose version
    COMPOSE_CMD="docker compose"
else
    echo "❌ Docker Compose is not installed"
    echo "Install with: sudo curl -L 'https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-$(uname -s)-$(uname -m)' -o /usr/local/bin/docker-compose"
    echo "Then: sudo chmod +x /usr/local/bin/docker-compose"
fi
echo

# Check required files
echo "📁 File Check:"
files=("face_recognition_system.py" "Dockerfile" "docker-compose.yml")
for file in "${files[@]}"; do
    if [ -f "$file" ]; then
        echo "✅ $file exists ($(wc -l < "$file") lines)"
    else
        echo "❌ $file is missing"
    fi
done

if [ -d "known_faces" ]; then
    echo "✅ known_faces directory exists"
    echo "   Contents: $(ls -la known_faces/ 2>/dev/null | wc -l) items"
else
    echo "❌ known_faces directory missing"
fi
echo

# Check camera access
echo "📹 Camera Check:"
if [ -e /dev/video0 ]; then
    echo "✅ Camera device /dev/video0 exists"
    echo "   Permissions: $(ls -la /dev/video0)"
    if groups | grep -q video; then
        echo "✅ User is in video group"
    else
        echo "⚠️  User not in video group (might need: sudo usermod -aG video $USER)"
    fi
else
    echo "❌ No camera device found at /dev/video0"
    echo "Available video devices:"
    ls -la /dev/video* 2>/dev/null || echo "   None found"
fi
echo

# Check X11/GUI setup
echo "🖥️  GUI/X11 Check:"
if [ -n "$DISPLAY" ]; then
    echo "✅ DISPLAY variable set: $DISPLAY"
else
    echo "❌ DISPLAY variable not set"
fi

if [ -e "/tmp/.X11-unix" ]; then
    echo "✅ X11 socket exists"
    echo "   Permissions: $(ls -la /tmp/.X11-unix/)"
else
    echo "❌ X11 socket not found"
fi

if command -v xhost &> /dev/null; then
    echo "✅ xhost command available"
else
    echo "❌ xhost not found (install: sudo apt-get install x11-xserver-utils)"
fi

if [ -f "$HOME/.Xauthority" ]; then
    echo "✅ .Xauthority file exists"
else
    echo "⚠️  .Xauthority file not found"
fi
echo

# Check Python dependencies (if available)
echo "🐍 Python Environment Check:"
if command -v python3 &> /dev/null; then
    echo "✅ Python3 available: $(python3 --version)"
    
    # Check if modules are available
    modules=("cv2" "face_recognition" "numpy")
    for module in "${modules[@]}"; do
        if python3 -c "import $module" 2>/dev/null; then
            echo "✅ $module module available"
        else
            echo "❌ $module module not available (will be installed in Docker)"
        fi
    done
else
    echo "❌ Python3 not found"
fi
echo

# Docker images and containers
echo "🏗️  Docker Images and Containers:"
if command -v docker &> /dev/null && docker info &> /dev/null; then
    echo "Images:"
    docker images | grep -E "(face-recognition|REPOSITORY)" || echo "   No face-recognition images found"
    echo
    echo "Containers:"
    docker ps -a | grep -E "(face-recognition|CONTAINER)" || echo "   No face-recognition containers found"
else
    echo "❌ Cannot check - Docker not accessible"
fi
echo

# Suggested next steps
echo "🎯 Next Steps:"
echo "1. Fix any ❌ issues shown above"
echo "2. Ensure all required files are in current directory"
echo "3. Run: chmod +x setup.sh && ./setup.sh"
echo "4. If build fails, check Docker logs: $COMPOSE_CMD logs"
echo "5. For permission issues: sudo usermod -aG docker,video $USER && newgrp docker"
echo

echo "=== Diagnostic Complete ==="