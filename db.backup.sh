#!/bin/bash

# MySQL info you want to back up
DB_NAME='your_database_name'
DB_USER='your_mysql_user' # Make sure have privileges with lock tables
DB_PSWD='your_mysql_password'
DB_HOST='localhost'
DB_PORT='3306'

# S3 bucket where the file will be stored, please use trailing slash
S3_BUCKET='s3://your.bucket/path/'

# Temporary local place for backup
DUMP_LOC='/path/to/save/backup'

# How long the backup in local will be kept
DAYS_OLD="3"

# Logging
START_TIME="$(date +"%s")"
DATE_BAK="$(date +"%Y-%m-%d")"
DATE_EXEC="$(date "+%d+%b")"
DATE_EXEC_H="$(date "+%d %b %Y %H:%M")"

# Output for checking
echo "["$DATE_EXEC_H"] Backup process start.. "

echo "Backing up "$DB_NAME"..."
mysqldump --add-drop-table --lock-tables=true -u $DB_USER -p$DB_PSWD -h $DB_HOST -P $DB_PORT $DB_NAME | gzip -9 > $DUMP_LOC/$DB_NAME-$DATE_BAK.sql.gz

# Counting filezie
FILESIZE="$(ls -lah $DUMP_LOC/$DB_NAME-$DATE_BAK.sql.gz | awk '{print $5}')"

echo "Sending to Amazon S3..."
s3cmd --acl-private --delete-removed sync $DUMP_LOC/ $S3_BUCKET

echo "Removing old files..."
find $DUMP_LOC/*.sql.gz -mtime +$DAYS_OLD -exec rm {} \;

END_TIME="$(date +"%s")"
DIFF_TIME=$(( $END_TIME - $START_TIME ))
H=$(($DIFF_TIME/3600))
M=$(($DIFF_TIME%3600/60))
S=$(($DIFF_TIME%60))

TWT_MSG="$DATE_EXEC+|+$DB_NAME+($FILESIZE)+in+$H+hour(s)+$M+minute(s)+$S+seconds"

echo "Done: "$TWT_MSG

# You can tweet the message or sending DM to notify your backup is completed.