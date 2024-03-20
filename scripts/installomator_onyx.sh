#!/bin/sh

# Installation using Installomator
# Installation of software using valuesfromarguments to install a custom software using Installomator

LOGO="mosyleb" # "mosyleb", "mosylem", "addigy", "microsoft", "ws1", "kandji", "filewave"

# Have the label been submittet in a PR for Installomator?
# What version of Installomator is it expected to be included in?
# Version 10

item="onyx" # enter the software to install (if it has a label in future version of Installomator)

# Variables for label
name="Onyx"
type="dmg"
osVersion=$( sw_vers -productVersion | cut -f1 -d'.' )
downloadURL="https://www.titanium-software.fr/download/$osVersion/OnyX.dmg"
appNewVersion=$( curl -fs https://www.titanium-software.fr/en/onyx.html | grep -Eo "OnyX [0-9]+\.[0-9]+\.[0-9]+ for macOS [^ ]+ $osVersion" | awk '{print $2}' | sort -Vr | head -1 )
versionKey="CFBundleShortVersionString"
expectedTeamID="T49MRBL8UL"

installomatorOptions="BLOCKING_PROCESS_ACTION=prompt_user LOGGING=INFO NOTIFY=silent" # Separated by space

# Other installomatorOptions:
#   LOGGING=REQ
#   LOGGING=DEBUG
#   LOGGING=WARN
#   BLOCKING_PROCESS_ACTION=ignore
#   BLOCKING_PROCESS_ACTION=tell_user
#   BLOCKING_PROCESS_ACTION=tell_user_then_quit
#   BLOCKING_PROCESS_ACTION=prompt_user
#   BLOCKING_PROCESS_ACTION=prompt_user_loop
#   BLOCKING_PROCESS_ACTION=prompt_user_then_kill
#   BLOCKING_PROCESS_ACTION=quit
#   BLOCKING_PROCESS_ACTION=kill
#   NOTIFY=all
#   NOTIFY=success
#   NOTIFY=silent
#   IGNORE_APP_STORE_APPS=yes
#   INSTALL=force
######################################################################
# To be used as a script sent out from a MDM.
# Fill the variable "what" above with a label.
# Script will run this label through Installomator.
######################################################################
# v.  9.2.3 : Only kill the caffeinate process we create
# v.  9.2.2 : A bit more logging on succes.
# v.  9.2.1 : Better logging handling and installomatorOptions fix.
######################################################################

# Mark: Script
# PATH declaration
export PATH=/usr/bin:/bin:/usr/sbin:/sbin

echo "$(date +%F\ %T) [LOG-BEGIN] $what"

# Verify that Installomator has been installed
destFile="/usr/local/Installomator/Installomator.sh"
if [ ! -e "${destFile}" ]; then
    echo "Installomator not found here:"
    echo "${destFile}"
    echo "Exiting."
    exit 99
fi

# No sleeping
/usr/bin/caffeinate -d -i -m -u &
caffeinatepid=$!
caffexit () {
    kill "$caffeinatepid"
    exit $1
}

# Install software using Installomator with valuesfromarguments
cmdOutput="$(${destFile} valuesfromarguments LOGO=$LOGO \
    name=\"${name}\" \
    type=${type} \
    packageID=${packageID} \
    downloadURL=\"$downloadURL\" \
    appNewVersion=${appNewVersion} \
    versionKey=${versionKey} \
    expectedTeamID=${expectedTeamID} \
    blockingProcesses=\"NONE\" \
    ${installomatorOptions} || true)"


# Check result
exitStatus="$( echo "${cmdOutput}" | grep --binary-files=text -i "exit" | tail -1 | sed -E 's/.*exit code ([0-9]).*/\1/g' || true )"
if [[ ${exitStatus} -eq 0 ]] ; then
    echo "${what} succesfully installed."
    selectedOutput="$( echo "${cmdOutput}" | grep --binary-files=text -E ": (REQ|ERROR|WARN)" || true )"
    echo "$selectedOutput"
else
    echo "ERROR installing ${what}. Exit code ${exitStatus}"
    echo "$cmdOutput"
    #errorOutput="$( echo "${cmdOutput}" | grep --binary-files=text -i "error" || true )"
    #echo "$errorOutput"
fi

echo "[$(DATE)][LOG-END]"

caffexit $exitStatus
