#!/bin/zsh
#set -x

: <<ABOUT_THIS_SCRIPT
-----------------------------------------------------------------------

	Written by: Paul Bowden
	Software Engineer
	Microsoft Corporation
	pbowden@microsoft.com
	https://github.com/pbowden-msft/ExtensionAttributes
		
	Adapted from a script by: William Smith
	Professional Services Engineer
	Jamf
	bill@talkingmoose.net
	https://github.com/talkingmoose/Casper-Scripts

	Last updated: April 7, 2021
	Originally posted: January 7, 2017
	
	Purpose: Use this script as part of an extension attribute in Jamf
	to report the type of Microsoft Office license in use.

	Except where otherwise noted, this work is licensed under
	http://creativecommons.org/licenses/by/4.0/

	"Communication happens when I know that you know what I know."

INSTRUCTIONS

	1) Log in to the Jamf Pro server.
	2) Navigate to JSS Settings > Computer Management > Extension Attributes.
	3) Click the " + " button to create a new extension attribute with these settings:
	   Display Name: Office License
	   Description: Reports Office license in use.
	   Data Type: String
	   Inventory Display: Extension Attributes
	   Input Type: Script
	   Script: < Copy and paste this entire script >
	4) Save the extension attribute.
	5) Use Recon.app or "sudo jamf recon" to inventory a Mac with Office installed.
	6) View the results under the Extension Attributes payload
	   of the computer's record or include the extension attribute
	   when adding criteria to an Advanced Computer Search or Smart Group.
	
-----------------------------------------------------------------------
ABOUT_THIS_SCRIPT

# Constants
PERPETUALLICENSE="/Library/Preferences/com.microsoft.office.licensingV2.plist"

# Detects the presence of a perpetual license
DetectPerpetualLicense() {
	if [ -f "$PERPETUALLICENSE" ]; then
		/bin/echo "Yes"
	else
		/bin/echo "No"
	fi
}

# Detects single vs. stacked license
DetectStackedLicense() {
	if [ -f "$PERPETUALLICENSE" ]; then
		LINECOUNT=$(/usr/bin/wc -l "$PERPETUALLICENSE" | awk {'print $1'})
		if [ "$LINECOUNT" = "125" ]; then
			/bin/echo "Yes"
		else
			/bin/echo "No"
		fi
	fi
}

# Determines what type of perpetual license the machine has installed
PerpetualLicenseType() {
	if [ -f "$PERPETUALLICENSE" ]; then
		if /usr/bin/grep -q "Bozo+MzVxzFzbIo+hhzTl43O7w5oMsJ7M3Q4vhvz/j" "$PERPETUALLICENSE"; then
			/bin/echo "Office 2021 Preview Volume License"
			return
		fi
		if /usr/bin/grep -q "Bozo+MzVxzFzbIo+hhzTl4xkRZSjOUX8J8nIgpXuMa" "$PERPETUALLICENSE"; then
			/bin/echo "Office 2021 Volume License"
			return
		fi
		if /usr/bin/grep -q "A7vRjN2l/dCJHZOm8LKan11/zCYPCRpyChB6lOrgfi" "$PERPETUALLICENSE"; then
			if [ "$STACKED" = "Yes" ]; then
				/bin/echo "Office 2021/2019 Volume License (Stacked)"
				return
			else
				/bin/echo "Office 2019 Volume License"
				return
			fi
		fi
		if /usr/bin/grep -q "Bozo+MzVxzFzbIo+hhzTl4JKv18WeUuUhLXtH0z36s" "$PERPETUALLICENSE"; then
			/bin/echo "Office 2019 Preview Volume License"
			return
		fi
		if /usr/bin/grep -q "A7vRjN2l/dCJHZOm8LKan1Jax2s2f21lEF8Pe11Y+V" "$PERPETUALLICENSE"; then
			/bin/echo "Office 2016 Volume License"
			return
		fi
		if /usr/bin/grep -q "DrL/l9tx4T9MsjKloHI5eX" "$PERPETUALLICENSE"; then
			/bin/echo "Office 2016 Home and Business License"
			return
		fi
		if /usr/bin/grep -q "C8l2E2OeU13/p1FPI6EJAn" "$PERPETUALLICENSE"; then
			/bin/echo "Office 2016 Home and Student License"
			return
		fi
		if /usr/bin/grep -q "Bozo+MzVxzFzbIo+hhzTl4m" "$PERPETUALLICENSE"; then
			/bin/echo "Office 2019 Home and Business License"
			return
		fi
		if /usr/bin/grep -q "Bozo+MzVxzFzbIo+hhzTl4j" "$PERPETUALLICENSE"; then
			/bin/echo "Office 2019 Home and Student License"
			return
		fi
		/bin/echo "Office Perpetual License"
	fi
}

# Creates a list of local usernames with UIDs above 500 (not hidden)
DetectO365License() {
	userList=$( /usr/bin/dscl /Local/Default -list /Users uid | /usr/bin/awk '$2 >= 501 { print $1 }' )
	
	while IFS= read -r aUser
	do
		# get the user's home folder path
		homePath=$( eval /bin/echo ~$aUser )
	
		# list of potential Office 365 activation files
		O365SUBMAIN="$homePath/Library/Group Containers/UBF8T346G9.Office/com.microsoft.Office365V2.plist"
		O365SUBNEW="$homePath/Library/Group Containers/UBF8T346G9.Office/Licenses/5"
		O365SUBBAK1="$homePath/Library/Group Containers/UBF8T346G9.Office/com.microsoft.O4kTOBJ0M5ITQxATLEJkQ40SNwQDNtQUOxATL1YUNxQUO2E0e.plist"
		O365SUBBAK2="$homePath/Library/Group Containers/UBF8T346G9.Office/O4kTOBJ0M5ITQxATLEJkQ40SNwQDNtQUOxATL1YUNxQUO2E0e" # hidden file
	
		# checks to see if an O365 subscription license file is present for each user
		if [ -f "$O365SUBMAIN" ] || [ -f "$O365SUBBAK1" ] || [ -f "$O365SUBBAK2" ] || [ -d "$O365SUBNEW" ]; then
			activations=$((activations+1))
		fi
	done <<< "$userList"
	
	# Returns the number of activations to O365ACTIVATIONS
	/bin/echo $activations
}

## Main

PERPETUALPRESENT=$(DetectPerpetualLicense)
STACKED=$(DetectStackedLicense)
O365ACTIVATIONS=$(DetectO365License)

if [ "$PERPETUALPRESENT" = "Yes" ] && [ "$O365ACTIVATIONS" ]; then
	/bin/echo "<result>Volume and Office 365 licenses detected. Only the volume license will be used.</result>"

elif [ "$PERPETUALPRESENT" = "Yes" ]; then
	LICTYPE=$(PerpetualLicenseType)
	/bin/echo "<result>$LICTYPE</result>"
	
elif [ "$O365ACTIVATIONS" ]; then
	/bin/echo "<result>Office 365 activations: $O365ACTIVATIONS</result>"
	
elif [ "$PERPETUALPRESENT" = "No" ] && [ ! "$O365ACTIVATIONS" ]; then
	/bin/echo "<result>No license</result>"
fi

exit 0