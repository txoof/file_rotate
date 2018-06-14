#!/bin/bash
# Adapted from 
# Julius Zaromskis
# https://nicaw.wordpress.com/2013/04/18/bash-backup-rotation-script/
# Backup rotation

# Storage folder where to move backup files
# add check here for backup directories
# Must contain backup.monthly backup.weekly backup.daily folders
storage=./test/

# Source folder where files are backed
source=$storage/today

# Destination file names
date_daily=`date +"%d-%m-%Y"`
#date_weekly=`date +"%V sav. %m-%Y"`
#date_monthly=`date +"%m-%Y"`

# Get current month and week day number
month_day=`date +"%d"`
week_day=`date +"%u"`

# check if storage folders exist and create if they do not 
directories=("backup.daily" "backup.weekly" "backup.monthly")
for i in "${directories[@]}"
do :
    if [ ! -d $storage$i ] ; then
      mkdir $storage$i
    fi
done

# Optional check if source files exist. Email if failed.
#if [ ! -f $source/archive.tgz ]; then
#ls -l $source/ | mail your@email.com -s "[backup script] Daily backup failed! Please check for missing files."
#fi

# It is logical to run this script daily. We take files from source folder and move them to
# appropriate destination folder

# On first month day do
if [ "$month_day" -eq 1 ] ; then
  destination=$storage/backup.monthly/$date_daily
else
  # On saturdays do
  if [ "$week_day" -eq 6 ] ; then
    destination=$storage/backup.weekly/$date_daily
  else
    # On any regular day do
    destination=$storage/backup.daily/$date_daily
  fi
fi
echo "destination for backup files: ${destination}"


# copy the files into the backup folder
# add option to compress 
mkdir $destination
cp -r $source/* $destination

# daily - keep for 7 days
find $storage/backup.daily/ -maxdepth 1 -mtime +7 -type d -exec rm -rv {} \;

# weekly - keep for 30 days
find $storage/backup.weekly/ -maxdepth 1 -mtime +30 -type d -exec rm -rv {} \;

# monthly - keep for 180 days
find $storage/backup.monthly/ -maxdepth 1 -mtime +180 -type d -exec rm -rv {} \;
