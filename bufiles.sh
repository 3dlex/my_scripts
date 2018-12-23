#!/bin/bash

#Create required files and directories
touch files2bu
#touch bu_archive/incremental_backup-log-$(date +%Y%m%d).txt
mkdir bu

#Find files created in the past 24 hours
#find Calibre\ Library/ -ctime 0 -type f >> files2bu
find Documents/ -ctime 0 -type f >> files2bu
find Downloads/ -ctime 0 -type f >> files2bu
find Music/ -ctime 0 -type f >> files2bu
find Pictures/ -ctime 0 -type f >> files2bu
find Templates/ -ctime 0 -type f >> files2bu
find Videos/ -ctime 0 -type f >> files2bu
find myapp/ -ctime 0 -type f >> files2bu

#Copy files to backup folder
for i in `cat files2bu`
do
echo backing up $i
cp $i bu/
done
echo "Finished gathering files for backup."

#Create an archive
echo "############"
echo "Now to create the archive."
tar -cvzf incremental_backup-$(date +%Y%m%d).tar.gz bu/
mv incremental_backup-$(date +%Y%m%d).tar.gz bu_archive/
cp files2bu bu_archive/incremental_backup-log-$(date +%Y%m%d).txt
echo Incremental backup complete.
echo Incremental backup is located at /home/matthew/bu_archive/incremental_backup-$(date +%Y%m%d).tar.gz.
cp /home/matthew/bu_archive/incremental_backup-$(date +%Y%m%d).tar.gz /home/matthew/ownCloud/basement_desktop/
cp /home/matthew/bu_archive/incremental_backup-log-$(date +%Y%m%d).txt /home/matthew/ownCloud/basement_desktop/
#Clean up leftove files and folders the archive created
rm files2bu
rm -rf bu/
