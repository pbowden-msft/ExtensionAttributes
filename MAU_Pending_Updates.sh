#!/bin/zsh
#set -x
## Extension Attribute to report the list of apps that AutoUpdate 4.34 (and later) has ready to install and pending closure of the running version

autoload is-at-least

CheckMAUVersion() {
	if [ -d /Library/Application\ Support/Microsoft/MAU2.0/Microsoft\ AutoUpdate.app ]; then
    		APPVERSION=$(/usr/bin/defaults read /Library/Application\ Support/Microsoft/MAU2.0/Microsoft\ AutoUpdate.app/Contents/Info.plist CFBundleShortVersionString)
    		if ! is-at-least 4.34 $APPVERSION; then
			echo "<result>MAU version is unsupported</result>"
			exit 0
		fi
	else
    		echo "<result>MAU is not installed</result>"
    		exit 0
	fi
}

GetCloneFolder() {
	if is-at-least 4.50 $APPVERSION; then
		CLONEPATH="/Library/Caches/com.microsoft.autoupdate.helper/Clones.noindex"
	elif is-at-least 4.35 $APPVERSION; then
		CLONEPATH="/Library/Caches/com.microsoft.autoupdate.helper/Clones"
	else
		CLONEPATH=$(/usr/bin/find /var/folders -name 'MSauClones')
	fi
	echo "$CLONEPATH"
}

## Main
CheckMAUVersion
CloneFolder=$(GetCloneFolder)

# Enumerate the apps in the clone folder
if [ -d "$CloneFolder" ]; then
	for app in $CloneFolder/**; do
		CLONEAPPNAME=$(defaults read "$app/Contents/Info" CFBundleName)
		CLONEAPPVER=$(defaults read "$app/Contents/Info" CFBundleVersion)
		BASEAPPBUNDLE=$(/usr/bin/basename "$app")
		INSTALLEDAPPVER=$(defaults read "/Applications/$BASEAPPBUNDLE/Contents/Info" CFBundleVersion)
		if [[ $CLONEAPPVER != $INSTALLEDAPPVER ]]; then
			APPSTRING="$CLONEAPPNAME [$CLONEAPPVER]"
			AppList+="$APPSTRING;"
		fi
	done
	echo "<result>$AppList</result>"

else
	echo "<result>None</result>"
fi

exit 0