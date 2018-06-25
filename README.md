# window-toggle

window toggle shell command for linux(mainly ubuntu)

* required xdotool and wmctrl
	* `sudo apt-get install xdotool`
	* `sudo apt-get install wmctrl`

## how to run
```
./window-toggle.sh 'Gnome-terminal' 'gnome-terminal'
```

## NOTE
* windowが複数ある場合の挙動が不明

```
## WM_CLASS
# "nautilus", "Nautilus"
# "desktop_window", "Nautilus"
# "gnome-terminal-server", "Gnome-terminal"
# "xterm", "XTerm"
# "xterm", "UXTerm"
# "Navigator", "Firefox"
# "tilda", "Tilda"
# "terminator", "Terminator"
# "google-chrome", "Google-chrome"
# "hyper", "Hyper"

# WM_NAME
# "unity-panel"
# "unity-launcher"
```

## FYI
### xbindkeys
```
sudo apt-get install xbindkeys
```

----

```
# "/usr/bin/gnome-terminal --geometry=212x35+0+0 --title=TotalTerminal --full-screen"
```

* ウィンドウの情報をクリックで取得
```
xprop | grep -e WM_NAME -e WM_CLASS
xwininfo
```

```
wmctrl -l
```

```
function xdotool-infos() {
	[[ $# == 0 ]] && echo "$0 <class>" && return 1
	xdotool search --class "$1" | xargs -L 1 sh -c 'printf "# $0"; xwininfo -id $0'
}
```
