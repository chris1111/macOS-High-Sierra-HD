#!/bin/bash
TARGET="/Volumes/High-Sierra-HD"
MOUNT_POINT="$(/usr/bin/mktemp -d)"
/usr/bin/hdiutil attach -nobrowse /tmp/RecoveryHDMeta.dmg -mountpoint "${MOUNT_POINT}"
echo "Probing Target Volume: ${TARGET}"

FS_TYPE=$(diskutil info "${TARGET}" | awk '$1 == "Type" { print $NF }')
echo "Target Volume FS: ${FS_TYPE}"
if [[ "${FS_TYPE}" == "apfs" ]]; then
    echo "Running ensureRecoveryBooter for APFS target volume: ${TARGET}"
    /tmp/Tools/dm ensureRecoveryBooter "${TARGET}" -base "${MOUNT_POINT}/BaseSystem.dmg" "${MOUNT_POINT}/BaseSystem.chunklist" -diag "${MOUNT_POINT}/AppleDiagnostics.dmg" "${MOUNT_POINT}/AppleDiagnostics.chunklist" -diagmachineblacklist 0 -installbootfromtarget 0 -slurpappleboot 0 -delappleboot 0 -addkernelcoredump 0
else
    echo "Running ensureRecoveryPartition for Non-APFS target volume: ${TARGET}"
    /tmp/Tools/dm ensureRecoveryPartition "${TARGET}" "${MOUNT_POINT}/BaseSystem.dmg" "${MOUNT_POINT}/BaseSystem.chunklist" "${MOUNT_POINT}/AppleDiagnostics.dmg" "${MOUNT_POINT}/AppleDiagnostics.chunklist" 0 0 0
fi

echo "Eject ${MOUNT_POINT}"
/usr/bin/hdiutil eject "${MOUNT_POINT}"
echo "Delete ${MOUNT_POINT}"
/bin/rm -rf "${MOUNT_POINT}"


if [ "/tmp/RecoveryHDMeta.sparseimage" ]; then
	rm -rf "/tmp/RecoveryHDMeta.sparseimage"
fi


if [ "/tmp/Tools" ]; then
	rm -rf "/tmp/Tools"
fi


if [ "/tmp/RecoveryHDMeta.dmg" ]; then
	rm -rf "/tmp/RecoveryHDMeta.dmg"
fi

echo "  "
echo "
***********************************************************
=== Installation Recovery HD Completed! ===
***********************************************************  "

echo "  "

echo "  "

echo "  "

echo "  "

echo "  "

echo "  "

echo "  "

echo "  "


# script Notifications
osascript -e 'display notification "Completed" with title "Installation macOS High Sierra HD"  sound name "default"'

Sleep 2


echo "  "
echo "
***********************************************************
=== Installation macOS High Sierra HD Completed. ===

Enjoy! "
echo "***********************************************************  "
echo "  "

echo "  "

echo "  "