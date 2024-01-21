#!/usr/bin/env bash
## This is a simple CPU/GPU/SSD temperature monitor
# Requires pcregrep: sudo apt install pcregrep -y
CORE_TEMP=$(vcgencmd measure_temp | pcregrep -o1 "temp=(.*)")
SSD_TEMP=$(sudo sudo smartctl -a /dev/sda | pcregrep -o1 "Temperature:\s*(\d*)")
printf "core temperature:\t%s\n" "$CORE_TEMP"
printf "ssd temperature:\t%s\n" "$SSD_TEMP"
