# YouTubeDL

A command-line tool to download YouTube videos and playlists as audio (mp3) or video (mkv) files.

## Features

- Download single YouTube videos or entire playlists
- Convert to audio (mp3) or video (mkv) format
- Automatic metadata tagging
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
   ```bash
   sudo apt-get install python-is-python3
   pip install -r requirements.txt
   ```

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/karol-preiskorn/YouTubeDL.git
   cd YouTubeDL
   ```

2. Make the script executable:
   ```bash
   chmod +x yt.sh
   ```

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

Upload downloaded files to YouTube:

```bash
python uploader.py <directory_path> <file_extension>
```

Example:
```bash
python uploader.py ./audio .mp3
python yt-upload.py ./video .mkv
```

## Output Structure

Downloaded files are organized as follows:

```
YouTubeDL/
├── audio/
│   ├── Video_Title.mp3
│   └── Playlist_Name/
│       ├── 001 - Video_Title.mp3
│       └── 002 - Video_Title.mp3
└── video/
    ├── Video_Title.mkv
    └── Playlist_Name/
        ├── 001 - Video_Title.mkv
        └── 002 - Video_Title.mkv
```

## Technical Details

### Video Quality
- Maximum resolution: 640p
- Format: Best available video + audio combined

### Audio Quality
- Format: MP3
- Quality: Highest available (0)
- Includes embedded thumbnail and metadata

### Playlist Downloads
- Sleep interval: 10-30 seconds between downloads
- Continues on errors (skips unavailable videos)
- Preserves playlist order with index numbers

## Project Structure

```
.
├── yt.sh           # Main download script
├── uploader.py     # YouTube upload utility
├── yt-upload.py    # Alternative upload utility
├── requirements.txt # Python dependencies
├── README.md       # This file
├── .gitignore      # Git ignore rules
├── audio/          # Downloaded audio files (gitignored)
└── video/          # Downloaded video files (gitignored)
```

## Troubleshooting

**yt-dlp not found:**
```bash
which yt-dlp
sudo apt install yt-dlp
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
