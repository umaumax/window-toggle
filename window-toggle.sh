#!/usr/bin/env bash
[[ $# -lt 2 ]] && echo "$0 target <target window class> [<launch command>]" && exit 1
target=$1
cmd=(${@:2})

export DISPLAY=:0

function get_info() {
	local WID=$1
	# [command line \- How do I find the window dimensions and position accurately including decorations? \- Unix & Linux Stack Exchange]( https://unix.stackexchange.com/questions/14159/how-do-i-find-the-window-dimensions-and-position-accurately-including-decoration )
	eval $(xwininfo -id $WID |
		sed -n -e "s/^ \+Absolute upper-left X: \+\([0-9]\+\).*/x=\1/p" \
			-e "s/^ \+Absolute upper-left Y: \+\([0-9]\+\).*/y=\1/p" \
			-e "s/^ \+Width: \+\([0-9]\+\).*/w=\1/p" \
			-e "s/^ \+Height: \+\([0-9]\+\).*/h=\1/p" \
			-e "s/^ \+Relative upper-left X: \+\([0-9]\+\).*/b=\1/p" \
			-e "s/^ \+Relative upper-left Y: \+\([0-9]\+\).*/t=\1/p")
	if [ "$entire" = true ]; then # if user wanted entire window, adjust x,y,w and h
		let x=$x-$b
		let y=$y-$t
		let w=$w+2*$b
		let h=$h+$t+$b
	fi
	echo "$w" "$h" "$x" "$y" "$b" "$t"
}

function detect() {
	xwininfo -id $WID | grep 'Depth: 0' >/dev/null && return 0
	[[ "$target" == "Terminator" ]] && xwininfo -id $WID | grep 'Depth: 24' >/dev/null && return 0

	local info=($(get_info $WID))
	local w=${info[0]}
	local h=${info[1]}
	local x=${info[2]}
	local y=${info[3]}
	local b=${info[4]}
	local t=${info[5]}
	if [[ "$target" == "Hyper" ]]; then
		[[ $b == 0 ]] && [[ $t == 0 ]] && [[ $x != 0 ]] && [[ $y != 0 ]] || return 0
	fi
	return 1
}

function map() {
	echo "map"
	echo "map args:" "$@"
	for WID in "$@"; do
		echo $WID
		detect $WID && continue
		xdotool windowmap $WID
	done
}
function focus() {
	echo "focus"
	echo "focus args:" "$@"
	for WID in "$@"; do
		detect $WID && continue
		echo "focus $WID"
		xdotool windowfocus $WID
		wait_focus $WID
		xdotool windowactivate $WID
		# set top view
		# xdotool windowraise $WID
		# windowをmain displayへ強制的に移動
		# NOTE: 事前に得られた情報を元にしているので、汎用性なし
		local info=($(get_info $WID))
		local w=${info[0]}
		local h=${info[1]}
		local x=${info[2]}
		local y=${info[3]}
		local b=${info[4]}
		local t=${info[5]}
		if [[ "$target" == "Terminator" ]] && [[ $x == 1969 ]]; then
			x=49
			xdotool windowmove $WID $x $y
			xdotool windowsize $WID 1871 1056
		fi
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
	echo "${rev[@]}"
}
VISIBLE_WIDS=($(xdotool search --onlyvisible --class "$target"))
# echo 'onlyvisible'
# echo "${VISIBLE_WIDS[@]}"
if [[ ${#VISIBLE_WIDS[@]} == 0 ]]; then
	WIDS=($(xdotool search --class "$target"))
	echo 'windowmap'
	echo "${WIDS[@]}"
	map $(REVERSE "${WIDS[@]}")
	echo 'focus and activate'
	focus $(REVERSE "${WIDS[@]}") && exit 0
	# NOTE: launch app
	# NOTE: gnome-terminalは`&`は不要
	"${cmd[@]}" &
	exit 0
else
	WIDS=($(xdotool search --class "$target"))
	# 	FOCUSED_WID=$(xdotool getwindowfocus)
	FOCUSED_WID=$(xdotool getactivewindow)
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
