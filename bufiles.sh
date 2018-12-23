#!/bin/bash
# Incremental Backup script to be run daily.

#Setup and variables 
#Create required files and directories
#Change destination to a location avaiable to you.
DESTINATION="/mnt/matthew"
FILES2BU="/tmp/files2bu"
touch ${FILES2BU}
#Verify FILES2BU was created and exit if not

if [[ ! -f "${FILES2BU}" ]]; then
    echo "Exit as file not created."
    exit 1
fi

#Track how many files will be backed up.
FILECOUNT=0

#Find files created in the past 24 hours but avoid "dot" files.
#The -path option runs checks a pattern against the entire path string. * is a wildcard, 
# / is a directory separator, \. is a dot (it has to be escaped to avoid special meaning), 
# and * is another wildcard. -not means don't select files that match this test.
find ~/ -not -path '*/\.*' -ctime 0 -type f > ${FILES2BU}

#Dispaly files to user or send to a log with total number.
for i in $(cat ${FILES2BU})
do
    echo backing up ${i}
    FILECOUNT=$((FILECOUNT + 1))
done

echo "Finished gathering files for backup. We have ${FILECOUNT} files to backup."

#Create an archive
echo "############"
echo "Now to create the archive."
#tar -czf /tmp/incremental_backup-$(date +%Y%m%d).tar.gz -T ${FILES2BU} >/dev/null 2>&1
tar -czf ${DESTINATION}/incremental_backup-$(date +%Y%m%d).tar.gz -T ${FILES2BU} >/dev/null 2>&1
echo Incremental backup complete.
echo Incremental backup is located at /tmp/incremental_backup-$(date +%Y%m%d).tar.gz.
#Clean up leftover files and folders the script created
rm ${FILES2BU}
