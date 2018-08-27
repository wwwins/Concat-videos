#!/bin/sh
#
# Copyright 2018 isobar. All Rights Reserved.
#
# Usage:
#       ./segment.sh base.h264 base-1
#
echo '>>>>>Start segmenting videos<<<<<'

if [ -z "$1" ] 
  then
    echo "Usage:\n      ./segemnt.sh base.h264 base-1"
    exit 1
fi

folder=~/intel-8th/data/
src=$1
seg=$2-%03d.h264

cd $folder
ffmpeg -i $src -segment_time 2 -g 60 -sc_threshold 0 -force_key_frames "expr:gte(t,n_forced*60)" -f segment -strict -2 -preset veryfast $seg 

