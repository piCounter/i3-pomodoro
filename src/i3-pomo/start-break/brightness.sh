#! /bin/bash
# Set primary display brightness to almost 0

xrandr --output $PRIMARY_DISPLAY --brightness .05
xrandr --output $SECONDARY_DISPLAY --brightness 1
i3-msg workspace 5
