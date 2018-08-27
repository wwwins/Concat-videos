#!/bin/sh
#
# Copyright 2018 isobar. All Rights Reserved.
#
# Usage:
#       ./get-raw-video.sh
#
echo '>>>>>Start extracting raw videos<<<<<'

folder=~/intel-8th/data/
folder30=~/intel-8th/data/fps30/

cd $folder

for f in *.mp4
do
  echo $f."-->".${f%%.*}
  ffmpeg -y -i $f -filter:v "setpts=0.999*PTS" -r 30 fps30/$f
done

cd $folder30
for f in *.mp4
do
#  ffmpeg -i $f -c copy -f h264 -y ${f%%.*}.h264
  ffmpeg -i $f -c copy -bsf:v h264_mp4toannexb -an -f mpegts -y ${f%%.*}.ts
done

mv *.ts $folder
