#!/bin/zsh
# set -x

## Extension Attribute to report the list of modern web-based add-ins that Outlook has loaded

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
	# Outlook can create multiple Manifests folders, so get the most recent
	MANIFESTPATH=$(print -lr -- $HOME/Library/Containers/com.microsoft.Outlook/Data/Library/Application\ Support/Microsoft/Office/16.0/Wef/**/Manifests(om[1,1]))
	echo "$MANIFESTPATH"
}

## Main
LoggedInUser=$(GetLoggedInUser)
GetHomeFolder "$LoggedInUser"
ManifestsFolder=$(GetManifestsFolder)

# Enumerate files in the Manifests folder
if [ -d "$ManifestsFolder" ]; then
	for manifest in $ManifestsFolder/**; do
		# New Outlook uses binary-based manifests, so we need to remove non-text characters as part of the grep
		ADDIN=$(cat "$manifest" | LC_ALL=C tr -d '[\000-\011\013-\037\177-\377]' | grep '<DisplayName' | cut -d '"' -f2 | sed -e 's/^[[:space:]]*//')
		if [ "$ADDIN" != "" ]; then
			AddInList+="$ADDIN;"
		fi
	done
	echo "<result>$AddInList</result>"

else
	echo "<result>None</result>"
fi

exit 0