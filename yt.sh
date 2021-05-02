# yt-video.sh
# =================================================
# --recode-video mkv
# --audio-format best
# -- 
# test: https://www.youtube.com/watch?v=GxrPn7qwt6c


# Check that there are at least two arguments given in a bash script
if (( $# < 1 )); then
    echo 'yt-video.sh need at last one parameter'
    exit 1
fi


FILE=/usr/local/bin/youtube-dl
if [ ! -x "$FILE" ]; then
    echo "This $FILE is not exist please install"
    exit 1
fi

if [[ $1 =~ ^https://(www\.)?youtube\.com/watch\?.*v=([a-zA-Z0-9-]+).* ]]; then
    echo "Link $1 from YT convert to mkv & mp3"
    youtube-dl --format '(mp4)[height<=480]+bestaudio' --restrict-filenames --add-metadata --merge-output-format mkv --output "%(title)s.%(ext)s" $1
    youtube-dl --format bestaudio --extract-audio --audio-quality 0 --restrict-filenames --add-metadata --output "%(title)s.%(ext)s" $1
elif [[ $1 =~ ^https://(www\.)?youtube\.com/playlist\?list=.* ]]; then
    echo "Link $1 playlist from YT convert to mkv"
    youtube-dl --ignore-errors --dateafter 20200501 --format '(mp4)[height<=480]+bestaudio' --restrict-filenames --add-metadata --merge-output-format mkv --output "%(playlist)s/%(playlist_index)s - %(title)s.%(ext)s" $1
elif [[ $1 =~ ^https://(www\.)?youtube\.com/playlist\?list=.* ]]; then
    echo "Link $1 playlist from YT convert to mp3"
    youtube-dl --ignore-errors --audio-format mp3 --format bestaudio --extract-audio --audio-quality 0 --restrict-filenames --add-metadata --embed-thumbnail --output "%(playlist)s/%(playlist_index)s - %(title)s.%(ext)s" $1
else
    echo "Link $1 *NOT* from YT"
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