import os
import sys
import subprocess
import random
import string
from pathlib import Path

file_desc_length = 10

def get_desc():
    return ''.join(random.choice(string.ascii_uppercase + string.digits) for _ in range(file_desc_length))


def upload(dirname, filename):
    """Upload a file to YouTube with a random title."""
    filepath = Path(dirname) / filename
    title = get_desc()
    
    # Use list format for security (no shell injection)
    command = ['youtube-upload', '--privacy=private', f'--title={title}', str(filepath)]
    
    try:
        print(f"Uploading: {filepath}")
        process = subprocess.Popen(command,
                                   stdout=subprocess.PIPE,
                                   stderr=subprocess.PIPE,
                                   stdin=subprocess.PIPE)
        output, error = process.communicate()
        
        if process.returncode == 0:
            print(f"Upload complete. Output: {output.decode('utf-8')}")
        else:
            print(f"Upload failed. Error: {error.decode('utf-8')}")
    except Exception as e:
        print(f"Error during upload: {e}")


def find_files(path, ext):
    """Find and upload all files with specified extension in path."""
    search_path = Path(path)
    
    if not search_path.exists():
        print(f"Error: Path '{path}' does not exist")
        return
    
    for file_path in search_path.rglob(f"*{ext}"):
        if file_path.is_file():
            print(f"Found file: {file_path}")
            upload(str(file_path.parent), file_path.name)


if __name__ == '__main__':
    if len(sys.argv) < 3:
        print("Usage: python uploader.py <directory_path> <file_extension>")
        print("Example: python uploader.py ./audio .mp3")
        sys.exit(1)
    
    find_files(sys.argv[1], sys.argv[2])
