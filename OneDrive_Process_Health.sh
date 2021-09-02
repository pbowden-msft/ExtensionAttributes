#!/bin/zsh

## Extension Attribute to report whether the OneDrive process is configured and running

GetLoggedInUser() {
	LOGGEDIN=$(/bin/echo "show State:/Users/ConsoleUser" | /usr/sbin/scutil | /usr/bin/awk '/Name :/&&!/loginwindow/{print $3}')
	if [ "$LOGGEDIN" = "" ]; then
		echo "$USER"
	else
		echo "$LOGGEDIN"
	fi
}

SetHomeFolder() {
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
SetHomeFolder "$LoggedInUser"

# Find out if OneDrive is configured
DataFile=$(ls -t $HOME/Library/Application\ Support/OneDrive/settings/Business1/*dat | head -n 1)
if [ "$DataFile" != "" ]; then
	OneDriveProcessId=$(/usr/bin/sudo -u $LoggedInUser /usr/bin/pgrep 'OneDrive')
	if [ "$OneDriveProcessId" != "" ]; then
		echo "<result>Running</result>"
	else
		echo "<result>Not running</result>"
	fi
else
	echo "<result>Not configured</result>"
fi

exit 0