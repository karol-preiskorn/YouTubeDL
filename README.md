# YouTubeDL

A command-line tool to download YouTube videos and playlists as audio (mp3) or video (mkv) files.

## Features

- Download single YouTube videos or entire playlists
- Convert to audio (mp3) or video (mkv) format
- **Comprehensive metadata preservation** (see [METADATA.md](METADATA.md)):
  - Embedded titles, artist, date, description, URL
  - Separate `.info.json` files with complete metadata
  - Description files for easy reading
  - Embedded thumbnails/album art
  - Auto-download and embed English subtitles (video)
  - Chapter markers preservation
- **Automatic documentation generation**:
  - Creates `README.md` files in each download folder
  - Includes channel/playlist information extracted from YouTube
  - Lists all downloaded files with sizes
  - Links to metadata and additional files
- Progress tracking with colored output
- Error handling and validation
- Support for playlist organization

## Prerequisites

### System Requirements

- WSL2 or Linux
- Bash shell

### Required Software

1. **yt-dlp** (YouTube downloader)

   ```bash
   sudo apt install yt-dlp
   ```

   Or install the latest version:

   ```bash
   sudo curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o /usr/local/bin/yt-dlp
   sudo chmod a+rx /usr/local/bin/yt-dlp
   ```

2. **ffmpeg** (Media converter)

   ```bash
   sudo apt install ffmpeg
   ```

3. **Python 3** (For upload scripts)

4. **Python 3** (For upload scripts)

   ```bash
   sudo apt-get install python3 python3-venv python3-pip
   ```

## Installation

### Quick Setup (Recommended)

Use the automated setup script:

```bash
git clone https://github.com/karol-preiskorn/YouTubeDL.git
cd YouTubeDL
./setup.sh
```

The setup script will:

- Check system dependencies (python3, ffmpeg, yt-dlp)
- Create Python virtual environment
- Install all Python packages
- Make scripts executable

### Manual Setup

1. Clone the repository:

   ```bash
   git clone https://github.com/karol-preiskorn/YouTubeDL.git
   cd YouTubeDL
   ```

2. **Set up Python virtual environment** (recommended):

   ```bash
   # Create virtual environment
   python3 -m venv venv

   # Activate virtual environment
   source venv/bin/activate

   # Install Python dependencies
   pip install -r requirements.txt
   ```

   **Note:** To deactivate the virtual environment later, run:

   ```bash
   deactivate
   ```

3. Make the script executable:

   ```bash
   chmod +x yt.sh
   ```

**Important:** Always activate the virtual environment before running Python upload scripts:

```bash
source venv/bin/activate
python uploader.py ./audio .mp3
```

### Verify Installation

Run the test script to verify everything is working:

```bash
./test.sh
```

This will check:

- Virtual environment setup
- Python packages installation
- Script permissions
- Syntax validation

## Usage

### Download Script (yt.sh)

Basic syntax:

```bash
./yt.sh -u <youtube_url> -o <format>
```

**Options:**

- `-u <url>` : YouTube video or playlist URL (required)
- `-o <format>` : Output format - either `mp3` or `mkv` (required)

**Examples:**

1. Download a single video as mp3:

   ```bash
   ./yt.sh -u 'https://www.youtube.com/watch?v=GxrPn7qwt6c' -o mp3
   ```

2. Download a single video as mkv:

   ```bash
   ./yt.sh -u 'https://www.youtube.com/watch?v=GxrPn7qwt6c' -o mkv
   ```

3. Download an entire playlist as mp3:

   ```bash
   ./yt.sh -u 'https://www.youtube.com/playlist?list=PLxxxxxx' -o mp3
   ```

4. Download an entire playlist as mkv:

   ```bash
   ./yt.sh -u 'https://www.youtube.com/playlist?list=PLxxxxxx' -o mkv
   ```

### Upload Scripts

Upload downloaded files to YouTube (requires active virtual environment):

```bash
# Activate virtual environment first
source venv/bin/activate

# Then run upload scripts
python uploader.py <directory_path> <file_extension>
```

Example:

```bash
source venv/bin/activate
python uploader.py ./audio .mp3
python yt-upload.py ./video .mkv
```

## Output Structure

Downloaded files are organized as follows:

```
YouTubeDL/
├── audio/
│   └── Channel_Name/
│       ├── README.md (📋 Channel info & file list)
│       ├── Video_Title.mp3
│       ├── Video_Title.description
│       ├── Video_Title.info.json
│       └── Playlist_Name/
│           ├── README.md (📋 Playlist info & file list)
│           ├── 001 - Video_Title.mp3
│           ├── 001 - Video_Title.description
│           ├── 001 - Video_Title.info.json
│           └── 002 - Video_Title.mp3
└── video/
    └── Channel_Name/
        ├── README.md (📋 Channel info & file list)
        ├── Video_Title.mkv
        ├── Video_Title.description
        ├── Video_Title.info.json
        ├── Video_Title.en.srt (if subtitles available)
        └── Playlist_Name/
            ├── README.md (📋 Playlist info & file list)
            ├── 001 - Video_Title.mkv
            └── 002 - Video_Title.mkv
```

**New!** 📋 **Auto-generated README.md files** include:

- Channel information (name, ID, URL)
- Playlist details (for playlist downloads)
- Complete file listings with sizes
- Upload dates and metadata information

📋 **See [README_EXAMPLE.md](README_EXAMPLE.md) for sample auto-generated README files**

**Note:** Each download includes metadata files (`.description` and `.info.json`). See [METADATA.md](METADATA.md) for details.

## Technical Details

### Video Quality

- Maximum resolution: 640p
- Format: Best available video + audio combined
- Subtitles: Auto-downloads and embeds English subtitles when available

### Audio Quality

- Format: MP3
- Quality: Highest available (0)
- Includes embedded thumbnail and metadata

### Playlist Downloads

- Sleep interval: 10-30 seconds between downloads
- Continues on errors (skips unavailable videos)
- Preserves playlist order with index numbers

### Metadata Preservation

All downloads include comprehensive metadata:

- **Embedded**: Title, artist, date, description, URL, chapters, thumbnails
- **Separate files**: `.description` (text) and `.info.json` (complete metadata)
- **Subtitles**: Auto-downloads and embeds English subtitles for videos (when available)

📖 **See [METADATA.md](METADATA.md) for complete metadata documentation**

## Project Structure

```
.
├── setup.sh           # Automated setup script
├── test.sh            # Test/verification script
├── yt.sh              # Main download script
├── uploader.py        # YouTube upload utility
├── yt-upload.py       # Alternative upload utility
├── requirements.txt   # Python dependencies
├── METADATA.md        # Metadata documentation
├── TROUBLESHOOTING.md # Troubleshooting guide
├── README.md          # This file
├── .gitignore         # Git ignore rules
├── venv/              # Python virtual environment (created by setup)
├── audio/             # Downloaded audio files (gitignored)
└── video/             # Downloaded video files (gitignored)
```

## Troubleshooting

**📖 For detailed troubleshooting, see [TROUBLESHOOTING.md](TROUBLESHOOTING.md)**

Common quick fixes:

**yt-dlp not found or HTTP 403 errors:**

```bash
# Install latest version (recommended)
sudo curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o /usr/local/bin/yt-dlp
sudo chmod a+rx /usr/local/bin/yt-dlp
```

**ffmpeg errors:**

```bash
ffmpeg -version
sudo apt install ffmpeg
```

**Python import errors:**

```bash
pip install -r requirements.txt
```

**Permission denied:**

```bash
chmod +x yt.sh
```

## Configuration

You can create a `.ytdlrc` file in your home directory for default yt-dlp options:

```bash
# ~/.ytdlrc
--output ~/Downloads/%(title)s.%(ext)s
--restrict-filenames
--add-metadata
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is provided as-is for educational and personal use.

## Acknowledgments

- [yt-dlp](https://github.com/yt-dlp/yt-dlp) - The core download engine
- [ffmpeg](https://ffmpeg.org/) - Media processing

## Author

Karol Preiskorn ([@karol-preiskorn](https://github.com/karol-preiskorn))
