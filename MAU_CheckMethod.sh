#!/bin/zsh

## Extension Attribute to report which mode Microsoft AutoUpdate is using

if [ -d /Library/Application\ Support/Microsoft/MAU2.0/Microsoft\ AutoUpdate.app ]; then
	HowToCheck=$(defaults read /Users/rstasel/Library/Preferences/com.microsoft.autoupdate2 HowToCheck 2>/dev/null)

if [ -z "$HowToCheck" ]; then    
        echo "<result>AutomaticDownload (inferred)</result>"
    else
        echo "<result>$HowToCheck</result>"
    fi
else
    echo "<result>Not installed</result>"
fi

exit 0
