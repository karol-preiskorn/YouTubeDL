# yt-video.sh
#
# Prerequsition:
#
# - install youtube-dl from ```sudo curl -L https://yt-dl.org/downloads/latest/youtube-dl -o /usr/local/bin/youtube-dl && sudo chmod a+rx /usr/local/bin/youtube-dl````
# - source: https://github.com/ytdl-org/youtube-dl
# - ```sudo apt install ffmpeg```
#
# test: https://www.youtube.com/watch?v=GxrPn7qwt6c

RED="\033[97;45m"
NC="\033[0m" # No Color
BLUE="\033[30;106m"
GREEN="\033[1;37;42m"

# Check that there are at least two arguments given in a bash script
if (( $# < 1 )); then
    echo -en "${RED}yt-video.sh need at last one parameter{NC}"
    exit 1
fi

# todo check -> created folder 'download' (or create it) downaload there all videos
# todo check ffmpeg instaled?
# todo chceck python3 is isnstalled?

FILE=/usr/local/bin/youtube-dl

if [ ! -x "$FILE" ]; then
    echo -e "This $FILE is not exist please install"
    exit 1
fi

if [[ $1 =~ ^https://(www\.)?youtube\.com/watch\?.*v=([a-zA-Z0-9-]+).* ]]; then
    echo -e "${RED}Link $1 from YT convert to mkv & mp3${NC}"
    /usr/local/bin/youtube-dl --format '(mp4)[height<=480]+bestaudio' --restrict-filenames --add-metadata --merge-output-format mkv --output "%(title)s.%(ext)s" $1
    /usr/local/bin/youtube-dl --format bestaudio --extract-audio --audio-quality 0 --restrict-filenames --add-metadata --output "%(title)s.%(ext)s" $1

elif [[ $1 =~ ^https://(www\.)?youtube\.com/playlist\?list=.* ]]; then
    echo -e "${RED}Link $1 playlist from YT convert to mkv${NC}"
    /usr/local/bin/youtube-dl --format '(mp4)[height<=480]+bestaudio' --sleep-interval 5 --ignore-errors  --restrict-filenames --add-metadata --merge-output-format mkv --output "%(playlist)s/%(playlist_index)s - %(title)s.%(ext)s" $1

elif [[ $1 =~ ^https://(www\.)?youtube\.com/playlist\?list=.* && $2 = "mp3" ]]; then
    echo -e "${RED}Link $1 playlist from YT convert to mp3${NC}"
    /usr/local/bin/youtube-dl --ignore-errors --audio-format mp3 --format bestaudio --extract-audio --audio-quality 0 --restrict-filenames --add-metadata --embed-thumbnail --output "%(playlist)s/%(playlist_index)s - %(title)s.%(ext)s" $1

else
    echo -e "${RED}Link $1 *NOT* from YT${NC}"
    exit 1
fi


# Videos can be filtered by their upload date using the options --date, --datebefore or --dateafter. They accept dates in two formats:

#     Absolute dates: Dates in the format YYYYMMDD.
#     Relative dates: Dates in the format (now|today)[+-][0-9](day|week|month|year)(s)?


# Download playlist
# youtube-dl -ict --yes-playlist --extract-audio --audio-format mp3 --audio-quality 0 https://www.youtube.com/playlist?list=UUCvVpbYRgYjMN7mG7qQN0Pg

# Download playlist, --download-archive downloaded.txt add successfully downloaded files into downloaded.txt
# youtube-dl --download-archive downloaded.txt --no-overwrites -ict --yes-playlist --extract-audio --audio-format mp3 --audio-quality 0 --socket-timeout 5 https://www.youtube.com/playlist?list=UUCvVpbYRgYjMN7mG7qQN0Pg

# Retry until success, no -i option
# while ! youtube-dl --download-archive downloaded.txt --no-overwrites -ct --yes-playlist --extract-audio --audio-format mp3 --audio-quality 0 --socket-timeout 5 <YT_PlayList_URL>; do echo DISCONNECTED; sleep 5; done
