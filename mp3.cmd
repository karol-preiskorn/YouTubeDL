#bash!
for f in *.m4a ; do /cygdrive/d/Utils/ffmpeg-20170520/bin/ffmpeg -i "$f" -acodec libmp3lame -ab 320k "${f%.*}.mp3"; done