#!/bin/zsh
#set -x

TOOL_NAME="Microsoft Outlook Local Folders Size Extension Attribute"
TOOL_VERSION="1.1"

# There are two parts to the returned value. 
#   'Legacy' refers to the total size of local messages in legacy (aka Classic) Outlook
#   'New' refers to the total size of local messages in New Outlook
# In some cases, both values may be greater than 0.00MB. This means that the user has local messages in both modes

## Copyright (c) 2023 Microsoft Corp. All rights reserved.
## Scripts are not supported under any Microsoft standard support program or service. The scripts are provided AS IS without warranty of any kind.
## Microsoft disclaims all implied warranties including, without limitation, any implied warranties of merchantability or of fitness for a 
## particular purpose. The entire risk arising out of the use or performance of the scripts and documentation remains with you. In no event shall
## Microsoft, its authors, or anyone else involved in the creation, production, or delivery of the scripts be liable for any damages whatsoever 
## (including, without limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary 
## loss) arising out of the use of or inability to use the sample scripts or documentation, even if Microsoft has been advised of the possibility
## of such damages.
## Feedback: pbowden@microsoft.com

# Function to determine the logged-in state of the Mac
function DetermineLoginState() {
	USERNAME=$(/usr/bin/last -1 -t ttys000 | /usr/bin/awk '{print $1}')
	CMD_PREFIX="sudo -u ${USERNAME} "
}

# Function to determine which Outlook profile is in use
function DetermineOutlookProfile() {
	PROFILE_NAME=$( defaults read "/Users/${USERNAME}/Library/Group Containers/UBF8T346G9.Office/OutlookProfile.plist" Default_Profile_Name )
}

# Function to determine the path to the Outlook database
function DetermineOutlookDB() {
	OUTLOOK_DB="/Users/${USERNAME}/Library/Group Containers/UBF8T346G9.Office/Outlook/Outlook 15 Profiles/${PROFILE_NAME}/Data/Outlook.sqlite"
	OUTLOOK_FOLDER="/Users/${USERNAME}/Library/Group Containers/UBF8T346G9.Office/Outlook/Outlook 15 Profiles/${PROFILE_NAME}/Data/"
	OUTLOOK_NEW_OMC="/Users/${USERNAME}/Library/Group Containers/UBF8T346G9.Office/Outlook/Outlook 15 Profiles/${PROFILE_NAME}/Omc/"
}

# Function to get the list of local messages from the classic Outlook database, and then get the file size on disk
function GetLocalMessages() {
	OMCSIZE=0
	local MSGRESULT=$(sqlite3 "${OUTLOOK_DB}" "SELECT PathToDataFile from Mail WHERE Record_AccountUID='0'")
	declare -a MSGARRAY
	SAVEIFS=$IFS
	IFS=$'\n'
	MSGARRAY=(${MSGRESULT})
	IFS=$SAVEIFS
	for msg in "${MSGARRAY[@]}"
	do
		MSGSIZE=$(/usr/bin/stat -qf%z "${OUTLOOK_FOLDER}${msg}")
		OMCSIZE=$(($OMCSIZE + $MSGSIZE))
	done
	LEGACYSIZE_MB=$(/usr/bin/awk "BEGIN {printf \"%.2f\n\", ${OMCSIZE}/1000/1000}")
}

# Function to get the list of local messages from New Outlook's Omc folders, and then get the file size on disk
function GetNewOmcMessages() {
	NEWOMCSIZE=0
	NEWOMCSIZE=$(/usr/bin/find ${OUTLOOK_NEW_OMC} -iname '*.eml' -ls | awk '{total += $7} END {print total}')
	NEWOMCSIZE_MB=$(/usr/bin/awk "BEGIN {printf \"%.2f\n\", ${NEWOMCSIZE}/1000/1000}")
}

## MAIN
DetermineLoginState
DetermineOutlookProfile
DetermineOutlookDB
GetLocalMessages
GetNewOmcMessages

/bin/echo "<result>Legacy:${LEGACYSIZE_MB}MB / New:${NEWOMCSIZE_MB}MB</result>"

exit 0