#!/usr/bin/env bash
[[ $# -lt 2 ]] && echo "$0 target <target window class> [<launch command>]" && exit 1
target=$1
cmd=(${@:2})

export DISPLAY=:0

function focus() {
	for WID in "$@"; do
		is_visual=1
		xwininfo -id $WID | grep 'Depth: 0' >/dev/null
		[[ $? == 0 ]] && is_visual=0
		if [[ $is_visual == 1 ]]; then
			echo "focus $WID"
			xdotool windowfocus $WID
			wait_focus $WID
			xdotool windowactivate $WID
			return 0
		fi
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
	echo "${rev[@]}"
}
VISIBLE_WIDS=($(xdotool search --onlyvisible --class "$target"))
echo 'onlyvisible'
echo "${VISIBLE_WIDS[@]}"
if [[ ${#VISIBLE_WIDS[@]} == 0 ]]; then
	WIDS=($(xdotool search --class "$target"))
	echo 'windowmap'
	for WID in $(REVERSE "${WIDS[@]}"); do
		echo $WID
		xdotool windowmap $WID
	done
	echo 'focus and activate'
	focus $(REVERSE "${WIDS[@]}") && exit 0
	# NOTE: launch app
	# NOTE: gnome-terminalは`&`は不要
	"${cmd[@]}" &
	exit 0
else
	WIDS=($(xdotool search --class "$target"))
	FOCUSED_WID=$(xdotool getwindowfocus)
	echo 'avtivate'
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

	echo 'windowunmap'
	for WID in "${VISIBLE_WIDS[@]}"; do
		xdotool windowunmap $WID
	done
	exit 0
fi
