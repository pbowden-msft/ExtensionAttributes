#!/bin/zsh

## Extension Attribute to report which mode Microsoft AutoUpdate is using

## Functions
function getPrefValue { # $1: domain, $2: key
     osascript -l JavaScript << EndOfScript
     ObjC.import('Foundation');
     ObjC.unwrap($.NSUserDefaults.alloc.initWithSuiteName('$1').objectForKey('$2'))
EndOfScript
}

function getPrefIsManaged { # $1: domain, $2: key
     osascript -l JavaScript << EndOfScript
     ObjC.import('Foundation')
     $.CFPreferencesAppValueIsForced(ObjC.wrap('$2'), ObjC.wrap('$1'))
EndOfScript
}

## Main
if [ -d /Library/Application\ Support/Microsoft/MAU2.0/Microsoft\ AutoUpdate.app ]; then
    HowToCheck=$(getPrefValue "com.microsoft.autoupdate2" "HowToCheck")

    if [ "$HowToCheck" = "" ]; then    
        echo "<result>AutomaticDownload (inferred)</result>"
    else
        echo "<result>$HowToCheck</result>"
    fi
else
    echo "<result>Not installed</result>"
fi

exit 0