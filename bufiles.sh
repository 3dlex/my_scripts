#!/bin/bash
# Incremental Backup script to be run daily.

#Setup and variables 
#Create required files and directories
DATE=$(date +%Y-%m-%d)
#Track how many files will be backed up.
FILECOUNT=0

#Log steps for troubleshooting.
LOGFILE="/tmp/backup-$(date +%Y%m%d)"

#Change destination to a location avaiable to you.
DESTINATION="/mnt/matthew"
FILES2BU="/tmp/files2bu"
touch ${FILES2BU}
#Verify FILES2BU was created and exit if not
if [[ ! -f "${FILES2BU}" ]]; then
    echo "Exit as file not created." | tee -a ${LOGFILE}
    exit 1
fi

echo "Today is: ${DATE}" | tee -a ${LOGFILE}
#Find files created in the past 24 hours but avoid "dot" files.
#The -path option runs checks a pattern against the entire path string. * is a wildcard, 
# / is a directory separator, \. is a dot (it has to be escaped to avoid special meaning), 
# and * is another wildcard. -not means don't select files that match this test.
find ~/ -not -path '*/\.*' -ctime 0 -type f > ${FILES2BU}

#Dispaly files to user or send to a log with total number.
for i in $(cat ${FILES2BU})
do
    echo backing up ${i} | tee -a ${LOGFILE}
    FILECOUNT=$((FILECOUNT + 1))
done

echo "Finished gathering files for backup. We have ${FILECOUNT} files to backup." | tee -a ${LOGFILE}

#Create an archive
echo "############"
echo "Now to create the archive."
tar -czf ${DESTINATION}/incremental_backup-$(date +%Y%m%d).tar.gz -T ${FILES2BU} >/dev/null 2>&1
if [[ -f "${DESTINATION}/incremental_backup-$(date +%Y%m%d).tar.gz" ]]; then
    echo Incremental backup complete. | tee -a ${LOGFILE}
    echo Incremental backup is located at ${DESTINATION}/incremental_backup-$(date +%Y%m%d).tar.gz. | tee -a ${LOGFILE}
else
    echo "Check backup as file was not found." | tee -a ${LOGFILE}
fi
#Clean up leftover files and folders the script created
rm ${FILES2BU}
