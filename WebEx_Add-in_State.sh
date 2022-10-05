#!/bin/zsh
#set -x

## Extension Attribute to report if the Cisco WebEx Scheduler add-in is present in Outlook for Mac
WEBEXID="7a91e319-a65d-4ceb-909b-12203561dbf5"

GetLoggedInUser() {
	LOGGEDIN=$(/bin/echo "show State:/Users/ConsoleUser" | /usr/sbin/scutil | /usr/bin/awk '/Name :/&&!/loginwindow/{print $3}')
	if [ "$LOGGEDIN" = "" ]; then
		echo "$USER"
	else
		echo "$LOGGEDIN"
	fi
}

GetHomeFolder() {
	HOME=$(dscl . read /Users/"$1" NFSHomeDirectory | cut -d ':' -f2 | cut -d ' ' -f2)
	if [ "$HOME" = "" ]; then
		if [ -d "/Users/$1" ]; then
			HOME="/Users/$1"
		else
			HOME=$(eval echo "~$1")
		fi
	fi
}

## Main
LoggedInUser=$(GetLoggedInUser)
GetHomeFolder "$LoggedInUser"

PREFSFILE="$HOME/Library/Containers/com.microsoft.Outlook/Data/Library/Preferences/com.microsoft.Outlook.plist"
if [ -e "$PREFSFILE" ]; then
	IDSCACHE=$(defaults read "$PREFSFILE" MoeIdsCache | grep "$WEBEXID")
	if [ $? = 0 ]; then
		# We found the ID in the cache, so report that the extension is loaded
		echo "<result>Loaded</result>"
	else
		# We didn't find the ID in the cache, so report that the extension is NOT loaded
		echo "<result>Not Loaded</result>"
	fi
else
	# We didn't find the Outlook preferences file so either Outlook is not installed or hasn't been run
	echo "<result>Unknown</result>"
fi

exit 0