#!/bin/zsh

## Extension Attribute to report the Device ID as reported by Microsoft Office apps

DeviceID=$(/usr/sbin/system_profiler SPHardwareDataType | grep "Hardware UUID" | cut -d ':' -f2 | cut -d ' ' -f2)
echo "<result>$DeviceID</result>"

exit 0