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


FILE=/usr/bin/yt-dlp

usage() {
	echo -e ""
	echo -e "Usage: yt.sh -a <yt url> -o [mp3|mkv]"
	echo -e
	echo -e "PRE-RUN:"
	echo -e " - sudo apt install yt-dlp"
	echo -e " - sudo apt install ffmpeg"
	echo -e ""
	echo -e "TEST:"
	echo -e " - ./yt.sh https://www.youtube.com/watch?v=GxrPn7qwt6c"
	echo -e ""
	exit 1
}

regex='(https?|ftp|file)://[-[:alnum:]\+&@#/%?=~_|!:,.;]*[-[:alnum:]\+&@#/%=~_|]'
#usage() { echo "Usage: $0 [-s <45|90>] [-p <string>]" 1>&2; exit 1; }
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

if [[ "${u}" =~ ^https://(www\.)?youtube\.com/watch\?.*v=([a-zA-Z0-9-]+).* && "${o}" == "mkv" ]]; then
	print_progress "Link ${u} from YT convert to mkv single file."
	$FILE -f 'bestvideo[height<=640]+bestaudio/best[height<=640]' --restrict-filenames --add-metadata --merge-output-format mkv --output "video/%(title)s.%(ext)s" "${u}"
elif [[ "${u}" =~ ^https://(www\.)?youtube\.com/watch\?.*v=([a-zA-Z0-9-]+).* && "${o}" == "mp3" ]]; then
	print_progress "Link ${u} from YT convert to mp3 single file."
	$FILE --audio-format mp3 --extract-audio --audio-quality 0 --restrict-filenames --add-metadata --embed-thumbnail --output "audio/%(title)s.%(ext)s" "${u}"
elif [[ "${u}" =~ ^https://(www\.)?youtube\.com/playlist\?list=.* && $o == "mkv" ]]; then
	print_progress "Link ${u} playlist from YT convert to mkv${NC}"
	$FILE -f 'bestvideo[height<=640]+bestaudio/best[height<=640]' --verbose --sleep-interval 20 --max-sleep-interval 60 --ignore-errors --restrict-filenames --add-metadata --merge-output-format mkv --output "video/%(playlist)s/%(playlist_index)s - %(title)s.%(ext)s" "${u}"
elif [[ "${u}" =~ ^https://(www\.)?youtube\.com/playlist\?list=.* && $o == "mp3" ]]; then
	print_progress "Link ${u} playlist from YT convert to mp3"
	$FILE --ignore-errors --audio-format mp3 --format bestaudio --extract-audio --audio-quality 0 --sleep-interval 20 --max-sleep-interval 60 --restrict-filenames --add-metadata --embed-thumbnail --output "audio/%(playlist)s/%(playlist_index)s - %(title)s.%(ext)s" "${u}"
elif [[ ${u} =~ ^https://(www\.)?youtube\.com/watch\?.*v=([a-zA-Z0-9-]+).* && $o = "mp3" ]]; then
	print_progress "Link ${u} video from YT convert to mp3"
	$FILE --ignore-errors --audio-format mp3 --format bestaudio --extract-audio --audio-quality 0 --restrict-filenames --add-metadata --embed-thumbnail --output "%(playlist)s/%(playlist_index)s - %(title)s.%(ext)s" "${u}"
else
	print_error "[error] in call $0 link ${u} *NOT* from YT video or playlist."
	exit 1
fi

print_progress "Finish download ${u} from YT"
