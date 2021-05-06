#!/bin/zsh

## Extension Attribute to report whether Teams has an update pending
## Returned values and meaning:
##    'Teams is not installed' = The Teams app wasn't found at its default path of /Applications/Microsoft Teams.app
##    'Teams is not running [version]' = Teams is installed (the version number is in parenthesis), but Teams is not launched, so it might not be getting updates
##    'Teams is up to date [version]' = Teams believes that it is running the latest version available
##    'Teams is running [version], update detected [version]' = Teams has detected that an update is available, but has not yet downloaded it
##    'Teams is running [version], update ready to install [version]' = Teams has downloaded an update and is ready to install it

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

GetInstalledVersion() {
	if [ -d /Applications/Microsoft\ Teams.app ]; then
    		INSTALLEDVER=$(/usr/bin/defaults read /Applications/Microsoft\ Teams.app/Contents/Info.plist CFBundleVersion)
		echo "$INSTALLEDVER"
	fi
}

TeamsIsClosed() {
 	TEAMSPPROC=$(/usr/bin/pgrep 'Microsoft Teams')
	echo "$?"
}

TeamsFoundUpdate() {
 	if [ -e $HOME/Library/Application\ Support/Microsoft/Teams/tmp/x64.json ]; then
		TEAMSUPDATE=$(cat $HOME/Library/Application\ Support/Microsoft/Teams/tmp/x64.json | grep '"isUpdateAvailable":true')
		if [ $? = "0" ]; then
			DETECTEDVERSION=$(cat $HOME/Library/Application\ Support/Microsoft/Teams/tmp/x64.json | grep -o '\d*\.\d*\.\d*\.\d*' | grep '' -m 1 | cut -c3 -c6 -c8 -c9 -c10 -c11)
			echo "$DETECTEDVERSION"
		fi
	fi
}

TeamsStagedUpdate() {
 	if [ -e $HOME/Library/Application\ Support/Microsoft/Teams/tmp/Teams_osx.pkg ]; then
		echo "true"
	fi
}

## Main
LoggedInUser=$(GetLoggedInUser)
GetHomeFolder "$LoggedInUser"

InstalledVersion=$(GetInstalledVersion)
if [ "$InstalledVersion" = "" ]; then
	echo "<result>Teams is not installed</result>"
	exit 0
fi

TeamsLaunchState=$(TeamsIsClosed)
if [ "$TeamsLaunchState" = "1" ]; then
	echo "<result>Teams is installed but not running [$InstalledVersion]</result>"
	exit 0
fi

DetectedVersion=$(TeamsFoundUpdate)
if [ "$DetectedVersion" != "" ]; then
	PKGSTAGED=$(TeamsStagedUpdate)
	if [ "$PKGSTAGED" = "true" ]; then
		echo "<result>Teams is running [$InstalledVersion], update ready to install [$DetectedVersion]</result>"
	else
		echo "<result>Teams is running [$InstalledVersion], update detected [$DetectedVersion]</result>"
	fi
else
	echo "<result>Teams is up to date [$InstalledVersion]</result>"
fi

exit 0