#!/sbin/sh
# Re-arm the legacy android_usb gadget until it enumerates.
# After a warm reboot from a hung system the Tegra UDC can stay in
# DISCONNECTED state, which leaves host adb "offline" until the cable is
# replugged. Toggling enable makes the kernel re-run the connect path.
S=/sys/class/android_usb/android0
sleep 2
i=0
while [ $i -lt 40 ]; do
    st=$(cat $S/state 2>/dev/null)
    [ "$st" = "CONFIGURED" ] && exit 0
    func=$(cat $S/functions 2>/dev/null)
    case "$func" in
        *ffs*) ;;
        *) func=ffs ;;
    esac
    echo 0 > $S/enable 2>/dev/null
    echo "$func" > $S/functions 2>/dev/null
    echo 1 > $S/enable 2>/dev/null
    i=$((i+1))
    sleep 2
done
