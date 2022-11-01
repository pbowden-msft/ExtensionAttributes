#!/bin/zsh
#set -x
## Extension Attribute to report the list of .installBackup apps created by Microsoft AutoUpdate

BackupAppList=$(ls -d /Applications/.*installBackup)
if [ ! $BackupAppList = '' ]; then
	echo "<result>$BackupAppList</result>"
else
	echo "<result>None</result>"
fi

exit 0