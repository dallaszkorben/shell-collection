#!/bin/bash

if [ $# -ne 3 ]
then
        echo "Usage: $0 channel seconds filename"
        exit
fi

WIDTH=640
HEIGHT=480
MENCODER=/usr/bin/mencoder
AUDIO="-oac mp3lame -lameopts cbr:br=128:mode=3"
VIDEO="-ovc lavc -lavcopts vcodec=mpeg4:vbitrate=6400"
DSP="adevice=/dev/dsp"
TV=" -tv driver=v4l2:width=$WIDTH:height=$HEIGHT:outfmt=yuy2:input=0:device=/dev/video0:norm=PAL:chanlist=us-cable:channel=$1:$DSP"
$MENCODER tv:// $TV $VIDEO $AUDIO -endpos $2 -ffourcc divx -o  "$3.avi"

