ffmpeg -y -f lavfi -i "color=color=black@0.0:size=1920x1080,format=rgba,subtitles=subtitle.ass:alpha=1" -r 23.976 -c:v png -t "00:02:46" subtitle.mov -stats
