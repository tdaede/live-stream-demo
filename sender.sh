#!/bin/bash

timestamp="$(date +%s)"

FF="ffmpeg"
#OUTPUT="http://xxx/out.mpd"

VCODEC=librav1e
COLOR=bt709

echo "Ingesting to: ${OUTPUT}"

${FF} \
-copyts -probesize 10M \
-i /dev/video0 \
-flags +global_header -r 30000/1001 \
\
-af aresample=async=1 \
\
-pix_fmt yuv420p \
-c:v ${VCODEC} -b:v:0 5000K -s:v:0 480x640 \
-vf transpose=2 \
-speed 10 \
-tiles 32 \
-c:a aac -ar 32000 -b:a:0 96k \
-map 0:v:0 \
-use_timeline 0 \
-frag_type every_frame \
-adaptation_sets "id=0,seg_duration=6,streams=v id=1,seg_duration=6,streams=a" \
-g:v 30 -keyint_min:v 30 -sc_threshold:v 0 -streaming 1 -ldash 1 \
-color_primaries ${COLOR} -color_trc ${COLOR} -colorspace ${COLOR} \
-http_user_agent Akamai_Broadcaster_v1.0 \
-http_persistent 1 \
-media_seg_name "$timestamp"'/chunk-stream_$RepresentationID$-$Number%05d$.$ext$' \
-init_seg_name "$timestamp"'/init-stream$RepresentationID$.$ext$' \
-f dash \
${OUTPUT}
