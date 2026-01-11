# Troubleshooting Guide

## Common Issues and Solutions

### HTTP 403 Forbidden Error

**Problem:** Getting "HTTP Error 403: Forbidden" or "nsig extraction failed" warnings.

**Solution:** Update yt-dlp to the latest version:

```bash
sudo curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o /usr/local/bin/yt-dlp
sudo chmod a+rx /usr/local/bin/yt-dlp
```

The script now automatically:

- Checks for the latest version in `/usr/local/bin/yt-dlp`
- Falls back to system version if needed
- Uses `android` player client for better compatibility
- Adds `--extractor-args youtube:player_client=android`

### HTTP 503 Service Unavailable Error

**Problem:** Getting "HTTP Error 503: Service Unavailable" during downloads.

**Cause:** YouTube is rate-limiting or throttling your connection due to:

- Too many requests
- Too fast download speed
- Temporary server issues
- Network congestion

**Solutions:**

The script now automatically handles 503 errors with:

- **20 retries** (increased from 10)
- **5 second sleep** between retries
- **Throttled rate** to 1MB/s to avoid triggering rate limits
- **Automatic resume** from where download stopped

**Additional options if issues persist:**

1. **Wait and retry later** - Sometimes YouTube servers are temporarily overloaded
2. **Reduce throttle rate** in [yt.sh](yt.sh):

   ```bash
   # Change from 1M to 500K for slower, more reliable downloads
   NETWORK_OPTS="... --throttled-rate 500K"
   ```

3. **Add longer sleep intervals** between downloads:

   ```bash
   PLAYLIST_OPTS="... --sleep-interval 30 --max-sleep-interval 60 ..."
   ```

4. **Try different time of day** - YouTube may be less busy during off-peak hours
5. **Use VPN** - Sometimes different IP addresses have different rate limits

**Manual download with custom settings:**

```bash
yt-dlp --throttled-rate 500K --retries 30 --retry-sleep 10 '<url>'
```

### YouTube API Changes

YouTube frequently updates their API. If downloads fail:

1. **Update yt-dlp** (see above)
2. **Check version:**

   ```bash
   yt-dlp --version
   ```

   Should be 2025.12.08 or newer

3. **Try different player client:**
   - Current: `android` (most reliable)
   - Alternative: `web`, `mweb`, `ios`

### Format Selection

The script now uses flexible format selection:

- **Video (mkv):** `(bestvideo[height<=640]+bestaudio)/best[height<=640]`
  - Tries to get separate video+audio streams
  - Falls back to combined stream if unavailable
  - Merges to mkv format

- **Audio (mp3):** Best audio quality with thumbnail embedding

### Missing Formats

If specific quality is unavailable:

```bash
# List all available formats
yt-dlp --list-formats '<youtube_url>'

# Download specific format
yt-dlp -f <format_id> '<youtube_url>'
```

### PO Token Warnings

**Warning:** "android client https formats require a GVS PO Token"

This is normal and can be ignored. The script automatically falls back to formats that work without tokens.

If you need the highest quality and see this warning, you can:

1. Use the available formats (usually sufficient)
2. Follow the guide at: https://github.com/yt-dlp/yt-dlp/wiki/PO-Token-Guide

### Slow Downloads

If downloads are slow:

1. **Check your connection**
2. **Remove rate limiting** (edit `PLAYLIST_OPTS` in yt.sh)
3. **Reduce sleep interval** between downloads

### Playlist Issues

**Problem:** Some videos in playlist fail to download

**Solution:** This is expected behavior with `--ignore-errors` flag. The script continues with remaining videos.

Check logs for:

- Private videos
- Deleted videos
- Geo-restricted content

### Python Script Issues

If upload scripts fail:

```bash
# Install/upgrade dependencies
pip install --upgrade youtube-upload

# Check Python version (needs Python 3)
python --version

# Run with full path if needed
python3 uploader.py ./audio .mp3
```

## Update History

### January 10, 2026

- Updated to yt-dlp 2025.12.08
- Changed player client to `android` for better reliability
- Improved format selection with fallback options
- Fixed duplicate code blocks in yt.sh
- Added automatic detection of latest yt-dlp version

### Previous Updates

- Migrated Python scripts to Python 3
- Fixed subprocess security vulnerabilities
- Refactored yt.sh to reduce code repetition
- Added comprehensive error handling
- Created configuration examples

## Support

For issues not covered here:

1. **yt-dlp issues:** https://github.com/yt-dlp/yt-dlp/issues
2. **Project issues:** https://github.com/karol-preiskorn/YouTubeDL/issues
3. **Check yt-dlp logs** with `--verbose` flag

## Useful Commands

```bash
# Check yt-dlp version
yt-dlp --version

# Update yt-dlp
sudo yt-dlp -U

# Test URL without downloading
yt-dlp --simulate '<url>'

# Get video info
yt-dlp --print-json '<url>'

# Download with verbose output
yt-dlp --verbose '<url>'
```
