#!/bin/sh
#
# Copyright 2018 isobar. All Rights Reserved.
#
# Usage:
#       ./segment.sh base.mp4 base-1
#
echo '>>>>>Start segmenting videos<<<<<'

if [ -z "$1" ] 
  then
    echo "Usage:\n      ./segemnt.sh base.mp4 base-1"
    exit 1
fi

folder=~/intel-8th/data/fps29.97-base/
src=$1
src30=fps30-$src
seg=$2-%03d.mp4

cd $folder
ffmpeg -hide_banner -y -i $src -filter:v "setpts=0.999*PTS" -r 30 $src30
ffmpeg -i $src30 -segment_time 2 -g 60 -sc_threshold 0 -force_key_frames "expr:gte(t,n_forced*60)" -f segment -strict -2 -preset veryfast $seg 
mv $2-*.mp4 ../fps30/

echo "\nrunning get-ts-video.sh\n"
