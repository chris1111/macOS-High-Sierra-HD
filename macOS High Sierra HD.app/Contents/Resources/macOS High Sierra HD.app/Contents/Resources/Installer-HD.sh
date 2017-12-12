#!/bin/bash
# macOS High Sierra HD
# Copyright (c) 2017, Chris1111 <leblond1111@gmail.com>
#
# Permission to use, copy, modify, and/or distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.

# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
# OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

if [[ $(mount | awk '$3 == "/Volumes/High-Sierra-HD" {print $3}') != "" ]]; then
 /usr/sbin/diskutil rename "/Volumes/High-Sierra-HD" "HighSierra-HD"
fi

# Vars
apptitle="macOS High Sierra HD"
version="1.0"
# Set Icon directory and file 
iconfile="/System/Library/CoreServices/Installer.app/Contents/Resources/Installer.icns"


osascript ./Scripts/main.app

# Select Install macOS
response=$(osascript -e 'tell app "System Events" to display dialog "Select Install macOS for choose your Install macOS High Sierra.app\n\nSelect Cancel for Quit" buttons {"Cancel","Install macOS"} default button 2 with title "'"$apptitle"' '"$version"'" with icon POSIX file "'"$iconfile"'"  ')

action=$(echo $response | cut -d ':' -f2)


# Get image file location
  imagepath=`/usr/bin/osascript << EOT
    tell application "Finder"
        activate
        set imagefilepath to choose file default location "/Applications" with prompt "Select your Install macOS High Sierra.app"
    end tell 
    return (posix path of imagefilepath) 
  EOT`

  # Cancel is user selects Cancel
  if [ ! "$imagepath" ] ; then
    osascript -e 'display notification "Program closing" with title "'"$apptitle"'" subtitle "User cancelled"'
    exit 0
  fi

hdiutil attach "$imagepath"/Contents/SharedSupport/InstallESD.dmg -noverify -nobrowse -mountpoint /tmp/Installer-OS

hdiutil attach "$imagepath"/Contents/SharedSupport/BaseSystem.dmg -noverify -nobrowse -mountpoint /tmp/Base-OS

echo " "

echo "
***********************************************************
********* Important *********
Select Volumes ➤ High-Sierra-HD
You will need to register the Log and exit macOS Installer
at the end of the installation to continue! "
echo " 
***********************************************************  "
osascript ./Scripts/OSINSTALL.app

echo " "
rsync -a --progress "/tmp/Base-OS/System/Library/CoreServices/boot.efi" "/Volumes/High-Sierra-HD/System/Library/CoreServices"

osascript -e 'tell app "System Events" to display dialog "
Download Recovery HD procedure from the Apple server
Be patient during Downloads!" with icon file "System:Library:CoreServices:CoreTypes.bundle:Contents:Resources:FinderIcon.icns" buttons {"OK"} default button 1 with title "RecoveryHD"'
echo " "

echo " "

osascript -e 'display notification "Starting" with title "macOS High Sierra HD"  sound name "default"'
echo "  "
echo "
***********************************************************
Downloads macOS High Sierra Recovery HD
Be patient during Downloads, the window
installation of the program will open at the end.
***********************************************************  "

# Downloads Recovery HD
curl -L http://swcdn.apple.com/content/downloads/01/50/091-52054/sxphm0npb8edfz2wqnulli6pd0pcripw2s/macOSUpdCombo10.13.2ForSeed.RecoveryHDUpdate.pkg -o /tmp/RecoveryHD.pkg

echo " "
echo " 
Install Recovery HD ➤ Volumes / High-Sierra-HD
approximate duration 15 seconds . . . . 
********************************************** "
osascript -e 'tell app "System Events" to display dialog "
Install Recovery HD ➤ Volumes/High-Sierra-HD " with icon file "System:Library:CoreServices:CoreTypes.bundle:Contents:Resources:FinderIcon.icns" buttons {"OK"} default button 1 with title "Recovery HD"' 

Sleep 2
# run the pkg
osascript -e 'do shell script "installer -allowUntrusted -verboseR -pkg /tmp/RecoveryHD.pkg -target /Volumes/High-Sierra-HD" with administrator privileges'


# script Notifications
osascript -e 'display notification "Completed" with title "Installation Recovery HD"  sound name "default"'
Sleep 2

# Unmount the dmg image
hdiutil detach -Force /tmp/Installer-OS

# Unmount the dmg image
hdiutil detach -Force /tmp/Base-OS

# Remove package Recovery HD
rm -r /tmp/RecoveryHD.pkg


echo "  "
echo "
***********************************************************
Installation macOS High Sierra HD Completed.
Enjoy! "
echo "***********************************************************  "
echo "  "