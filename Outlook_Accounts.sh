#!/bin/zsh

## Extension Attribute to report the list of email accounts configured in Outlook for Mac
##
## The result will be a semicolon-separated list of email addresses, with values such as:
##    pbowden@microsoft.com_ActiveSyncExchange_HxS;paul@myserver.com_InternetMailIMAP_Direct;pbowden@microsoft.com_Legacy;
##
## The first email address listed is the primary email account
## The suffix 'ActiveSyncExchange_HxS' refers to the sync technology in New Outlook (aka Phoenix)
## The suffix 'InternetMailIMAP_Direct' refers to the IMAP provider in New Outlook'
## The suffix 'Legacy" refers to an account (of any type) configured in legacy (aka classic) Outlook
## If you see duplicate email addresses listed, it's most likely that the same account is configured in both New and legacy Outlook

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

ListPhoenixAccounts() {
	PHOENIXACCOUNTS=$(/usr/bin/defaults read "$HOME/Library/Group Containers/UBF8T346G9.Office/Outlook/Outlook 15 Profiles/Main Profile/ProfilePreferences.plist" SortedAccounts | grep '_' | tr -d '("),' | awk '{printf("%s;",$0)} END { printf "\n" }' | grep '_' | tr -d '[:space:]')
	echo "$PHOENIXACCOUNTS"
}

ListLegacyAccounts() {
	LEGACYACCOUNTS=$(/usr/bin/sqlite3 "$HOME/Library/Group Containers/UBF8T346G9.Office/Outlook/Outlook 15 Profiles/Main Profile/Data/Outlook.sqlite" "SELECT Account_EmailAddress FROM AccountsMail;" | awk '{printf("%s_Legacy;",$0)} END { printf "\n" }')
	echo "$LEGACYACCOUNTS"
}


## Main
LoggedInUser=$(GetLoggedInUser)
GetHomeFolder "$LoggedInUser"
AccountList=$(ListPhoenixAccounts)
AccountList+=$(ListLegacyAccounts)

if [ "$AccountList" = "" ]; then
	echo "<result>None configured</result>"
else	
	echo "<result>$AccountList</result>"
fi

exit 0