#!/usr/bin/env bash
# Clips public-domain horror films from Wikimedia Commons into small looping MP4s.
cd "$(dirname "$0")/assets/video"
W=https://upload.wikimedia.org/wikipedia/commons/transcoded
enc() { # url start dur out keepaudio
  local A="-an"; [ "$5" = "1" ] && A="-c:a aac -b:a 96k"
  ffmpeg -loglevel error -y -ss "$2" -i "$1" -t "$3" -vf "scale=640:-2,fps=24" -c:v libx264 -preset veryfast -crf 28 -pix_fmt yuv420p -movflags +faststart $A "$4" && echo "ok $4" || echo "FAIL $4"
}
enc "$W/e/ee/Night_Of_The_Living_Dead_%281968%29_-_trailer.webm/Night_Of_The_Living_Dead_%281968%29_-_trailer.webm.360p.mpeg4.mov" 0 150 cinema_notld_trailer.mp4 1 &
enc "$W/2/2e/Night_of_the_Living_Dead_-_Ten_Minutes_to_Three.webm/Night_of_the_Living_Dead_-_Ten_Minutes_to_Three.webm.360p.mpeg4.mov" 0 120 tv_notld_scene.mp4 0 &
enc "$W/0/02/Nosferatu_%281922%2C_English_titles_1947%29.webm/Nosferatu_%281922%2C_English_titles_1947%29.webm.360p.mpeg4.mov" 4700 120 tv_nosferatu.mp4 0 &
enc "$W/5/57/The_Cabinet_of_Dr._Caligari.webm/The_Cabinet_of_Dr._Caligari.webm.360p.mpeg4.mov" 1500 90 tv_caligari.mp4 0 &
wait
rm -f search_*.json
ls -la
