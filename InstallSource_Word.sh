#!/bin/zsh
#set -x

## Extension Attribute to report how Microsoft Word was installed

if [ -d /Applications/Microsoft\ Word.app ]; then
	SOURCE=$(/usr/bin/mdls -name kMDItemAppStoreReceiptType /Applications/Microsoft\ Word.app | awk '{print $3}')
	if [ "$SOURCE" = '"Production"' ]; then
		echo "<result>Mac AppStore (user account)</result>"
	elif [ "$SOURCE" = '"ProductionVPP"' ]; then
		echo "<result>Mac AppStore (VPP)</result>"
    else
    	echo "<result>Office CDN</result>"
    fi
else
    echo "<result>Not installed</result>"
fi

exit 0