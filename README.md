# window-toggle

* required xdotool
	* ```sudo apt-get install -y xdotool```

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
sudo apt-get install wmctrl
```
```
# "/usr/bin/gnome-terminal --geometry=212x35+0+0 --title=TotalTerminal --full-screen"
```
* ウィンドウの情報をクリックで取得
```
xprop | grep -e WM_NAME -e WM_CLASS
xwininfo
wmctrl -l
```
