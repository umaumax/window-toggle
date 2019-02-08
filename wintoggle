#!/usr/bin/env bash

# DEBUG=1
function debug() {
	[[ -n $DEBUG ]] && echo "[DEBUG] $*"
}
debug "environment variables"
debug "DEBUG: [$DEBUG]"
debug "USE_XDOTOOL: [$USE_XDOTOOL]"

function cmdcheck() { type >/dev/null 2>&1 "$@"; }
! cmdcheck wmctrl && echo 'REQUIRED: wmctrl' && exit 1
! cmdcheck xprop && echo 'REQUIRED: xprop' && exit 1

export DISPLAY=:0

# ----
# function is_wmctrl_id() {
# 	echo "$1" | grep -q '0x' && [[ ${#1} == 10 ]]
# }
# function is_xprop_id() {
# 	echo "$1" | grep -q '0x' && [[ ${#1} != 10 ]]
# }
# function is_xdotool_id() {
# 	echo "$1" | grep -q -v '0x'
# }
function to_wmctrl_id() {
	printf '0x%08x' $(printf '%d' "$1")
}
function to_xprop_id() {
	printf '0x%x' $(printf '%d' "$1")
}
function to_xdotool_id() {
	printf '%d' "$1"
}

# NOTE: wmctrl -lは下記の状態の中で番号順でソートされている
# * shaded on (hidden)
# * shaded off(visuable)
# つまり，下記のappを対象とすれば，ほぼ確実に，shadedの状態がわかる
# 0x0240000a  0 N/A  xxx-VirtualBox Hud

# FYI: [wmctrl \- Get Active Window ID in Hex not Decimal \- Ask Ubuntu]( https://askubuntu.com/questions/646771/get-active-window-id-in-hex-not-decimal )
function get_active_window_id() {
	local target_window_id=$(wmctrl -lp | grep $(to_wmctrl_id $(xprop -root | grep _NET_ACTIVE_WINDOW | head -1 | awk '{print $5}' | sed 's/,//')) | cut -d' ' -f1)
	[[ -z $target_window_id ]] && return 1
	echo "$target_window_id"
}

function app_filter() {
	local app_name=$1
	case "$app_name" in
	"tilda.Tilda")
		grep "$app_name" | grep '\-1' | grep -v 'Config'
		;;
	"terminator.Terminator")
		grep "$app_name" | grep -v 'Terminator Preferences'
		;;
	*)
		grep "$app_name"
		;;
	esac
}

function is_focus() {
	local app_name=$1
	local active_window_id=$(get_active_window_id)
	local app_first_window_id=$(get_first_window_id $app_name)
	debug "active_window_id:$active_window_id"
	debug "app_first_window_id:$app_first_window_id"
	[[ $app_first_window_id != $active_window_id ]]
	return
}

function is_hidden() {
	# NOTE: before desktop_window.Nautilus app or not
	local app_name=$1
	local target_window_id=$(wmctrl -lx | sed -n '1,/N\/A/p' | app_filter "$app_name" | cut -d' ' -f1 | head -n 1)
	[[ -n "$target_window_id" ]]
	return
}
function is_shown() {
	# NOTE: after desktop_window.Nautilus app or not
	local app_name=$1
	local target_window_id=$(wmctrl -lx | sed -n '/N\/A/,$p' | app_filter "$app_name" | cut -d' ' -f1 | head -n 1)
	[[ -n "$target_window_id" ]]
	return
}
function is_exist() {
	local app_name=$1
	local target_window_id=$(wmctrl -lx | app_filter "$app_name" | cut -d' ' -f1 | head -n 1)
	[[ -n "$target_window_id" ]]
	return
}
# NOTE: order 1.hidden window(id order) 2.shown window(id order)
function get_first_window_id() {
	local app_name=$1
	local target_window_id=$(wmctrl -lx | app_filter "$app_name" | cut -d' ' -f1 | head -n 1)
	echo "$target_window_id"
}

function start_app() {
	local app_name=$1
	case "$app_name" in
	"gnome-terminal-server.Gnome-terminal")
		gnome-terminal
		;;
	"tilda.Tilda")
		nohup tilda </dev/null 1>/dev/null 2>/dev/null &
		;;
	"terminator.Terminator")
		nohup terminator </dev/null 1>/dev/null 2>/dev/null &
		;;
	"xterm.UXTerm")
		nohup uxterm </dev/null 1>/dev/null 2>/dev/null &
		;;
	"xterm.XTerm")
		nohup xterm </dev/null 1>/dev/null 2>/dev/null &
		;;
	"urxvt.URxvt")
		nohup urxvt </dev/null 1>/dev/null 2>/dev/null &
		;;
	"Alacritty.Alacritty")
		nohup alacritty </dev/null 1>/dev/null 2>/dev/null &
		;;
	"Navigator.Firefox")
		nohup firefox </dev/null 1>/dev/null 2>/dev/null &
		;;
	"nautilus.Nautilus")
		nohup xdg-open $PWD </dev/null 1>/dev/null 2>/dev/null &
		;;
		#   "guake.Main.py")
	*)
		echo "Cannot find launch cmd of '$app_name'"
		return 1
		;;
	esac
}

function hide_window() {
	local app_name=$1
	local target_window_id=$(get_first_window_id $app_name)
	[[ -z $target_window_id ]] && return 1
	# hide
	[[ -n $USE_XDOTOOL ]] && xdotool windowunmap $(to_xdotool_id $target_window_id) && return 0
	wmctrl -i -r $target_window_id -b add,shaded
}

function show_window() {
	local app_name=$1
	local target_window_id=$(get_first_window_id $app_name)
	[[ -z $target_window_id ]] && return 1
	# show
	[[ -n $USE_XDOTOOL ]] && xdotool windowmap $(to_xdotool_id $target_window_id) && return 0
	wmctrl -i -r $target_window_id -b remove,shaded
}

function focus_window() {
	local app_name=$1
	local target_window_id=$(get_first_window_id $app_name)
	[[ -z $target_window_id ]] && return 1
	# focus
	[[ -n $USE_XDOTOOL ]] && xdotool windowfocus $(to_xdotool_id $target_window_id) && return 0
	wmctrl -ia $target_window_id
}

function toggle_window() {
	debug 'toggle_window called'
	local app_name=$1
	if ! is_exist $app_name; then
		debug 'start_app call'
		start_app $app_name
		return
	fi

	if is_shown $app_name; then
		if is_focus $app_name; then
			debug 'focus_window call'
			focus_window $app_name
			return
		else
			debug 'hide_window call'
			hide_window $app_name
			return
		fi
	else
		debug 'show_window call'
		show_window $app_name
		debug 'focus_window call'
		focus_window $app_name
		return
	fi
}

function help() {
	echo "$0 [app_name]"
	cat <<'EOF'
* app_name example
  * gnome-terminal-server.Gnome-terminal
  * xterm.XTerm
  * xterm.UXTerm
  * tilda.Tilda
  * guake.Main.py
  * terminator.Terminator
  * urxvt.URxvt
  * Alacritty.Alacritty

  * nautilus.Nautilus
  * Navigator.Firefox

* environment variables
  * DEBUG=[0, 1]
  * USE_XDOTOOL=[0,1] WARN: don't mix wmctrl and xdotool and we have bugs now
EOF
}

[[ $# -lt 1 ]] && help && exit 1

app_name=$1
toggle_window $app_name
[[ $? == 0 ]] && exit 0
echo "No such application found! '$app_name'"
exit 1
