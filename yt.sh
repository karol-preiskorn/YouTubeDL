youtube-dl --ignore-errors --format bestaudio --extract-audio --audio-format mp3 --audio-quality 360K --restrict-filenames --embed-thumbnail --add-metadata --output "%(title)s.%(ext)s" $1
