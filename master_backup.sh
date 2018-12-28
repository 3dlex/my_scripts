#!/bin/bash
# 
#Description: Backup script to be run daily.
# On Sunday a full backup is taken and the rest 
# of the days are incremental.
#
#Author: Matthew Davidson
#Date: 12-27-2018
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

#User to backup. Change to fit your needs.
USERBU="/home/matthew"

#Change destination to a location avaiable to you.
DESTINATION="/mnt/matthew/backup"

#File list used by incremental backups
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

#Script starts
scriptstart(){
    echo "############" | tee -a ${LOGFILE}
    echo "Starting new backup" | tee -a ${LOGFILE}
    echo "Today is: ${DATE}" | tee -a ${LOGFILE}
}

#Due to disk space constraints we need to purge older backups
# A full backup is moved to a safe location offsite once a month.
purgeoldbackup(){
    find ${DESTINATION} -mtime +14 -type f -delete
}

#Determine day of the week. Monday - Saturday are incremental and
# Sunday are full backups.
fullorincremental(){
    if [[ $(date +%u) != 7 ]]; then
        echo "We will run an incremental."
        BACKUP="incremental"
    else
        echo "We will run a full backup."
        BACKUP="full"
    fi
}

#Incremental : process_files function
#Find files created in the past 24 hours but avoid "dot" files.
#The -path option checks a pattern against the entire path string. * is a wildcard,
# / is a directory separator, \. is a dot (it has to be escaped to avoid special meaning),
# and * is another wildcard. -not means don't select files that match this test.
process_files(){
    if [[ ${BACKUP} == "incremental" ]]; then
        find "${USERBU}" -not -path '*/\.*' -ctime 0 -type f > "${FILES2BU}"
        for i in $(cat ${FILES2BU}); do
            echo backing up ${i} | tee -a ${LOGFILE}
            FILECOUNT=$((FILECOUNT + 1))
        done
        echo "Finished gathering files for incremental backup. We have ${FILECOUNT} files to backup." | tee -a ${LOGFILE}
    fi
}

#Create an archive either incremental or full.
create_archive(){
    if [[ ${BACKUP} == "incremental" ]]; then
        echo "############" | tee -a ${LOGFILE}
        echo "Now to create the incremental backup." | tee -a ${LOGFILE}
        tar -czf ${DESTINATION}/incremental_backup-$(date +%Y%m%d).tar.gz -T ${FILES2BU} >/dev/null 2>&1
        if [[ -f "${DESTINATION}/incremental_backup-$(date +%Y%m%d).tar.gz" ]]; then
            echo "Incremental backup complete." | tee -a ${LOGFILE}
            echo "Incremental backup is located at:" | tee -a ${LOGFILE} 
            echo "${DESTINATION}/incremental_backup-$(date +%Y%m%d).tar.gz" | tee -a ${LOGFILE}
        else
            echo "Check backup as file was not found." | tee -a ${LOGFILE}
        fi
    else
        echo "############" | tee -a ${LOGFILE}
        echo "Now to create the full backup." | tee -a ${LOGFILE}
        tar -czvf ${DESTINATION}/full_backup-$(date +%Y%m%d).tar.gz ${USERBU}
        if [[ -f "${DESTINATION}/full_backup-$(date +%Y%m%d).tar.gz" ]]; then
            echo full backup complete. | tee -a ${LOGFILE}
            echo full backup is located at ${DESTINATION}/full_backup-$(date +%Y%m%d).tar.gz | tee -a ${LOGFILE}
        else
            echo "Check backup as file was not found." | tee -a ${LOGFILE}
        fi
    fi
}

#Clean up left over temp files.
clean_up(){
    #Clean up leftover files and folders the script created
    rm ${FILES2BU}
}


##########################################################
#Script begins
scriptstart
purgeoldbackup
fullorincremental
process_files
create_archive
clean_up
