#!/sbin/sh
sleep 25
{
  echo "== ps adbd =="; ps | grep adbd
  echo "== functions =="; cat /sys/class/android_usb/android0/functions 2>&1
  echo "== enable =="; cat /sys/class/android_usb/android0/enable 2>&1
  echo "== state =="; cat /sys/class/android_usb/android0/state 2>&1
  echo "== ffs dir =="; ls -l /dev/usb-ffs/adb 2>&1
  echo "== props =="; getprop 2>/dev/null | grep -Ei 'adb|usb'
} > /data/media/usbdiag.txt 2>&1
dmesg > /data/media/dmesg9.txt 2>/dev/null
cp /tmp/recovery.log /data/media/recovery9.log 2>/dev/null
pkill adbd 2>/dev/null
sleep 1
/sbin/adbd --device_banner=recovery > /data/media/adbd.log 2>&1 &
sync
