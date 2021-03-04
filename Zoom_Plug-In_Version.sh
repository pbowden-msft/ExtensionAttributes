#!/bin/zsh

## Extension Attribute to report the version of the Zoom injection-based plug-in for Outlook

if [ -d /Library/Application\ Support/ZoomOutlookPlugin/zOutlookPluginAgent.app ]; then
    ZoomVersion=`/usr/bin/defaults read /Library/Application\ Support/ZoomOutlookPlugin/zOutlookPluginAgent.app/Contents/Info.plist CFBundleVersion`
    echo "<result>$ZoomVersion</result>"
elif [ -d /Users/Shared/ZoomOutlookPlugin/zOutlookPluginAgent.app ]; then
    ZoomVersion=`/usr/bin/defaults read /Users/Shared/ZoomOutlookPlugin/zOutlookPluginAgent.app/Contents/Info.plist CFBundleVersion`
    echo "<result>$ZoomVersion</result>"
else
    echo "<result>Not installed</result>"
fi

exit 0