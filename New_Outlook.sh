#!/bin/zsh

## Extension Attribute to report whether a user is actively running New Outlook (aka Phoenix)

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

RunningPhoenix() {
	PHOENIX=$(/usr/bin/defaults read "$HOME/Library/Containers/com.microsoft.Outlook/Data/Library/Preferences/com.microsoft.Outlook" IsRunningNewOutlook)
	echo "$PHOENIX"
}

## Main
LoggedInUser=$(GetLoggedInUser)
GetHomeFolder "$LoggedInUser"
RunningNewOutlook=$(RunningPhoenix)

if [ "$RunningNewOutlook" = "1" ]; then
	echo "<result>Yes</result>"
else	
	echo "<result>No</result>"
fi

exit 0