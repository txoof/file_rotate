#!/bin/bash
# Adapted from 
# Julius Zaromskis
# https://nicaw.wordpress.com/2013/04/18/bash-backup-rotation-script/
# Backup rotation

# Storage folder where to move backup files
# add check here for backup directories
# Must contain backup.monthly backup.weekly backup.daily folders
storage=./test/
#storage=/storage/emulated/0/phone_backup/

# Source folder where files are backed
source=$storage/backup.today

# days to retain backups
retentionDaily=8
retentionWeekly=32
retentionMonthly=184

# Destination file names
date_daily=`date +"%Y-%m-%d"`
#date_weekly=`date +"%V sav. %m-%Y"`
#date_monthly=`date +"%m-%Y"`

# Get current month and week day number
month_day=`date +"%d"`
week_day=`date +"%u"`


# check if storage path exists
if [[ ! -d $storage && -w $storage ]] ; then
  mkdir $storage
fi

# check if source path exists
if [ ! -r $source ] ; then
  echo "source path ($source) is not readable"
  exit 1
fi

# check if storage folders exist and create if they do not 
directories=("backup.daily" "backup.weekly" "backup.monthly")
for i in "${directories[@]}"
do :
    echo "checking for $storage$i"
    if [ ! -d $storage$i ] ; then
      echo "making $storage/$i"
      mkdir $storage$i
    fi
done

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

# copy the files into the backup folder
# add option to compress 
if [ ! -d $destination ] ; then
  mkdir $destination
fi
cp -r $source/* $destination

# daily - keep for retentionDaily
find $storage/backup.daily/ -maxdepth 1 -mtime +$retentionDaily -type d -exec rm -rv {} \;

# weekly - keep for retentionWeekly
find $storage/backup.weekly/ -maxdepth 1 -mtime +$retentionWeekly -type d -exec rm -rv {} \;

# monthly - keep for retentionMonthly
find $storage/backup.monthly/ -maxdepth 1 -mtime +$retentionMonthly -type d -exec rm -rv {} \;
