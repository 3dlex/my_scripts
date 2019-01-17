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
# Requires logrotate to be setup.
LOGFILE="/var/log/mybackup.log"

#User to backup. Change to fit your needs.
USERBU="/home/matthew"

#Change destination to a location avaiable to you.
DESTINATION="/mnt/matthew/backup"

#File list used by incremental backups
FILES2BU="/tmp/files2bu"
touch "${FILES2BU}"
#Verify FILES2BU was created and exit if not
if [[ ! -f "${FILES2BU}" ]]; then
    echo "${FILES2BU} was not created. Exiting now." | tee -a "${LOGFILE}"
    exit 1
fi

#Variable used to count number of files backed up. Useful when script is run
# manually or exiting an incremental if there are no files to backup. 
FILECOUNT=0

##########################################################
#Functions

logit(){
    echo "$(date) ${1}" | tee -a ${LOGFILE}
}

#Script starts
scriptstart(){
    logit "############"
    logit "Starting new backup"
    logit "Today is: ${DATE}"
}

#Due to disk space constraints we need to purge older backups
# A full backup is moved to a safe location offsite once a month.
purgeoldbackup(){
    logit "Purge older backups. Log file will also contain the names of deleted files."
    find ${DESTINATION} -mtime +31 -type f -print -delete | tee -a ${LOGFILE}
    logit "############"
}

#Determine day of the week and set variable. Monday - Saturday are 
# incremental and Sunday are full backups.
fullorincremental(){
    if [[ $(date +%u) != 7 ]]; then
        BACKUP="incremental"
    else
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
        logit "Incremental backup chosen. Gathering files."
        find "${USERBU}" -not -path '*/\.*' -ctime 0 -type f > "${FILES2BU}"
        for i in $(cat ${FILES2BU}); do
            logit "Backing up ${i}"
            FILECOUNT=$((FILECOUNT + 1))
        done
        logit "Finished gathering files for incremental backup. We have ${FILECOUNT} files to backup."
        if [[ ${FILECOUNT} == "0" ]]; then
            logit "Since there are no files to backup we will exit script."
            exit 0
        fi
    fi
}

#Create an archive either incremental or full.
create_archive(){
    if [[ ${BACKUP} == "incremental" ]]; then
        logit "############"
        logit "Now to create the incremental backup."
        tar -czf ${DESTINATION}/incremental_backup-$(date +%Y%m%d).tar.gz -T ${FILES2BU} >/dev/null 2>&1
        if [[ -f "${DESTINATION}/incremental_backup-$(date +%Y%m%d).tar.gz" ]]; then
            logit "Incremental backup complete."
            logit "Incremental backup is located at:"
            logit "${DESTINATION}/incremental_backup-$(date +%Y%m%d).tar.gz"
        else
            logit "Check backup as file was not found."
        fi
    else
        logit "############"
        logit "Now to create the full backup."
        tar -czvf ${DESTINATION}/full_backup-$(date +%Y%m%d).tar.gz ${USERBU} >/dev/null 2>&1
        if [[ -f "${DESTINATION}/full_backup-$(date +%Y%m%d).tar.gz" ]]; then
            logit "Full backup complete."
            logit "Full backup is located at ${DESTINATION}/full_backup-$(date +%Y%m%d).tar.gz"
        else
            logit "Check backup as file was not found."
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
