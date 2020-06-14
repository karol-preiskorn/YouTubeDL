# 
# 
# --recode-video mkv
# --audio-format best
# -- 
# test: https://www.youtube.com/watch?v=GxrPn7qwt6c

youtube-dl --ignore-errors --recode-video mkv --format '(mp4,webm)[height<480]+bestaudio' --restrict-filenames --embed-thumbnail --add-metadata --output "%(title)s.%(ext)s" $1
