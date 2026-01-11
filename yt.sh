#!/usr/bin/env bash
#
# PROGRAM: yt.sh
#
# PRE-INSTALATION:
#
#  - apt install yt-dlp
#  - sudo apt install ffmpeg
#
# TEST:
# - https://www.youtube.com/watch?v=GxrPn7qwt6c
#

# More safety, by turning some bugs into errors.
set -o errexit -o pipefail -o noclobber -o nounset

v_date=$(date +"%Y-%m-%d")

START=$(date +%s)

RED='\033[7;49;31m'
NC='\033[0m'
BLUE='\033[0;49;36m'
VIOLET='\033[35;49m'
GREY='\033[37;2m'

print_progress() {
	END=$(date +%s)
	lv_diff=$((END - START))
	lv_diff_d=$((lv_diff / (3600 * 24)))
	lv_diff_h=$((lv_diff / 3600 % 24))
	lv_diff_m=$((lv_diff / 60 % 60))
	lv_diff_s=$((lv_diff % 60))
	echo -en "${BLUE}[yt.sh]${NC} ${lv_diff_h}h:${lv_diff_m}m:${lv_diff_s}s -  $1"
}

print_info() {
	if [ "$#" -ne 1 ]; then
		print_error "${RED}Illegal number of parameters f. print_info().${NC}"
		exit 1
	fi
	TXT_COLOR="${GREY}${1}${NC} "
	echo -en "${TXT_COLOR}"
}

print_error() {
	if [ "$#" -ne 1 ]; then
		print_error "${RED}Illegal number of parameters f. print_error().${NC}"
		exit 1
	fi
	TXT_COLOR="${RED}${1}${NC} "
	echo -en "${TXT_COLOR}"
}

print_debug() {
	if [ "$#" -ne 1 ]; then
		print_error "${VIOLET}Illegal number of parameters f. print_debug().${NC}"
		exit 1
	fi
	TXT_COLOR="${VIOLET}${1}${NC} "
	echo -e "${TXT_COLOR}"
}

# Function to create README.md files in download folders
create_folder_readme() {
	local folder_path="$1"
	local format="$2"
	
	if [ ! -d "$folder_path" ]; then
		return
	fi
	
	local readme_file="$folder_path/README.md"
	local info_json_file
	
	# Find the first .info.json file to extract metadata
	info_json_file=$(find "$folder_path" -name "*.info.json" -type f | head -1)
	
	if [ -z "$info_json_file" ]; then
		return
	fi
	
	print_progress "Creating README.md in $folder_path"
	
	# Extract metadata using Python (more reliable than jq)
	local channel_name uploader_id channel_id channel_url
	local playlist_title playlist_id playlist_count upload_date
	
	channel_name=$(python3 -c "import json, sys; data=json.load(open('$info_json_file')); print(data.get('channel', data.get('uploader', 'Unknown')))" 2>/dev/null || echo "Unknown")
	uploader_id=$(python3 -c "import json, sys; data=json.load(open('$info_json_file')); print(data.get('uploader_id', data.get('channel_id', '')))" 2>/dev/null || echo "")
	channel_id=$(python3 -c "import json, sys; data=json.load(open('$info_json_file')); print(data.get('channel_id', ''))" 2>/dev/null || echo "")
	channel_url=$(python3 -c "import json, sys; data=json.load(open('$info_json_file')); print(data.get('channel_url', data.get('uploader_url', '')))" 2>/dev/null || echo "")
	playlist_title=$(python3 -c "import json, sys; data=json.load(open('$info_json_file')); print(data.get('playlist_title', ''))" 2>/dev/null || echo "")
	playlist_id=$(python3 -c "import json, sys; data=json.load(open('$info_json_file')); print(data.get('playlist_id', ''))" 2>/dev/null || echo "")
	upload_date=$(python3 -c "import json, sys; data=json.load(open('$info_json_file')); print(data.get('upload_date', ''))" 2>/dev/null || echo "")
	
	# Format upload date if available
	if [ -n "$upload_date" ] && [ ${#upload_date} -eq 8 ]; then
		upload_date="${upload_date:0:4}-${upload_date:4:2}-${upload_date:6:2}"
	fi
	
	# Create README.md
	cat > "$readme_file" << EOF
# $channel_name

## Channel Information

- **Channel Name:** $channel_name
- **Channel ID:** ${channel_id:-N/A}
- **Uploader ID:** ${uploader_id:-N/A}
$([ -n "$channel_url" ] && echo "- **Channel URL:** $channel_url")
$([ -n "$upload_date" ] && echo "- **Upload Date:** $upload_date")

$(if [ -n "$playlist_title" ]; then
echo "## Playlist Information

- **Playlist:** $playlist_title
- **Playlist ID:** ${playlist_id:-N/A}"
fi)

## Downloaded Files

$(if [ "$format" = "mkv" ]; then
echo "### Video Files"
find "$folder_path" -name "*.mp4" -o -name "*.mkv" | sort | while read file; do
	filename=$(basename "$file")
	filesize=$(du -h "$file" 2>/dev/null | cut -f1 || echo "Unknown")
	echo "- **$filename** ($filesize)"
done
echo ""
echo "### Subtitles"
find "$folder_path" -name "*.srt" -o -name "*.vtt" | sort | while read file; do
	filename=$(basename "$file")
	echo "- $filename"
done
else
echo "### Audio Files"
find "$folder_path" -name "*.mp3" -o -name "*.m4a" -o -name "*.ogg" | sort | while read file; do
	filename=$(basename "$file")
	filesize=$(du -h "$file" 2>/dev/null | cut -f1 || echo "Unknown")
	echo "- **$filename** ($filesize)"
done
fi)

## Additional Files

### Metadata
$(find "$folder_path" -name "*.info.json" | sort | while read file; do
	filename=$(basename "$file")
	echo "- $filename (Complete metadata)"
done)

### Descriptions
$(find "$folder_path" -name "*.description" | sort | while read file; do
	filename=$(basename "$file")
	echo "- $filename (Video description)"
done)

### Thumbnails
$(find "$folder_path" -name "*.webp" -o -name "*.jpg" -o -name "*.png" | sort | while read file; do
	filename=$(basename "$file")
	echo "- $filename"
done)

---

*Generated on $(date) by [YouTubeDL](https://github.com/karol-preiskorn/YouTubeDL)*
EOF
	
	print_progress "README.md created in $folder_path"
}

# Check if yt-dlp is installed - prefer /usr/local/bin (latest) over /usr/bin (apt)
YTDLP_CMD=""
if [ -f "/usr/local/bin/yt-dlp" ]; then
    YTDLP_CMD="/usr/local/bin/yt-dlp"
    print_progress "Using yt-dlp from /usr/local/bin ($(${YTDLP_CMD} --version))"
elif command -v yt-dlp &> /dev/null; then
    YTDLP_CMD="yt-dlp"
    print_progress "Using yt-dlp from PATH ($(${YTDLP_CMD} --version))"
else
    print_error "yt-dlp not found. Please install it with: sudo curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o /usr/local/bin/yt-dlp && sudo chmod a+rx /usr/local/bin/yt-dlp"
    exit 1
fi

# Common options with comprehensive metadata
COMMON_OPTS="--restrict-filenames --add-metadata --write-description --write-info-json --embed-chapters"
PLAYLIST_OPTS="--verbose --sleep-interval 10 --max-sleep-interval 30 --ignore-errors"
# Network and retry options to handle 503 errors - add throttling to avoid rate limits
NETWORK_OPTS="--retries 20 --fragment-retries 20 --retry-sleep 5 --file-access-retries 10 --throttled-rate 1M"
# Extractor args to help with 403/503 errors - use android client which is more reliable
EXTRACTOR_ARGS="--extractor-args youtube:player_client=android"

regex='(https?|ftp|file)://[-[:alnum:]\+&@#/%?=~_|!:,.;]*[-[:alnum:]\+&@#/%=~_|]'

usage() {
	echo -e ""
	echo -e "Usage: yt.sh -u <yt url> -o [mp3|mkv]"
	echo -e ""
	echo -e "Options:"
	echo -e "  -u <url>    YouTube video or playlist URL"
	echo -e "  -o <format> Output format (mp3 for audio, mkv for video)"
	echo -e ""
	echo -e "PRE-RUN:"
	echo -e "  - sudo apt install yt-dlp"
	echo -e "  - sudo apt install ffmpeg"
	echo -e ""
	echo -e "Examples:"
	echo -e "  Single video to mp3:"
	echo -e "    ./yt.sh -u 'https://www.youtube.com/watch?v=GxrPn7qwt6c' -o mp3"
	echo -e "  Single video to mkv:"
	echo -e "    ./yt.sh -u 'https://www.youtube.com/watch?v=GxrPn7qwt6c' -o mkv"
	echo -e "  Playlist to mp3:"
	echo -e "    ./yt.sh -u 'https://www.youtube.com/playlist?list=PLxxxxxx' -o mp3"
	echo -e ""
	exit 1
}
u=""
o=""
while getopts "u:o:" opt; do
	case "${opt}" in
		u)
			u=${OPTARG}
			if [[ $u =~ $regex ]]
			then
				echo "Oki use URL: ${u}"
			else
				usage
			fi
			;;
		o)
			o=${OPTARG}
			echo "Option audio specified ${o}."
			;;
		*)
			usage
			;;
	esac

done

shift $((OPTIND-1))

# echo "url = ${u}"
# echo "out audio => ${o}"

if [ -z "${u}" ] || [ -z "${o}" ]; then
   usage
fi

# Validate output format
if [[ "${o}" != "mp3" && "${o}" != "mkv" ]]; then
	print_error "Invalid output format: ${o}. Must be 'mp3' or 'mkv'"
	usage
fi

# Detect URL type
if [[ "${u}" =~ ^https://(www\.)?youtube\.com/playlist\?list=.* ]]; then
	IS_PLAYLIST=true
	print_progress "Detected YouTube playlist"
elif [[ "${u}" =~ ^https://(www\.)?youtube\.com/watch\?.*v=([a-zA-Z0-9-]+).* ]]; then
	IS_PLAYLIST=false
	print_progress "Detected YouTube video"
else
	print_error "[error] URL ${u} is not a valid YouTube video or playlist."
	exit 1
fi

# Download based on type and format
if [ "${IS_PLAYLIST}" = true ]; then
	if [ "${o}" = "mkv" ]; then
		print_progress "Downloading playlist as mkv files"
		${YTDLP_CMD} -f '(bestvideo[height<=640]+bestaudio)/best[height<=640]' \
			${PLAYLIST_OPTS} ${COMMON_OPTS} ${NETWORK_OPTS} ${EXTRACTOR_ARGS} \
			--merge-output-format mkv \
			--embed-thumbnail --write-subs --embed-subs --sub-langs "en.*,en" \
			--output "video/%(uploader)s/%(playlist)s/%(playlist_index)s - %(title)s.%(ext)s" \
			"${u}"
	elif [ "${o}" = "mp3" ]; then
		print_progress "Downloading playlist as mp3 files"
		${YTDLP_CMD} ${PLAYLIST_OPTS} ${COMMON_OPTS} ${NETWORK_OPTS} ${EXTRACTOR_ARGS} \
			--audio-format mp3 --format bestaudio --extract-audio --audio-quality 0 \
			--embed-thumbnail \
			--output "audio/%(uploader)s/%(playlist)s/%(playlist_index)s - %(title)s.%(ext)s" \
			"${u}"
	fi
else
	if [ "${o}" = "mkv" ]; then
		print_progress "Downloading video as mkv file"
		${YTDLP_CMD} -f '(bestvideo[height<=640]+bestaudio)/best[height<=640]' \
			${COMMON_OPTS} ${NETWORK_OPTS} ${EXTRACTOR_ARGS} \
			--merge-output-format mkv \
			--embed-thumbnail --write-subs --embed-subs --sub-langs "en.*,en" \
			--output "video/%(uploader)s/%(title)s.%(ext)s" \
			"${u}"
	elif [ "${o}" = "mp3" ]; then
		print_progress "Downloading video as mp3 file"
		${YTDLP_CMD} ${COMMON_OPTS} ${NETWORK_OPTS} ${EXTRACTOR_ARGS} \
			--audio-format mp3 --extract-audio --audio-quality 0 \
			--embed-thumbnail \
			--output "audio/%(uploader)s/%(title)s.%(ext)s" \
			"${u}"
	fi
fi

print_progress "Finish download ${u} from YT"

# Create README.md files in download folders
if [ "${IS_PLAYLIST}" = true ]; then
	if [ "${o}" = "mkv" ]; then
		# For playlists, create README in each uploader/playlist folder
		find video -mindepth 2 -maxdepth 2 -type d -name "*" 2>/dev/null | while read folder; do
			create_folder_readme "$folder" "mkv"
		done
	elif [ "${o}" = "mp3" ]; then
		find audio -mindepth 2 -maxdepth 2 -type d -name "*" 2>/dev/null | while read folder; do
			create_folder_readme "$folder" "mp3"
		done
	fi
else
	if [ "${o}" = "mkv" ]; then
		# For single videos, create README in uploader folder
		find video -mindepth 1 -maxdepth 1 -type d -name "*" 2>/dev/null | while read folder; do
			create_folder_readme "$folder" "mkv"
		done
	elif [ "${o}" = "mp3" ]; then
		find audio -mindepth 1 -maxdepth 1 -type d -name "*" 2>/dev/null | while read folder; do
			create_folder_readme "$folder" "mp3"
		done
	fi
fi

print_progress "README.md files created"
