#!/bin/zsh

## Extension Attribute to report which mode Microsoft AutoUpdate is using

if [ -d /Library/Application\ Support/Microsoft/MAU2.0/Microsoft\ AutoUpdate.app ]; then
    HowToCheck=`python -c "from Foundation import CFPreferencesCopyAppValue; print CFPreferencesCopyAppValue('HowToCheck', 'com.microsoft.autoupdate2')"`

    if [ "$HowToCheck" = "None" ]; then    
        echo "<result>AutomaticDownload (inferred)</result>"
    else
        echo "<result>$HowToCheck</result>"
    fi
else
    echo "<result>Not installed</result>"
fi

exit 0