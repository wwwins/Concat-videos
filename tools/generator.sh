#!/bin/sh
#
# Copyright 2018 isobar. All Rights Reserved.
#
# Usage:
#       ./generator.sh 01234 pic 
#
echo '>>>>>Starting generating frames'

if [ -z "$1" ]
  then
    echo "Usage:\n      ./generator.sh 12345 pic"
    exit 1
fi

project=~/intel-8th/
data=${project}data
fps=1/2
sno=$1
list=$sno/list
audio=$data/audio.aac

intro=$data/intro.ts
text1=$data/text1.ts
text2=$data/text2.ts
text3=$data/text3.ts
end=$data/end.ts
uts0=$sno/out-1-000.ts
uts1=$sno/out-1-001.ts
uts2=$sno/out-2-000.ts
uts3=$sno/out-2-001.ts

concat_params1="concat:$intro|$uts0|$text1|$uts1|$text2|$uts2|$text3|$uts3|$end"
concat_params2="concat:$intro|$uts0|$text1|$uts1|$text2|$uts2|$text3|$uts3|$end"
concat_params3="concat:$intro|$uts0|$text1|$uts1|$text2|$uts2|$text3|$uts3|$end"
concat_params4="concat:$intro|$uts0|$text1|$uts1|$text2|$uts2|$text3|$uts3|$end"
concat_params5="concat:$intro|$uts0|$text1|$uts1|$text2|$uts2|$text3|$uts3|$end"

src1=$sno-1.mp4
src2=$sno-2.mp4
raw1=$sno/$sno-1.mp4
raw2=$sno/$sno-2.mp4
dst1=$sno/$2-1-%03d.png
dst2=$sno/$2-2-%03d.png
seg1=$sno/out-1-%03d.mp4
seg2=$sno/out-2-%03d.mp4
rawoutput=$sno/output.264
anoutput=$sno/voutput.mp4
output=$sno/output.mp4

echo '>>>>>PARAMS:'$src1 $src2 $dst1 $dst2 $seg1 $seg2 fps=$fps

# create folder
cd ${project}public/
mkdir $sno
# extract raw video
#ffmpeg -i $src1 -c copy -f h264 -y $raw1
#ffmpeg -i $src2 -c copy -f h264 -y $raw2
# capture frames
echo ">>>>>FRAMES"
ffmpeg -hide_banner -i $raw1 -vf fps=$fps -y $dst1
ffmpeg -hide_banner -i $raw2 -vf fps=$fps -y $dst2
# segment videos
echo ">>>>>SEGMENT"
ffmpeg -hide_banner -i $raw1 -segment_time 2 -g 60 -sc_threshold 0 -force_key_frames "expr:gte(t,n_forced*60)" -f segment -preset veryfast $seg1
ffmpeg -hide_banner -i $raw2 -segment_time 2 -g 60 -sc_threshold 0 -force_key_frames "expr:gte(t,n_forced*60)" -f segment -preset veryfast $seg2

# create video list
#cp $data/list1 $list
#sed -i "s/{SNO}/$sno/g" $list
# concat videos
#ffmpeg -f concat -safe 0 -i $list -c copy $rawoutput

# convert ts
echo ">>>>>CONVERT TS"
for f in $sno/out-*.mp4
do
  ffmpeg -hide_banner -i $f -c copy -bsf:v h264_mp4toannexb -an -f mpegts -y ${f%%.*}.ts
done
# merge video and audio
echo ">>>>>MERGE VIDEO"
ffmpeg -hide_banner -i $concat_params1 -c copy -y $anoutput
echo ">>>>>MERGE AUDIO"
ffmpeg -hide_banner -i $anoutput -i $audio -c copy -y $output

echo 'done!!'
