# rtc-bq32k-rRIO
Supercharging the RoboRIO with the BQ32000 from TI

Started off with the BQ32000 Module from Evola:
https://evola.fr/en/breakout-boards/813-real-time-clock-module-bq32000.html

It is wired up to the i2c port on the RoboRIO like this:
<insert pic here>

Next, pulled the kernel driver from the NI git repo here:
https://raw.githubusercontent.com/ni/linux/nilrt_pub/16.0/4.1/drivers/rtc/rtc-bq32k.c

This is a stock driver for Linux mainline from what I can tell.

This is built on the RoboRIO using these directions from NI:
https://forums.ni.com/t5/NI-Linux-Real-Time-Documents/Tutorial-Adding-Kernel-Modules-on-NI-Linux-Real-Time/ta-p/3527186

Note, you may need to add coreutils using opkg.
You will also need to add i2c-tools using opkg.

Summary of steps:
Pull down these files into a local directory.
run 'source /usr/local/natinst/tools/versioning_utils.sh'
run 'setup_versioning_env'
run 'versioning_call make'
run 'rtc-bq32k.ko /lib/modules/`uname -r`/kernel'
run 'depmod'

You should be able to run 'i2cdetect -y 2' and it will show something like this:
admin@roboRIO-900-FRC:~/rtc-bq32k# i2cdetect -y 2
     0  1  2  3  4  5  6  7  8  9  a  b  c  d  e  f
00:          -- -- -- -- -- -- -- -- -- -- -- -- -- 
10: -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
20: -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
30: -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
40: -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
50: -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
60: -- -- -- -- -- -- -- -- 68 -- -- -- -- -- -- -- 
70: -- -- -- -- -- -- -- --                         

The 68 indicates that the device has been found.

You can now run this to instantiate the device:
'echo bq32000 0x68 | tee /sys/class/i2c-adapter/i2c-2/new_device'

If you run 'i2cdetect -y 2' again it will show "UU" instead of 68 indicating that the device is active:
admin@roboRIO-900-FRC:~/rtc-bq32k# i2cdetect -y 2
     0  1  2  3  4  5  6  7  8  9  a  b  c  d  e  f
00:          -- -- -- -- -- -- -- -- -- -- -- -- -- 
10: -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
20: -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
30: -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
40: -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
50: -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
60: -- -- -- -- -- -- -- -- UU -- -- -- -- -- -- -- 
70: -- -- -- -- -- -- -- --                         

Running 'dmesg' will show something like this:
[   53.975048] bq32k 2-0068: Marshall's in your system messing with your clock!
[   53.975951] bq32k 2-0068: Enabled trickle RTC battery charge.
[   53.976784] bq32k 2-0068: rtc core: registered bq32k as rtc0

You can then proceed to set the clock and read from it:
Setting the clock: 'hwclock.util-linux --systohc --utc'
Reading from it: 'hwclock.util-linux -r -f /dev/rtc'
