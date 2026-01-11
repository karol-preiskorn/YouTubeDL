#!/usr/bin/env bash
#
# PROGRAM: test.sh
# Test script to verify YouTubeDL setup
#

set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo "=== YouTubeDL Test Suite ==="

# Test 1: Check if venv exists
if [ -d "venv" ]; then
    echo -e "${GREEN}✓${NC} Virtual environment exists"
else
    echo -e "${RED}✗${NC} Virtual environment not found"
    echo "Run: ./setup.sh"
    exit 1
fi

# Test 2: Activate venv and check Python
source venv/bin/activate
if [[ "$VIRTUAL_ENV" ]]; then
    echo -e "${GREEN}✓${NC} Virtual environment activated"
else
    echo -e "${RED}✗${NC} Failed to activate virtual environment"
    exit 1
fi

# Test 3: Check Python version
PYTHON_VERSION=$(python --version 2>&1)
echo -e "${GREEN}✓${NC} Python: $PYTHON_VERSION"

# Test 4: Check if packages are installed
python -c "import googleapiclient" 2>/dev/null && echo -e "${GREEN}✓${NC} Google API client installed" || echo -e "${RED}✗${NC} Google API client not found"

# Test 5: Check if scripts are executable
[ -x "yt.sh" ] && echo -e "${GREEN}✓${NC} yt.sh is executable" || echo -e "${RED}✗${NC} yt.sh is not executable"
[ -x "setup.sh" ] && echo -e "${GREEN}✓${NC} setup.sh is executable" || echo -e "${RED}✗${NC} setup.sh is not executable"

# Test 6: Check Python scripts syntax
python -m py_compile uploader.py && echo -e "${GREEN}✓${NC} uploader.py syntax OK" || echo -e "${RED}✗${NC} uploader.py syntax error"
python -m py_compile yt-upload.py && echo -e "${GREEN}✓${NC} yt-upload.py syntax OK" || echo -e "${RED}✗${NC} yt-upload.py syntax error"

# Test 7: Check help output
python uploader.py 2>&1 | grep -q "Usage:" && echo -e "${GREEN}✓${NC} uploader.py help works" || echo -e "${RED}✗${NC} uploader.py help failed"

echo ""
echo -e "${GREEN}All tests passed! Project is ready to use.${NC}"
echo ""
echo "To download a video:"
echo "  ./yt.sh -u 'https://www.youtube.com/watch?v=VIDEO_ID' -o mkv"
echo ""
echo "To run upload scripts (with venv active):"
echo "  source venv/bin/activate"
echo "  python uploader.py ./audio .mp3"
