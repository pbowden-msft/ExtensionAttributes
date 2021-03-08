#!/bin/zsh

## Extension Attribute to report the tenant ID associated with Office 365

function ReadTenantID {
	# creates a list of local usernames with UIDs above 500 (not hidden)
	userList=$( /usr/bin/dscl /Local/Default -list /Users uid | /usr/bin/awk '$2 >= 501 { print $1 }' )
	
	while IFS= read aUser
	do
		# get the user's home folder path
		HOMEPATH=$( eval /bin/echo ~$aUser )

		# execute some sql to get the active O365 logon, if any
		local RESULT=$(/usr/bin/defaults read $HOMEPATH/Library/Preferences/com.microsoft.office TenantIDKey)
	
		# checks to see if we got a hit
		if [ "$RESULT" != "" ]; then
			ids+="$RESULT;"
		fi
	done <<< "$userList"
	
	/bin/echo "$ids"
}

# Main
TENANTID=$(ReadTenantID)
if [ "$TENANTID" != "" ]; then
	/bin/echo "<result>$TENANTID</result>"
else
	/bin/echo "<result>Not detected</result>"
fi

exit 0