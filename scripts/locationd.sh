#! /bin/zsh
# Enable location service
/usr/bin/defaults write /var/db/locationd/Library/Preferences/ByHost/com.apple.locationd LocationServicesEnabled -bool true; /bin/launchctl kickstart -k system/com.apple.locationd 2>&1
# Set auto timezone
/usr/sbin/systemsetup -setusingnetworktime on
exit 0
