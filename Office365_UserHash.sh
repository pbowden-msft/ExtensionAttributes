#!/bin/zsh

## Extension Attribute to report the user primary identity hash associated with Office 365

function ReadUserIDHash {
	# creates a list of local usernames with UIDs above 500 (not hidden)
	userList=$( /usr/bin/dscl /Local/Default -list /Users uid | /usr/bin/awk '$2 >= 501 { print $1 }' )
	
	while IFS= read aUser
	do
		# get the user's home folder path
		HOMEPATH=$( eval /bin/echo ~$aUser )

		# pull the user hash from suite-wide defaults
		local RESULT=$(/usr/bin/defaults read $HOMEPATH/Library/Preferences/com.microsoft.office TenantAssociationOidKey)
	
		# checks to see if we got a hit
		if [ "$RESULT" != "" ]; then
			ids+="$RESULT;"
		fi
	done <<< "$userList"
	
	/bin/echo "$ids"
}

# Main
USERIDHASH=$(ReadUserIDHash)
if [ "$USERIDHASH" != "" ]; then
	/bin/echo "<result>$USERIDHASH</result>"
else
	/bin/echo "<result>Not detected</result>"
fi

exit 0