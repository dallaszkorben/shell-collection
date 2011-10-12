#!/bin/bash

if [ $# -ne 1 ]
then
        echo "Usage: $0 channel"
        exit
fi

WIDTH=640
HEIGHT=480
MPLAYER=/usr/bin/mplayer
DSP="adevice=/dev/dsp"
TV=" -tv driver=v4l2:width=$WIDTH:height=$HEIGHT:outfmt=yuy2:input=0:device=/dev/video0:norm=PAL:chanlist=us-cable:channel=$1:$DSP"
$MPLAYER  tv:// $TV -dumpfile dump.avi

