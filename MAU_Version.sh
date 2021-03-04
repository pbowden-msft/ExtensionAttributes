#!/bin/zsh

## Extension Attribute to report the installed version of Microsoft AutoUpdate

if [ -d /Library/Application\ Support/Microsoft/MAU2.0/Microsoft\ AutoUpdate.app ]; then
    AppVersion=`/usr/bin/defaults read /Library/Application\ Support/Microsoft/MAU2.0/Microsoft\ AutoUpdate.app/Contents/Info.plist CFBundleShortVersionString`
    echo "<result>$AppVersion</result>"
else
    echo "<result>Not installed</result>"
fi

exit 0