#!/bin/zsh

## Extension Attribute to report the list of web-based add-ins that Outlook has loaded

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

GetManifestsFolder() {
	MANIFESTPATH=$(/usr/bin/find "$HOME/Library/Containers/com.microsoft.Outlook/Data/Library/Application Support/Microsoft/Office/16.0/Wef" -name 'Manifests')
	echo "$MANIFESTPATH"
}

## Main
LoggedInUser=$(GetLoggedInUser)
GetHomeFolder "$LoggedInUser"
ManifestsFolder=$(GetManifestsFolder)

# Enumerate files in the Manifests folder
if [ -d "$ManifestsFolder" ]; then
	for manifest in $ManifestsFolder/**; do
		ADDIN=$(cat "$manifest" | grep '<DisplayName' | cut -d '"' -f2)
		if [ "$ADDIN" != "" ]; then
			AddInList+="$ADDIN;"
		fi
	done
	echo "<result>$AddInList</result>"

else
	echo "<result>None</result>"
fi

exit 0