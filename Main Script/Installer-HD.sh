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

# Remove the image if exist

if [[ $(mount | awk '$3 == "/Volumes/RecoveryHDMeta" {print $3}') != "" ]]; then
 hdiutil detach "/Volumes/RecoveryHDMeta"
fi

if [ "/tmp/RecoveryHDMeta.sparseimage" ]; then
	rm -rf "/tmp/RecoveryHDMeta.sparseimage"
fi

if [ "/tmp/RecoveryHDMeta.dmg" ]; then
	rm -rf "/tmp/RecoveryHDMeta.dmg"
fi


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
Sleep 2

echo "
***********************************************************
Creation macOS High Sierra Recovery HD
***********************************************************  "
rsync -a --progress ./Tools /tmp

# Create the Recovery HD for HFS+J/APFS
hdiutil create -size 600m -type SPARSE -fs HFS+J -volname RecoveryHDMeta -uid 0 -gid 80 -mode 1775 /tmp/RecoveryHDMeta

# Mount the image
hdiutil attach -nobrowse /tmp/RecoveryHDMeta.sparseimage


rsync -a --progress "$imagepath/Contents/SharedSupport/BaseSystem.dmg" "/Volumes/RecoveryHDMeta"
rsync -a --progress "$imagepath/Contents/SharedSupport/AppleDiagnostics.chunklist" "/Volumes/RecoveryHDMeta"
rsync -a --progress "$imagepath/Contents/SharedSupport/BaseSystem.chunklist" "/Volumes/RecoveryHDMeta"
rsync -a --progress "$imagepath/Contents/SharedSupport/AppleDiagnostics.dmg" "/Volumes/RecoveryHDMeta"
Sleep 2


echo "
***********************************************************
Installation Recovery HD
***********************************************************  "

# unmount the Image
hdiutil detach -Force /Volumes/RecoveryHDMeta

# convert the Image
hdiutil convert /tmp/RecoveryHDMeta.sparseimage -format UDZO -o /tmp/RecoveryHDMeta.dmg

# Unmount the dmg image
hdiutil detach -Force /tmp/Installer-OS

# Unmount the dmg image
hdiutil detach -Force /tmp/Base-OS
