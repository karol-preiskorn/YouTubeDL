#!/usr/bin/env bash
#
# PROGRAM: yt-video.sh
#
# INSTALATION:
# - install youtube-dl from ```sudo curl -L https://yt-dl.org/downloads/latest/youtube-dl -o /usr/local/bin/youtube-dl && sudo chmod a+rx /usr/local/bin/youtube-dl````
# - source: https://github.com/ytdl-org/youtube-dl
# - ```sudo apt install ffmpeg```
#
# TEST:
# - https://www.youtube.com/watch?v=GxrPn7qwt6c

v_date=$(date +"%Y-%m-%d")

RED='\033[7;49;31m'
NC='\033[0m'
BLUE='\033[0;49;36m'
VIOLET='\033[35;49m'
GREY='\033[37;2m'

START=$(date +%s)

print_progress() {

	END=$(date +%s)

	lv_diff=$((END - START))
	lv_diff_d=$((lv_diff / (3600 * 24)))
	lv_diff_h=$((lv_diff / 3600 % 24))
	lv_diff_m=$((lv_diff / 60 % 60))
	lv_diff_s=$((lv_diff % 60))

	echo -e "${BLUE}[progress] ${lv_diff_d} days ${lv_diff_h}h:${lv_diff_m}m:${lv_diff_s}s  -  $1${NC}"
}

print_info() {
	if [ "$#" -ne 1 ]; then
		print_error "${RED}Illegal number of parameters f. print_info${NC}"
		exit 1
	fi
	TXT_COLOR="${GREY}${1}${NC} "
	echo -e "${TXT_COLOR}"
}

print_error() {
	if [ "$#" -ne 1 ]; then
		print_error "${RED}Illegal number of parameters f. print_info${NC}"
		exit 1
	fi
	TXT_COLOR="${RED}${1}${NC} "
	echo -e "${TXT_COLOR}"
}

print_debug() {
	if [ "$#" -ne 1 ]; then
		print_error "Illegal number of parameters f. print_info${NC}"
		exit 1
	fi
	TXT_COLOR="${VIOLET}${1}${NC} "
	echo -e "${TXT_COLOR}"
}

# Check that there are at least two arguments given in a bash script
if (($# < 1)); then
	echo -en "$0 need at last one parameter from youtube video or playlist"
	echo -en "       - second parametr $0 is oprional describe format output [mp3|flac|mkv]."
	exit 1
fi

FILE=/usr/bin/youtube-dl

if [ ! -x "$FILE" ]; then
	print_error "This $FILE is not exist please install"
	exit 1
fi

if [[ $1 =~ ^https://(www\.)?youtube\.com/watch\?.*v=([a-zA-Z0-9-]+).* ]] && [ "$#" -eq 1 ]; then

	print_progress "Link $1 from YT convert to mkv & mp3."

	$FILE -f 'bestvideo[height<=640]+bestaudio/best[height<=640]' --restrict-filenames --add-metadata --merge-output-format mkv --output "%(title)s.%(ext)s" "$1"
	$FILE --format bestaudio --extract-audio --audio-quality 0 --restrict-filenames --add-metadata --embed-thumbnail --output "%(title)s.%(ext)s" "$1"

elif [[ $1 =~ ^https://(www\.)?youtube\.com/playlist\?list=.* ]] && [ "$#" -eq 1 ]; then

	print_progress "Link $1 playlist from YT convert to mkv${NC}"

	$FILE -f 'bestvideo[height<=640]+bestaudio/best[height<=640]' --verbose --sleep-interval 5 --max-sleep-interval 12 --ignore-errors --restrict-filenames --add-metadata --merge-output-format mkv --output "%(playlist)s/%(playlist_index)s - %(title)s.%(ext)s" "$1"

elif [[ $1 =~ ^https://(www\.)?youtube\.com/playlist\?list=.* && $2 = "mp3" ]] && [ "$#" -eq 2 ]; then

	print_progress "Link $1 playlist from YT convert to mp3"

	$FILE --ignore-errors --audio-format mp3 --format bestaudio --extract-audio --audio-quality 0 --restrict-filenames --add-metadata --embed-thumbnail --output "%(playlist)s/%(playlist_index)s - %(title)s.%(ext)s" "$1"

elif [[ $1 =~ ^https://(www\.)?youtube\.com/watch\?.*v=([a-zA-Z0-9-]+).* && $2 = "mp3" ]] && [ "$#" -eq 2 ]; then

	print_progress "Link $1 video from YT convert to mp3"

	$FILE --ignore-errors --audio-format mp3 --format bestaudio --extract-audio --audio-quality 0 --restrict-filenames --add-metadata --embed-thumbnail --output "%(playlist)s/%(playlist_index)s - %(title)s.%(ext)s" "$1"

else
	print_error "[error] in call $0 link $1 *NOT* from YT video or playlist"
	exit 1
fi

print_progress "Finish download $1 from YT"
