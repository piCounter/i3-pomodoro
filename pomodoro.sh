#! /bin/bash
# turn off display for 5 minutes every 25 minutes

# User Configs
REPO_PATH=$HOME/code/i3-pomo
source $REPO_PATH/etc/*.conf

#system
SELF="$(basename "$0")"
PID_OF_SELF=$(pgrep -f "$SELF")
function verbose {
	if [[ $VERBOSE = 'true' ]]; then
		echo "$@"
	fi
}

#time
function min_to_sec {
	TIME=$1
	echo $(qalc -t ${TIME}*60)
	exit 0
}
STUDYTIME_SECONDS=$(min_to_sec $STUDYTIME_MINUTES)
BREAKTIME_SECONDS="$(min_to_sec $BREAKTIME_MINUTES)"
verbose study_min $STUDYTIME_MINUTES = $STUDYTIME_SECONDS seconds
verbose break_min $BREAKTIME_MINUTES = $BREAKTIME_SECONDS seconds
function next_second {
	TIME=$1
	sleep 1
	echo $((${TIME}-1))
	exit 0
}

# UI
function start_studytime {
	cmus-remote -U
	xrandr --output HDMI-A-0 --brightness 1
	echo $STUDYTIME_SECONDS
	exit 0
}

function start_breaktime {
	cmus-remote -p
	xrandr --output HDMI-A-0 --brightness .05
	echo $BREAKTIME_SECONDS
	exit 0
}

trap "snooze 300" SIGUSR1

function snooze {
	TIME=$1
	verbose 'time extended by' $TIME
#	let COUNT=COUNT+5*60 # Increase time by 5 minutes
	COUNT=$((${COUNT}+${TIME}))
}

function warningbar {
	i3-nagbar -m 'Break WILL begin in 1 minute' \
		-t warning \
		-B "EMERGENCY STOP" "kill $PID_OF_SELF && killall i3-nagbar 2> /dev/null" \
		-B "WAAIIITTTT..... I need 5 more minutes" "pkill -USR1 -f $SELF"
}

# Runtime
MODE='study'
COUNT="$(start_studytime)"
while true; do
	verbose $MODE $COUNT
	if [[ $COUNT = '' ]]; then
		exit 1;
	fi
	if [ $MODE = 'study' ]; then
		if [[ $COUNT -eq $BREAKTIME_WARNING_SECONDS ]]; then
			warningbar &
		fi
		if [[ $COUNT -eq '0' ]]; then
			MODE='break'
			COUNT=$(start_breaktime)
		fi
	fi
	if [ $MODE = 'break' ]; then
		if [[ $COUNT -eq '0' ]]; then
			MODE='study'
			COUNT=$(start_studytime)
		fi
	fi
	COUNT=$(next_second $COUNT)
done




