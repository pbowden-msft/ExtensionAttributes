#!/bin/zsh

## Extension Attribute to report the version of the WebEx injection-based plug-in for Outlook

if [ -d /Library/Application\ Support/Microsoft/WebExPlugin/WebexOutlookPlugin.bundle ]; then
    WebExVersion=`/usr/bin/defaults read /Library/Application\ Support/Microsoft/WebExPlugin/WebexOutlookPlugin.bundle/Contents/Info.plist CFBundleVersion`
    echo "<result>$WebExVersion</result>"
else
    echo "<result>Not installed</result>"
fi

exit 0