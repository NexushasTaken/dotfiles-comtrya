use_device=$(cat ~/.config/mouse-id.txt 2> /dev/null)
device=${mouse_device:-'USB OPTICAL MOUSE'}
xinput --set-prop "$device" 'libinput Accel Speed' -1.0
xinput --set-prop "$device" 'libinput Accel Profile Enabled' 0 0
