#!/bin/bash

# based on https://gist.github.com/yellowled/1439610
IN=$1
OUT=$(echo $1 | sed 's/^\(.*\)\.[a-zA-Z0-9]*$/\1/')

# webm
#ffmpeg -i $IN -f webm -vcodec libvpx -acodec libvorbis -ab 128000 -crf 22 -s 640x360 $OUT.webm

# mp4
#ffmpeg -i $IN -acodec aac -strict experimental -ac 2 -ab 128k -vcodec libx264 -vpre slow -f mp4 -crf 22 -s 640x360 $OUT.mp4
ffmpeg -i $IN -acodec aac -strict experimental -ac 2 -ab 128k -vcodec libx264  -f mp4 -crf 22 -s 640x360 $OUT.mp4

# ogg (if you want to support older Firefox)
#ffmpeg2theora $IN -o $OUT.ogv -x 640 -y 360 --videoquality 5 --audioquality 0  --frontend