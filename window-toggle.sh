#!/usr/bin/env bash
[[ $# -lt 2 ]] && echo "$0 target <target window class> [<launch command>]" && exit 1
target=$1
cmd=(${@:2})

export DISPLAY=:0

function map() {
	for WID in "$@"; do
		# 		echo $WID
		xwininfo -id $WID | grep 'Map State: IsUnMapped' >/dev/null
		[[ $? == 0 ]] && continue
		xdotool windowmap $WID
	done
}
function focus() {
	for WID in "$@"; do
		# Map State: IsViewable
		# Map State: IsUnMapped
		# 		xwininfo -id $WID | grep 'Depth: 0' >/dev/null
		xwininfo -id $WID | grep 'Map State: IsUnMapped' >/dev/null
		[[ $? == 0 ]] && continue
		# 		echo "focus $WID"
		xdotool windowfocus $WID
		wait_focus $WID
		xdotool windowactivate $WID
		# set top view
		# 			xdotool windowraise $WID
		return 0
	done
	return 1
}
# NOTE: 一定の間，時間を開けずにgetwindowfocusを発行すると以降の間ずっとエラーとなるので，getactivewindowを用いる
function wait_focus() {
	local WID=$1
	local max=10
	for ((i = 0; i < $max; i++)); do
		FOCUSED_WID=$(xdotool getactivewindow)
		# 		FOCUSED_WID=$(xdotool getwindowfocus)
		[[ $WID == $FOCUSED_WID ]] && break
		sleep 0.1
	done
}
function REVERSE() {
	local rev=()
	for WID in "$@"; do
		rev=($WID "${rev[@]}")
	done
	# 	echo "${rev[@]}"
}
VISIBLE_WIDS=($(xdotool search --onlyvisible --class "$target"))
# echo 'onlyvisible'
# echo "${VISIBLE_WIDS[@]}"
if [[ ${#VISIBLE_WIDS[@]} == 0 ]]; then
	WIDS=($(xdotool search --class "$target"))
	# 	echo 'windowmap'
	map $(REVERSE "${WIDS[@]}")
	# 	echo 'focus and activate'
	focus $(REVERSE "${WIDS[@]}") && exit 0
	# NOTE: launch app
	# NOTE: gnome-terminalは`&`は不要
	"${cmd[@]}" &
	exit 0
else
	WIDS=($(xdotool search --class "$target"))
	FOCUSED_WID=$(xdotool getwindowfocus)
	# 	echo 'activate'
	focus_flag=0
	for WID in "${WIDS[@]}"; do
		[[ $WID == $FOCUSED_WID ]] && focus_flag=1
	done
	# NOTE: only focus
	if [[ $focus_flag == 0 ]]; then
		echo 'focus and activate'
		focus "${WIDS[@]}"
		exit 0
	fi

	# 	echo 'windowunmap'
	for WID in "${VISIBLE_WIDS[@]}"; do
		xdotool windowunmap $WID
	done
	exit 0
fi
