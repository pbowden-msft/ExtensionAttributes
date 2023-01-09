#!/bin/zsh

## Extension Attribute to report whether GuardAgainstAppModification is being used with Microsoft AutoUpdate

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
    RetainClone=$(getPrefValue "com.microsoft.autoupdate2" "GuardAgainstAppModification")

    if [ "$RetainClone" = "true" ]; then    
        echo "<result>Guard enabled</result>"
    else
        echo "<result>Guard disabled</result>"
    fi
else
    echo "<result>MAU not installed</result>"
fi

exit 0