#! /bin/bash
# return display brightness to full

echo 'brightness.sh'

xrandr --output $PRIMARY_DISPLAY --brightness 1
xrandr --output $SECONDARY_DISPLAY --brightness .15
#i3-msg workspace 1
