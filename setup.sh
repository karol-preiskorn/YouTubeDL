#!/usr/bin/env bash
#
# PROGRAM: setup.sh
# Setup script for YouTubeDL project
#
# This script:
# 1. Checks for required dependencies
# 2. Sets up Python virtual environment
# 3. Installs Python packages
# 4. Makes scripts executable

set -o errexit -o pipefail -o noclobber -o nounset

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}=== YouTubeDL Setup Script ===${NC}\n"

# Check for required system dependencies
echo "Checking system dependencies..."

if ! command -v python3 &> /dev/null; then
    echo -e "${RED}Error: python3 not found${NC}"
    echo "Install with: sudo apt-get install python3"
    exit 1
fi
echo -e "${GREEN}✓${NC} python3 found: $(python3 --version)"

if ! command -v ffmpeg &> /dev/null; then
    echo -e "${YELLOW}Warning: ffmpeg not found${NC}"
    echo "Install with: sudo apt install ffmpeg"
else
    echo -e "${GREEN}✓${NC} ffmpeg found"
fi

if ! command -v yt-dlp &> /dev/null; then
    echo -e "${YELLOW}Warning: yt-dlp not found${NC}"
    echo "Install with: sudo curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o /usr/local/bin/yt-dlp && sudo chmod a+rx /usr/local/bin/yt-dlp"
else
    echo -e "${GREEN}✓${NC} yt-dlp found: $(yt-dlp --version)"
fi

# Check for python3-venv
if ! python3 -m venv --help &> /dev/null; then
    echo -e "${RED}Error: python3-venv not found${NC}"
    echo "Install with: sudo apt-get install python3-venv"
    exit 1
fi
echo -e "${GREEN}✓${NC} python3-venv available"

echo ""

# Create virtual environment if it doesn't exist
if [ -d "venv" ]; then
    echo -e "${YELLOW}Virtual environment already exists${NC}"
    read -p "Do you want to recreate it? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Removing existing virtual environment..."
        rm -rf venv
    else
        echo "Keeping existing virtual environment"
    fi
fi

if [ ! -d "venv" ]; then
    echo "Creating virtual environment..."
    python3 -m venv venv
    echo -e "${GREEN}✓${NC} Virtual environment created"
fi

# Activate virtual environment
echo "Activating virtual environment..."
source venv/bin/activate

# Upgrade pip
echo "Upgrading pip..."
pip install --upgrade pip > /dev/null 2>&1
echo -e "${GREEN}✓${NC} pip upgraded"

# Install requirements
if [ -f "requirements.txt" ]; then
    echo "Installing Python packages from requirements.txt..."
    pip install -r requirements.txt
    echo -e "${GREEN}✓${NC} Python packages installed"
else
    echo -e "${YELLOW}Warning: requirements.txt not found${NC}"
fi

# Make scripts executable
echo "Making scripts executable..."
chmod +x yt.sh
echo -e "${GREEN}✓${NC} yt.sh is executable"

echo ""
echo -e "${GREEN}=== Setup Complete! ===${NC}\n"
echo "To use the project:"
echo "1. Activate virtual environment:"
echo "   ${GREEN}source venv/bin/activate${NC}"
echo ""
echo "2. Download videos:"
echo "   ${GREEN}./yt.sh -u '<youtube_url>' -o mkv${NC}"
echo ""
echo "3. Upload files (with venv active):"
echo "   ${GREEN}python uploader.py ./audio .mp3${NC}"
echo ""
echo "4. Deactivate when done:"
echo "   ${GREEN}deactivate${NC}"
echo ""
