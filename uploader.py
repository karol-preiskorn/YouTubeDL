import os
import sys
import subprocess
import random
import string
from pathlib import Path

file_desc_length = 10
ALLOWED_EXTENSIONS = {
    ".aac",
    ".m4a",
    ".mkv",
    ".mp3",
    ".mp4",
    ".ogg",
    ".wav",
    ".webm",
}


def get_desc():
    return "".join(
        random.choice(string.ascii_uppercase + string.digits)
        for _ in range(file_desc_length)
    )


def upload(dirname, filename):
    """Upload a file to YouTube with a random title."""
    filepath = Path(dirname) / filename
    title = get_desc()

    # Use list format for security (no shell injection)
    command = ["youtube-upload", "--privacy=private", f"--title={title}", str(filepath)]

    try:
        print(f"Uploading: {filepath}")
        process = subprocess.Popen(
            command,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
        )
        output, error = process.communicate()
    except FileNotFoundError:
        print("Error during upload: youtube-upload was not found")
        return False
    except OSError as error:
        print(f"Error during upload: {error}")
        return False

    if process.returncode == 0:
        print(f"Upload complete. Output: {output.decode('utf-8', errors='replace')}")
        return True

    print(f"Upload failed. Error: {error.decode('utf-8', errors='replace')}")
    return False


def find_files(path, ext):
    """Find and upload all files with specified extension in path."""
    search_path = Path(path)
    extension = ext.lower()

    if not search_path.is_dir():
        print(f"Error: Directory '{path}' does not exist")
        return False

    if extension not in ALLOWED_EXTENSIONS:
        allowed = ", ".join(sorted(ALLOWED_EXTENSIONS))
        print(f"Error: Unsupported extension '{ext}'. Allowed: {allowed}")
        return False

    success = True

    for file_path in search_path.rglob("*"):
        if file_path.is_file() and file_path.suffix.lower() == extension:
            print(f"Found file: {file_path}")
            success = upload(str(file_path.parent), file_path.name) and success

    return success


def main():
    program = Path(sys.argv[0]).name
    if len(sys.argv) < 3:
        print(f"Usage: python {program} <directory_path> <file_extension>")
        print(f"Example: python {program} ./audio .mp3")
        return 1

    return 0 if find_files(sys.argv[1], sys.argv[2]) else 1


if __name__ == "__main__":
    sys.exit(main())
