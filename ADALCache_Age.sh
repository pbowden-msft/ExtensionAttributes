#!/bin/zsh

## Extension Attribute to report the age (in days) since the com.microsoft.adalcache keychain entry was created

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

# Find out if the login.keychain is in the path - if not, add it
KeychainHasLogin=$(/usr/bin/sudo -u $LoggedInUser /usr/bin/security list-keychains | grep 'login.keychain')
if [ "$KeychainHasLogin" = "" ]; then
	/usr/bin/sudo -u $LoggedInUser /usr/bin/security list-keychains -s "$HOME/Library/Keychains/login.keychain-db"
fi

# Get today's date in the 8-digit format of YYYYMMDD
DateToday=$(date "+%Y%m%d")

# Get the creation date of the keychain entry
KeychainCreationDate=$(/usr/bin/sudo -u $LoggedInUser /usr/bin/security find-generic-password -l 'com.microsoft.adalcache' | grep 'cdat' | cut -d '"' -f4)

# Trim the keychain date into the 8-digit format of YYMMDD
TrimmedCreationDate=${KeychainCreationDate:0:8}

if [ "$TrimmedCreationDate" = "" ]; then
	# Return Not found value if we could not find or parse the keychain entry
    echo "<result>Not found</result>"
else
    # Perform simple math to calculate the delta in days between today's date and creation date
    (( Delta = $DateToday - $TrimmedCreationDate ))
    echo "<result>$Delta</result>"
fi

exit 0