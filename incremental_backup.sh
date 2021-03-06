#!/bin/bash
# 
#Description: Incremental backup script to be run daily.
#
#Author: Matthew Davidson
#Date: 12-23-2018
#
##########################################################
#Global Setup and variables 
VERSION="1.0"
SCRIPTNAME=$(basename "$0")
SCRIPTPATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
DATE=$(date +%Y-%m-%d)

#Log steps for troubleshooting.
# Need to migrate to proper log location.
LOGFILE="/tmp/backup-$(date +%Y%m%d)"

#User to backup. change to fit your needs.
USERBU="/home/matthew"

#Change destination to a location avaiable to you.
DESTINATION="/mnt/matthew"

#File list
FILES2BU="/tmp/files2bu"
touch "${FILES2BU}"
#Verify FILES2BU was created and exit if not
if [[ ! -f "${FILES2BU}" ]]; then
    echo "FILES2BU was not created. Exiting now." | tee -a "${LOGFILE}"
    exit 1
fi

#Variable used to count number of files backed up. Useful when script is run manually. 
FILECOUNT=0

##########################################################
#Functions

#Find files created in the past 24 hours but avoid "dot" files.
#The -path option checks a pattern against the entire path string. * is a wildcard, 
# / is a directory separator, \. is a dot (it has to be escaped to avoid special meaning), 
# and * is another wildcard. -not means don't select files that match this test.
find_files(){
    find "${USERBU}" -not -path '*/\.*' -ctime 0 -type f > "${FILES2BU}"
}

#Dispaly files to user or send to a log with total number.
process_files(){
    for i in $(cat ${FILES2BU}); do
        echo backing up ${i} | tee -a ${LOGFILE}
        FILECOUNT=$((FILECOUNT + 1))
    done
    echo "Finished gathering files for backup. We have ${FILECOUNT} files to backup." | tee -a ${LOGFILE}
}

#Create an archive
create_archive(){
    echo "############"
    echo "Now to create the archive."
    tar -czf ${DESTINATION}/incremental_backup-$(date +%Y%m%d).tar.gz -T ${FILES2BU} >/dev/null 2>&1
    if [[ -f "${DESTINATION}/incremental_backup-$(date +%Y%m%d).tar.gz" ]]; then
        echo Incremental backup complete. | tee -a ${LOGFILE}
        echo Incremental backup is located at ${DESTINATION}/incremental_backup-$(date +%Y%m%d).tar.gz. | tee -a ${LOGFILE}
    else
        echo "Check backup as file was not found." | tee -a ${LOGFILE}
    fi
}
    
#Clean up left over temp files.
clean_up(){
    #Clean up leftover files and folders the script created
    rm ${FILES2BU}
}

##########################################################
#Script starts
echo "Today is: ${DATE}" | tee -a ${LOGFILE}
find_files
process_files
create_archive
clean_up
