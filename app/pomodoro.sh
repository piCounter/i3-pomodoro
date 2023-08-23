#! /bin/bash
# turn off display for 5 minutes every 25 minutes

# User Configs
REPO_PATH=$HOME/code/i3-pomo
source $REPO_PATH/etc/i3-pomo/*.conf

function show_help {
	echo 'Usage: pomodoro.sh [OPTION]...'
	echo -e "\t-b Start in break mode (~5 minutes before work)"
	echo -e "\t-v Verbose output"
	echo -e "\t-w Start in work mode (~about 25 minutes of work before break)"
    echo -e "\t-h|? show this help message and exit"
    exit 0
}

#system
THISFILE="$(basename "$0")"
PID_OF_THISFILE=$(pgrep -f "$THISFILE")
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
	for i in $(ls $REPO_PATH/src/i3-pomo/start-study/*.sh); do
		source ${i} > /dev/null
	done
	echo $STUDYTIME_SECONDS
	exit 0
}

function start_breaktime {
	for i in $(ls $REPO_PATH/src/i3-pomo/start-break/*.sh); do
		source ${i} > /dev/null
	done
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

function killwarningbar {
	killall i3-nagbar 2> /dev/null
}

function warningbar {
	MESSAGE="$(echo 'Break WILL begin in' $BREAKTIME_WARNING_SECONDS 'seconds')"
	i3-nagbar -m "$MESSAGE" \
		-t warning \
		-B "EMERGENCY STOP" "kill $PID_OF_THISFILE && killall i3-nagbar 2> /dev/null" \
		-B "WAAIIITTTT..... I need 5 more minutes" "pkill -USR1 -f $THISFILE"
}

# Show help if no arguments are given
if [ $# -eq 0 ]; then
	show_help
	exit 0
fi

# Accept option flags
while getopts "h?bwv" opt; do
	case "$opt" in
		h|\?)
			show_help
			exit 0
			;;
		b)
			MODE='break'
			COUNT="$(start_breaktime)"
			echo 'Starting in Break mode'
			;;
		v)
			VERBOSE='true'
			;;
		w)
			MODE='study'
			COUNT="$(start_studytime)"
			echo 'Starting in Work mode'
			;;
	esac
done

# Runtime
while true; do
	verbose $MODE $COUNT
	if [[ $COUNT = '' ]]; then
		exit 1;
	fi
	if [[ $MODE = 'study' ]]; then
		if [[ "$COUNT" -eq "$BREAKTIME_WARNING_SECONDS" ]]; then
			warningbar &
		fi
		if [[ $COUNT -eq "$((${BREAKTIME_WARNING_SECONDS}-${AUTOCLOSE_BREAKTIME_WARNINGBAR_AFTER_N_SECONDS}))" ]]; then
			killwarningbar 
		fi
		if [[ $COUNT -le '0' ]]; then
			killwarningbar 
			MODE='break'
			COUNT=$(start_breaktime)
		fi
	fi
	if [[ $MODE = 'break' ]]; then
		if [[ $COUNT -le '0' ]]; then
			MODE='study'
			COUNT=$(start_studytime)
		fi
	fi
	COUNT=$(next_second $COUNT)
done




