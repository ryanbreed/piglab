#!/bin/bash
PCAP=$1
FILTER=$2
tshark -r "$PCAP" -2 -R "$FILTER" -Y "$FILTER" -T fields -e tcp.stream| sort -n| uniq | while read str; do 
  fname="$(basename $PCAP)"
  outbase="${fname%%.pcap}"
  extracted="${outbase}_stream_$(printf %06d ${str}).txt"
  echo "processing $extracted"
  tshark -r "$PCAP" -2 -R "$FILTER" -Y "$FILTER" -z follow,tcp,ascii,${str} | \
  awk 'BEGIN {RS=""; FS="==================================================================="} {print $2}' >\
  extracts/text/${extracted}
done
