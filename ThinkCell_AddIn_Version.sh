#!/bin/zsh

## Extension Attribute to report the version of the think-cell add-in for PowerPoint

if [ -d /Library/Application\ Support/Microsoft/think-cell/tcaddin.plugin ]; then
    ThinkCellVersion=`/usr/bin/defaults read /Library/Application\ Support/Microsoft/think-cell/tcaddin.plugin/Contents/Info.plist CFBundleVersion`
    echo "<result>$ThinkCellVersion</result>"
else
    echo "<result>Not installed</result>"
fi

exit 0