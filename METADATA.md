# Metadata Information

## Overview

All downloaded files (both video and audio) now include comprehensive metadata embedded and saved as separate files for maximum compatibility and information preservation.

## Metadata Included

### For All Downloads (Video & Audio)

#### Embedded in Files

- **Title** - Video/audio title
- **Artist/Creator** - Channel name or creator
- **Description** - Full video description
- **Date** - Upload date
- **Genre/Category** - YouTube category
- **URL/Comment** - Original YouTube URL
- **Chapters** - Timeline chapters (if available)
- **Thumbnail** - Embedded album art/cover

#### Separate Files Created

- **`.description`** - Text file with full description
- **`.info.json`** - Complete metadata JSON with all available information including:
  - Video ID
  - All available formats
  - Upload date and time
  - View count, like count
  - Channel information
  - Tags
  - Thumbnails (all resolutions)
  - Chapters/timestamps
  - Subtitles information
  - And much more...

### Video (MKV) Specific

Additional features for video downloads:

- **Subtitles** - Automatically downloads and embeds English subtitles (if available)
  - Language priority: `en.*,en` (all English variants)
  - Embedded directly in MKV container
- **Video Chapters** - Timeline chapters embedded in file
- **Thumbnail** - High-quality thumbnail embedded in video metadata

### Audio (MP3) Specific

Additional features for audio downloads:

- **Album Art** - Thumbnail embedded as MP3 cover art
- **ID3 Tags** - Standard MP3 metadata tags:
  - TPE1 (Artist)
  - TIT2 (Title)
  - TALB (Album - if from playlist)
  - TDRC (Date)
  - COMM (Comment with URL)

## File Structure Example

After downloading a video, you'll get:

```
video/
├── Video_Title.mp4 (or .mkv after merging)
├── Video_Title.description
├── Video_Title.info.json
└── Video_Title.en.srt (if subtitles available)
```

After downloading audio:

```
audio/
├── Audio_Title.mp3
├── Audio_Title.description
└── Audio_Title.info.json
```

## Viewing Metadata

### Using ffprobe (for embedded metadata)

```bash
# View all metadata
ffprobe -v quiet -print_format json -show_format file.mp4

# View specific tags
ffprobe -v quiet -show_entries format_tags=title,artist,date file.mp3
```

### Using exiftool (more detailed)

```bash
# Install exiftool
sudo apt install libimage-exiftool-perl

# View all metadata
exiftool file.mp4
exiftool file.mp3
```

### Using Media Players

- **VLC**: Tools → Media Information (Ctrl+I)
- **MPV**: Press `i` during playback
- **MusicBee/Foobar2000**: Right-click → Properties

## Accessing JSON Metadata

The `.info.json` file contains extensive metadata in JSON format:

```bash
# Pretty print JSON
python3 -m json.tool file.info.json

# Extract specific fields using jq
jq '.title, .upload_date, .view_count' file.info.json

# Search for specific information
grep -i "duration" file.info.json
```

## Metadata Benefits

1. **Organization** - Easy to sort and organize your media library
2. **Search** - Find files by metadata fields
3. **Preservation** - Keep original video information even offline
4. **Compatibility** - Works with all major media players and libraries
5. **Archival** - Complete information for long-term storage
6. **Backup** - Re-upload or recreate with original metadata

## Configuration Options

The metadata options are defined in [yt.sh](yt.sh):

```bash
COMMON_OPTS="--restrict-filenames --add-metadata --write-description --write-info-json --embed-chapters"
```

### To Disable Specific Metadata

Edit `yt.sh` and remove options:

- Remove `--write-description` to skip description files
- Remove `--write-info-json` to skip JSON files
- Remove `--embed-chapters` to skip chapter embedding
- Remove `--embed-thumbnail` to skip thumbnail embedding (video/audio sections)
- Remove `--write-subs --embed-subs` to skip subtitles (video section)

### To Add More Metadata

Available options to add to `COMMON_OPTS`:

- `--write-thumbnail` - Save thumbnail as separate image file
- `--write-all-thumbnails` - Save all thumbnail resolutions
- `--write-comments` - Save comments to separate file
- `--write-annotations` - Save annotations (if available)
- `--add-chapters` - Add chapters from description
- `--parse-metadata "%(title)s:%(meta_title)s"` - Custom metadata parsing

## Troubleshooting

**Metadata not embedded:**

- Ensure ffmpeg is installed: `sudo apt install ffmpeg`
- Check yt-dlp version: `yt-dlp --version` (should be 2025.12.08+)

**Missing JSON files:**

- Check `COMMON_OPTS` includes `--write-info-json`
- Verify write permissions in output directory

**Subtitles not found:**

- Not all videos have subtitles
- Check available subtitles: `yt-dlp --list-subs <url>`
- Some videos only have auto-generated subtitles

**Thumbnail not embedded:**

- Requires ffmpeg with appropriate codecs
- Some formats don't support embedded thumbnails
- Check separate `.webp` or `.jpg` file in directory

## See Also

- [README.md](README.md) - General usage
- [TROUBLESHOOTING.md](TROUBLESHOOTING.md) - Common issues
- [yt-dlp metadata documentation](https://github.com/yt-dlp/yt-dlp#post-processing-options)
