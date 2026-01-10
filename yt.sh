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

# Check if yt-dlp is installed
if ! command -v yt-dlp &> /dev/null; then
    print_error "yt-dlp not found. Please install it with: sudo apt install yt-dlp"
    exit 1
fi

# Common options
COMMON_OPTS="--restrict-filenames --add-metadata"
PLAYLIST_OPTS="--verbose --sleep-interval 10 --max-sleep-interval 30 --ignore-errors"

# Check if yt-dlp is installed
if ! command -v yt-dlp &> /dev/null; then
    print_error "yt-dlp not found. Please install it with: sudo apt install yt-dlp"
    exit 1
fi

# Common options
COMMON_OPTS="--restrict-filenames --add-metadata"
PLAYLIST_OPTS="--verbose --sleep-interval 10 --max-sleep-interval 30 --ignore-errors"

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
		yt-dlp -f 'bestvideo[height<=640]+bestaudio/best[height<=640]' \
			${PLAYLIST_OPTS} ${COMMON_OPTS} \
			--merge-output-format mkv \
			--output "video/%(playlist)s/%(playlist_index)s - %(title)s.%(ext)s" \
			"${u}"
	elif [ "${o}" = "mp3" ]; then
		print_progress "Downloading playlist as mp3 files"
		yt-dlp ${PLAYLIST_OPTS} ${COMMON_OPTS} \
			--audio-format mp3 --format bestaudio --extract-audio --audio-quality 0 \
			--embed-thumbnail \
			--output "audio/%(playlist)s/%(playlist_index)s - %(title)s.%(ext)s" \
			"${u}"
	fi
else
	if [ "${o}" = "mkv" ]; then
		print_progress "Downloading video as mkv file"
		yt-dlp -f 'bestvideo[height<=640]+bestaudio/best[height<=640]' \
			${COMMON_OPTS} \
			--merge-output-format mkv \
			--output "video/%(title)s.%(ext)s" \
			"${u}"
	elif [ "${o}" = "mp3" ]; then
		print_progress "Downloading video as mp3 file"
		yt-dlp ${COMMON_OPTS} \
			--audio-format mp3 --extract-audio --audio-quality 0 \
			--embed-thumbnail \
			--output "audio/%(title)s.%(ext)s" \
			"${u}"
	fi
fi

print_progress "Finish download ${u} from YT"
