# window-toggle

script to use toggle window by app name

# NEW VRESION

```
$ wintoggle gnome-terminal-server.Gnome-terminal

$ wintoggle [app_name]
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
```

## TODO
* USE WINDOW_ID version not only APP_NAME
* enable xdotool version

----
----

# OLD VRESION

window toggle shell command for linux(mainly ubuntu)

* required xdotool and wmctrl
	* `sudo apt-get install xdotool`
	* `sudo apt-get install wmctrl`

## how to run
```
window-toggle 'Gnome-terminal' 'gnome-terminal'
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
$ wmctrl -l
# PID, 座標情報を含む(x,y,w,h)
$ wmctrl -p -G -l
# workspace info
$ wmctrl -d
0 * DG: 1120x621 VP: 0,0 WA: 65,24 1055x597 N/A
```

```
function xdotool-infos() {
	[[ $# == 0 ]] && echo "$0 <class>" && return 1
	xdotool search --class "$1" | xargs -L 1 sh -c 'printf "# $0"; xwininfo -id $0'
}
```
